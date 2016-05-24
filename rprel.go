package main

import (
	"encoding/json"
	"errors"
	"fmt"
	"github.com/jtacoma/uritemplates"
	"github.com/urfave/cli"
	"mime"
	"net/http"
	"os"
	"path/filepath"
	"strings"
	"time"
)

var Version string
var BuildTime string

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

func main() {
	var fullRepo string
	var releaseName string
	var authToken string
	var commitish string
	compiledTime, _ := time.Parse("2006-01-02T15:04:05-0700", BuildTime)
	cli.AppHelpTemplate = AppHelpTemplate

	app := cli.NewApp()
	app.Name = "rprel"
	app.Usage = "Create GitHub release and upload artifacts"
	app.UsageText = "rprel [options] files..."
	app.Version = Version
	app.Compiled = compiledTime
	app.Flags = []cli.Flag{
		cli.StringFlag{
			Name:        "commitsh, c",
			Value:       "master",
			Usage:       "The `COMMITISH` (sha, branch, etc.) that will be used to create the release",
			Destination: &commitish,
			EnvVar:      "RELEASE_COMMITISH",
		},
		cli.StringFlag{
			Name:        "token, t",
			Usage:       "The GitHub authentication `TOKEN`",
			Destination: &authToken,
			EnvVar:      "GITHUB_AUTH_TOKEN",
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
		if authToken == "" {
			return cli.NewExitError("Error: you must provide a GitHub auth token", 1)
		}
		if fullRepo == "" {
			return cli.NewExitError("Error: you must provide the full repo name", 1)
		}
		if releaseName == "" {
			return cli.NewExitError("Error: you must provide the release name", 1)
		}

		releaseInfo := Release{
			Name:      releaseName,
			Repo:      fullRepo,
			Commitish: commitish,
			Files:     ctx.Args(),
		}
		result := createRelease(&releaseInfo, ctx.Args(), authToken)
		if !result {
			return cli.NewExitError("The release could not be created :(", 1)
		}
		fmt.Println("Release created!")
		return nil
	}

	app.Run(os.Args)
}

func createRelease(release *Release, files []string, authToken string) bool {
	err := generateRelease(release, authToken)
	uploadReleaseAssets(release, authToken)
	// create release
	// upload files
	if err != nil {
		return false
	} else {
		return true
	}
}

func generateRelease(release *Release, authToken string) (err error) {
	url := "https://api.github.com/repos/" + release.Repo + "/releases"
	client := &http.Client{}
	body := strings.NewReader(`{"tag_name": "` + release.Name + `", "name": "` + release.Name + `", "commitish": "` + release.Commitish + `", "prerelease": true}`)
	req, err := http.NewRequest("POST", url, body)
	req.Header.Set("Authorization", "token "+authToken)

	resp, err := client.Do(req)
	if err != nil {
		fmt.Println(err.Error())
		return err
	}
	defer resp.Body.Close()

	jsonErr := json.NewDecoder(resp.Body).Decode(release)

	if err != nil {
		fmt.Println("Error: ", jsonErr.Error())
		return err
	}

	return nil
}

func uploadReleaseAssets(release *Release, authToken string) error {
	template, _ := uritemplates.Parse(release.UploadUrl)
	for i := 0; i < len(release.Files); i++ {
		err := uploadReleaseAsset(release.Files[i], template, authToken)
		if err != nil {
			return err
		}

	}

	return nil
}

func uploadReleaseAsset(fileName string, template *uritemplates.UriTemplate, authToken string) error {
	values := make(map[string]interface{})
	values["name"] = fileName
	file, err := os.Open(fileName)
	if err != nil {
		return errors.New("Error: there was an issue with the file '" + fileName + "'!")
	}
	url, _ := template.Expand(values)
	return doUploadReleaseAsset(file, url, authToken)
}

func doUploadReleaseAsset(file *os.File, url string, authToken string) error {
	stat, err := file.Stat()
	if err != nil {
		return err
	}
	if stat.IsDir() {
		return errors.New("the asset to upload can't be a directory")
	}
	mediaType := mime.TypeByExtension(filepath.Ext(file.Name()))

	client := &http.Client{}
	req, err := http.NewRequest("POST", url, file)
	req.Header.Set("Authorization", "token "+authToken)
	req.Header.Set("Content-Type", mediaType)
	req.ContentLength = stat.Size()
	resp, err := client.Do(req)

	if resp == nil {
		return errors.New("something wrong happened")
	}

	return err
}
