package cmd

import (
	"fmt"
	"github.com/urfave/cli"
	"os"
	"os/exec"
	"path/filepath"
	"time"
)

const (
	BuildCmd        = "command"
	BuildArchiveCmd = "archive-command"
	BuildNumber     = "build-number"
	BuildCommit     = "commit"
)

var (
	buildCmd        string
	buildArchiveCmd string
	buildContext    *cli.Context
	buildInfoFile   *os.File
	err             error
)

func Build(ctx *cli.Context) error {
	if err := validateArgs(ctx); err != nil {
		return err
	}

	buildCmd = ctx.String(BuildCmd)
	buildArchiveCmd = ctx.String(BuildArchiveCmd)

	//TODO:build phase

	if buildInfoFile, err = os.Create("BUILD-INFO"); err != nil {
		return err
	}
	defer os.Remove(buildInfoFile.Name())

	if _, err = buildInfoFile.WriteString(buildInfoFileContents()); err != nil {
		return err
	}

	//TODO handle provided archive cmd
	if err = generateArchive(ctx.Args()[0]); err != nil {
		fmt.Println(err.Error())
		return err
	}

	return nil
}

func generateArchive(source string) error {

	filename := filepath.Base(source)
	target, _ := os.Getwd()

	tarball := filename + ".tgz"
	tmpTarPath := os.TempDir() + tarball

	cmdName := "tar"
	cmdArgs := []string{"--dereference", "-czf", tmpTarPath, "*", ".??*"}
	command := exec.Command(cmdName, cmdArgs...)
	command.Dir = source
	if err := command.Run(); err != nil {
		return err
	}

	if err := os.Rename(tmpTarPath, target+tarball); err != nil {
		return err
	}

	return nil
}

func gitHeadSha(dir string) string {
	cmdName := "git"
	cmdArgs := []string{"rev-parse", "--verify", "HEAD"}
	command := exec.Command(cmdName, cmdArgs...)
	command.Dir = dir
	cmdOut, err := command.Output()
	if err != nil {
		return ""
	}
	return string(cmdOut)
}

func buildInfoFileContents() string {
	return ("---\n" +
		"version: " + version() + "\n" +
		"build_number: " + buildNumber() + "\n" +
		"git_commit: " + buildCommit() + "\n")
}

func version() string {
	return buildDate() + "-" + buildNumber() + "-" + buildCommit()[:7]
}

func buildDate() string {
	return time.Now().Format("20060102")
}

func buildNumber() string {
	return buildContext.String(BuildNumber)
}

func buildCommit() string {
	if buildContext.String("BuildCommit") != "" {
		return buildContext.String(BuildCommit)
	} else {
		return gitHeadSha(buildContext.Args()[0])
	}
}

func validateArgs(ctx *cli.Context) error {
	if ctx.NArg() != 1 {
		return cli.NewExitError("Error: The artifact source must be provided", 1)
	}
	if ctx.String(BuildNumber) == "" {
		return cli.NewExitError("Error: The build number must be provided", 1)
	}
	if len(ctx.String(BuildCommit)) < 7 && gitHeadSha(ctx.Args()[0]) == "" {
		return cli.NewExitError("Error: A build commit sha of at least 7 characters must be provided", 1)
	}

	return nil
}
