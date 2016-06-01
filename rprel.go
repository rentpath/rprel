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
			Name:   "release",
			Usage:  descRelease,
			Flags:  cmd.ReleaseFlags,
			Action: cmd.Release,
		},
		{
			Name:   "build",
			Usage:  descBuild,
			Flags:  cmd.BuildFlags,
			Action: cmd.Build,
		},
	}

	app.Run(os.Args)
}
