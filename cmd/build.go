package cmd

import (
	"archive/tar"
	"fmt"
	"github.com/urfave/cli"
	"io"
	"io/ioutil"
	"os"
	"path/filepath"
	"strings"
	"time"
)

const (
	BuildCmd        = "command"
	BuildArchiveCmd = "archive-command"
)

type Header struct {
	Comment string    // comment
	Extra   []byte    // "extra data"
	ModTime time.Time // modification time
	Name    string    // file name
	OS      byte      // operating system type
}

var (
	buildCmd   string
	archiveCmd string
)

func Build(ctx *cli.Context) error {
	if ctx.NArg() != 1 {
		return cli.NewExitError("Error: The artifact source must be provided", 1)
	}

	buildCmd = ctx.String(BuildCmd)
	archiveCmd = ctx.String(BuildArchiveCmd)
	source := ctx.Args()[0]

	//TODO:build phase
	buildInfoFile, err := os.Create("BUILD-INFO")
	if err != nil {
		return err
	}

	defer os.Remove(buildInfoFile.Name())

	buildDate := time.Now().Format("20060102")
	buildNumber := "123"
	buildCommit := "abc123"

	n, err := buildInfoFile.WriteString("---\nversion: " + buildDate + "-" + buildNumber + "-" + buildCommit + "\nbuild_number: " + buildNumber + "\ngit_commit: " + buildCommit + "\n")
	fmt.Println("wrote %d bytes", n)

	//TODO handle provided archive cmd
	cwd, _ := os.Getwd()
	err = generateArchive(source, cwd)

	if err != nil {
		fmt.Println(err.Error())
	}

	return err
}

func generateArchive(source, target string) error {
	filename := filepath.Base(source)
	tarfile, err := ioutil.TempFile("", filename)
	if err != nil {
		return err
	}
	fmt.Println(tarfile.Name())
	defer os.Remove(tarfile.Name())

	tarball := tar.NewWriter(tarfile)
	defer tarball.Close()

	info, err := os.Stat(source)
	if err != nil {
		return nil
	}

	var baseDir string
	if info.IsDir() {
		baseDir = filepath.Base(source)
	}

	err = filepath.Walk(source, tarWalk(baseDir, source, tarball))

	if err != nil {
		fmt.Println(err.Error())
		return err
	}

	dest := filepath.Join(target, fmt.Sprintf("%s.tar", filename))
	if err := os.Link(tarfile.Name(), dest); err != nil {
		return err
	}

	return nil
}

func tarWalk(baseDir string, source string, tarball *tar.Writer) filepath.WalkFunc {
	return func(path string, info os.FileInfo, err error) error {
		if err != nil {
			return err
		}
		header, err := tar.FileInfoHeader(info, info.Name())
		if err != nil {
			return err
		}

		if baseDir != "" {
			header.Name = filepath.Join(baseDir, strings.TrimPrefix(path, source))
		}

		if err := tarball.WriteHeader(header); err != nil {
			return err
		}

		if info.IsDir() {
			return nil
		}

		file, err := os.Open(path)
		if err != nil {
			return err
		}
		defer file.Close()
		_, err = io.Copy(tarball, file)
		return err
	}
}
