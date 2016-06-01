package cmd

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
)

const (
	ReleaseToken     = "token"
	ReleaseRepo      = "repo"
	ReleaseName      = "name"
	ReleaseCommitish = "commitish"
)

type ReleaseInfo struct {
	Name      string
	Repo      string
	Commitish string
	Files     []string
	Id        int    `json:"id"`
	Url       string `json:"url"`
	UploadUrl string `json:"upload_url"`
}

var AuthToken string

func Release(ctx *cli.Context) error {
	if ctx.NArg() == 0 {
		return cli.NewExitError("Error: at least one release artifact must be provided", 1)
	}
	if ctx.String(ReleaseToken) == "" {
		return cli.NewExitError("Error: you must provide a GitHub auth token", 1)
	}
	if ctx.String(ReleaseRepo) == "" {
		return cli.NewExitError("Error: you must provide the full repo name", 1)
	}
	if ctx.String(ReleaseName) == "" {
		return cli.NewExitError("Error: you must provide the release name", 1)
	}

	AuthToken = ctx.String(ReleaseToken)

	release := ReleaseInfo{
		Name:      ctx.String(ReleaseName),
		Repo:      ctx.String(ReleaseRepo),
		Commitish: ctx.String(ReleaseCommitish),
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

func generateRelease(release *ReleaseInfo) (err error) {
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

func uploadReleaseAssets(release *ReleaseInfo) error {
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
