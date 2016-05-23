package main

import (
	"fmt"
	"github.com/urfave/cli"
	"io/ioutil"
	"net/http"
	"os"
	"strings"
)

var AppHelpTemplate = `NAME:
	{{.Name}} - {{.Usage}}
USAGE:
	{{if .UsageText}}{{.UsageText}}{{else}}{{.HelpName}} {{if .VisibleFlags}}[global options]{{end}}{{if .Commands}} command [command options]{{end}} {{if .ArgsUsage}}{{.ArgsUsage}}{{else}}[arguments...]{{end}}{{end}}
	{{if .Version}}{{if not .HideVersion}}
VERSION:
	{{.Version}}
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

type ReleaseInfo struct {
	Name      string
	Repo      string
	Commitish string
}

func main() {
	var fullRepo string
	var releaseName string
	var authToken string
	var commitish string

	cli.AppHelpTemplate = AppHelpTemplate

	app := cli.NewApp()
	app.Name = "rprel"
	app.Usage = "Create GitHub release and upload artifacts"
	app.UsageText = "rprel [options] files..."
	app.Version = "1.2.5"
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

		releaseInfo := ReleaseInfo{
			Name:      releaseName,
			Repo:      fullRepo,
			Commitish: commitish,
		}
		result := createRelease(releaseInfo, ctx.Args(), authToken)
		if !result {
			return cli.NewExitError("The release could not be created :(", 1)
		}
		fmt.Println("Release created!")
		return nil
	}

	app.Run(os.Args)
}

func createRelease(info ReleaseInfo, files []string, authToken string) bool {
	result, _ := generateRelease(info, authToken)
	// create release
	// upload files
	for i := 0; i < len(files); i++ {
		fmt.Println(files[i])
	}

	return result
}

func generateRelease(info ReleaseInfo, authToken string) (result bool, err error) {
	url := "https://api.github.com/repos/" + info.Repo + "/releases"
	client := &http.Client{}
	body := strings.NewReader(`{"tag_name": "` + info.Name + `", "name": "` + info.Name + `", "commitish": "` + info.Commitish + `", "prerelease": true}`)
	req, err := http.NewRequest("POST", url, body)
	req.Header.Set("Authorization", "token "+authToken)

	resp, err := client.Do(req)
	if err != nil {
		fmt.Println(err.Error)
		return false, nil
	}
	defer resp.Body.Close()

	fmt.Println("response Status:", resp.Status)
	fmt.Println("response Headers:", resp.Header)
	respBody, _ := ioutil.ReadAll(resp.Body)
	fmt.Println("response Body:", string(respBody))
	return true, nil
}
