package cmd

import (
	"github.com/urfave/cli"
)

var BuildFlags = []cli.Flag{
	cli.StringFlag{
		Name:  BuildCmd + ", c",
		Usage: "The `CMD` to run during the building of the artifact. If no command is provided and a Makefile is present, rprel will run `make build` if `build` is a valid Make target, otherwise falling back to just `make`. If no `CMD` is provided and there is no Makefile, nothing will be done during the build phase.",
	},
	cli.StringFlag{
		Name:  BuildArchiveCmd + ", a",
		Usage: "The `ARCHIVE_CMD` to run during the arifact packaging phase. If no command is provided and a Makefile exists with an `archive` target, `make archive` will be run, otherwise, the source provided will be packaged into a gzipped tarball.",
	},
	cli.StringFlag{
		Name:   BuildNumber,
		Usage:  "The `NUMBER` used by the CI service to identify the build`",
		EnvVar: "BUILD_NUMBER",
	},
	cli.StringFlag{
		Name:   BuildCommit,
		Usage:  "The `SHA` of the build (default: `git rev-parse --verify HEAD`)",
		EnvVar: "GIT_COMMIT",
	},
}

var ReleaseFlags = []cli.Flag{
	cli.StringFlag{
		Name:   ReleaseToken + ", t",
		Usage:  "The GitHub authentication `TOKEN`",
		EnvVar: "GITHUB_AUTH_TOKEN",
	},
	cli.StringFlag{
		Name:   ReleaseCommitish + ", c",
		Value:  "master",
		Usage:  "The `COMMITISH` (sha, branch, etc.) that will be used to create the release",
		EnvVar: "RELEASE_COMMITISH",
	},
	cli.StringFlag{
		Name:   ReleaseRepo + ", r",
		Usage:  "The full repo name, `OWNER/REPO`, where the release will be created",
		EnvVar: "FULL_REPO_NAME",
	},
	cli.StringFlag{
		Name:   ReleaseName + ", n",
		Usage:  "The release `NAME` (typically the version being released)",
		EnvVar: "RELEASE_NAME",
	},
}
