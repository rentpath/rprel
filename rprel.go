package main

import (
	"github.com/rentpath/rprel/cmd"
	"github.com/urfave/cli"
	"os"
	"time"
)

const (
	descName    = "rprel"
	descUsage   = "Build and create releases"
	descRelease = "Creates GitHub release and upload artifacts"
	descBuild   = "Builds a release artifact"
)

var (
	Version   string
	BuildTime string
	Src       string
)

func main() {

	app := cli.NewApp()
	app.Name = descName
	app.Usage = descUsage
	app.Version = Version
	app.Compiled, _ = time.Parse("2006-01-02T15:04:05-0700", BuildTime)
	app.Commands = []cli.Command{
		{
			Name:  "release",
			Usage: descRelease,
			Flags: []cli.Flag{
				cli.StringFlag{
					Name:   cmd.ReleaseToken + ", t",
					Usage:  "The GitHub authentication `TOKEN`",
					EnvVar: "GITHUB_AUTH_TOKEN",
				},
				cli.StringFlag{
					Name:   cmd.ReleaseCommitish + ", c",
					Value:  "master",
					Usage:  "The `COMMITISH` (sha, branch, etc.) that will be used to create the release",
					EnvVar: "RELEASE_COMMITISH",
				},
				cli.StringFlag{
					Name:   cmd.ReleaseRepo + ", r",
					Usage:  "The full repo name, `OWNER/REPO`, where the release will be created",
					EnvVar: "FULL_REPO_NAME",
				},
				cli.StringFlag{
					Name:   cmd.ReleaseName + ", n",
					Usage:  "The release `NAME` (typically the version being released)",
					EnvVar: "RELEASE_NAME",
				},
			},
			Action: cmd.Release,
		},
		{
			Name:  "build",
			Usage: descBuild,
			Flags: []cli.Flag{
				cli.StringFlag{
					Name:  cmd.BuildCmd + ", c",
					Usage: "The `CMD` to run during the building of the artifact. If no command is provided and a Makefile is present, rprel will run `make build` if `build` is a valid Make target, otherwise falling back to just `make`. If no `CMD` is provided and there is no Makefile, nothing will be done during the build phase.",
				},
				cli.StringFlag{
					Name:  cmd.BuildArchiveCmd + ", a",
					Usage: "The `ARCHIVE_CMD` to run during the arifact packaging phase. If no command is provided and a Makefile exists with an `archive` target, `make archive` will be run, otherwise, the source provided will be packaged into a gzipped tarball.",
				},
			},
			Action: cmd.Build,
		},
	}

	app.Run(os.Args)
}
