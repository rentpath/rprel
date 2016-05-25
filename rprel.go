package main

import (
	"encoding/json"
	"errors"
	"fmt"
	"github.com/jtacoma/uritemplates"
	"github.com/urfave/cli"
	"io"
	"io/ioutil"
	"mime"
	"net/http"
	"os"
	"path/filepath"
	"strings"
	"time"
)

var AppHelpTemplate = `NAME:
	{{.Name}} - {{.Usage}}
USAGE:
	{{if .UsageText}}{{.UsageText}}{{else}}{{.HelpName}} {{if .VisibleFlags}}[global options]{{end}}{{if .Commands}} command [command options]{{end}} {{if .ArgsUsage}}{{.ArgsUsage}}{{else}}[arguments...]{{end}}{{end}}
	{{if .Version}}{{if not .HideVersion}}
VERSION:
	{{.Version}}
	{{.Compiled}}
	{{end}}{{end}}{{if len .Authors}}
AUTHOR(S):
	{{range .Authors}}{{.}}{{end}}
	{{end}}{{if .VisibleCommands}}
OPTIONS:
	{{range .VisibleFlags}}{{.}}
	{{end}}{{end}}{{if .Copyright}}
COPYRIGHT:
	{{.Copyright}}
	{{end}}
`

type Release struct {
	Name      string
	Repo      string
	Commitish string
	Files     []string
	Id        int    `json:"id"`
	Url       string `json:"url"`
	UploadUrl string `json:"upload_url"`
}

var Version string
var BuildTime string
var AuthToken string

func main() {
	var fullRepo string
	var releaseName string
	var commitish string
	cli.AppHelpTemplate = AppHelpTemplate

	app := cli.NewApp()
	app.Name = "rprel"
	app.Usage = "Create GitHub release and upload artifacts"
	app.UsageText = "rprel [options] files..."
	app.Version = Version
	app.Compiled, _ = time.Parse("2006-01-02T15:04:05-0700", BuildTime)
	app.Flags = []cli.Flag{
		cli.StringFlag{
			Name:        "token, t",
			Usage:       "The GitHub authentication `TOKEN`",
			Destination: &AuthToken,
			EnvVar:      "GITHUB_AUTH_TOKEN",
		},
		cli.StringFlag{
			Name:        "commitsh, c",
			Value:       "master",
			Usage:       "The `COMMITISH` (sha, branch, etc.) that will be used to create the release",
			Destination: &commitish,
			EnvVar:      "RELEASE_COMMITISH",
		},
		cli.StringFlag{
			Name:        "repo, r",
			Usage:       "The full repo name, `OWNER/REPO`, where the release will be created",
			Destination: &fullRepo,
			EnvVar:      "FULL_REPO_NAME",
		},
		cli.StringFlag{
			Name:        "name, n",
			Usage:       "The release `NAME` (typically the version being released)",
			Destination: &releaseName,
			EnvVar:      "RELEASE_NAME",
		},
	}
	app.Action = func(ctx *cli.Context) error {
		if ctx.NArg() == 0 {
			return cli.NewExitError("Error: at least one release artifact must be provided", 1)
		}
		if AuthToken == "" {
			return cli.NewExitError("Error: you must provide a GitHub auth token", 1)
		}
		if fullRepo == "" {
			return cli.NewExitError("Error: you must provide the full repo name", 1)
		}
		if releaseName == "" {
			return cli.NewExitError("Error: you must provide the release name", 1)
		}

		release := Release{
			Name:      releaseName,
			Repo:      fullRepo,
			Commitish: commitish,
			Files:     ctx.Args(),
		}

		if err := generateRelease(&release); err != nil {
			return cli.NewExitError(err.Error(), 1)
		}
		if err := uploadReleaseAssets(&release); err != nil {
			return cli.NewExitError(err.Error(), 1)
		}
		fmt.Println("Release created!")
		return nil
	}
	app.Run(os.Args)
}

func generateRelease(release *Release) (err error) {
	url := "https://api.github.com/repos/" + release.Repo + "/releases"
	body := strings.NewReader(`{"tag_name": "` + release.Name + `", "name": "` + release.Name + `", "commitish": "` + release.Commitish + `", "prerelease": true}`)

	resp, err := githubPostRequest(url, body)
	if err != nil {
		return err
	}

	if err := json.Unmarshal(resp, release); err != nil {
		return err
	}
	return nil
}

func uploadReleaseAssets(release *Release) error {
	template, _ := uritemplates.Parse(release.UploadUrl)
	for i := 0; i < len(release.Files); i++ {
		if err := uploadReleaseAsset(release.Files[i], template); err != nil {
			return err
		}
	}

	return nil
}

func uploadReleaseAsset(fileName string, template *uritemplates.UriTemplate) error {
	file, err := os.Open(fileName)
	if err != nil {
		return err
	}
	stat, err := file.Stat()
	if err != nil {
		return err
	}
	if stat.IsDir() {
		return errors.New("the asset to upload can't be a directory")
	}
	if err != nil {
		return errors.New("Error: there was an issue with the file '" + fileName + "'!")
	}
	url, _ := template.Expand(map[string]interface{}{"name": fileName})
	mediaType := mime.TypeByExtension(filepath.Ext(file.Name()))
	headers := map[string]interface{}{"Content-Type": mediaType, "Content-Length": stat.Size()}

	_, err = githubPostRequest(url, file, headers)

	return err
}

func githubPostRequest(url string, body io.Reader, headers ...map[string]interface{}) (result []byte, err error) {
	client := &http.Client{}
	req, err := http.NewRequest("POST", url, body)
	req.Header.Set("Authorization", "token "+AuthToken)
	if len(headers) > 0 {
		for k, v := range headers[0] {
			if k == "Content-Length" {
				req.ContentLength = v.(int64)
			} else {
				req.Header.Set(k, v.(string))
			}
		}
	}
	resp, err := client.Do(req)
	defer resp.Body.Close()
	if err != nil {
		return []byte{}, err
	}

	return ioutil.ReadAll(resp.Body)
}
