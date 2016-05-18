# rprel
Rprel (arr-pee-rell) is a tool for creating GitHub releases from a build artifact.

**Contents**
- [Downloading the Binary](#downloading-the-binary)
- [Building from Source](#building-from-source)
- [Usage](#usage)
- [Running the Tests](#running-the-tests)
- [Contributing](#contributing)
- [License](#license)

# Downloading the Binary

To install, first download the [latest version](https://github.com/rentpath/rprel/releases/latest) from the [releases page](https://github.com/rentpath/rprel/releases), then make sure it has executable permissions and place it in `$PATH`. If you prefer
to install from source, see the instructions below.

# Building from source

*Rprel* is built in [Go](https://golang.org/) so you will need `golang`
installed to use/modify it.

You can find instructions on installation [here](https://golang.org/doc/install).

Make sure that `GO` is in your path (`bash_profile`, `zsh`, `bashrc`, etc):
```
export PATH=~/go/bin:$PATH
export GOPATH=$HOME/go
```
Once `go` is installed, make sure you `source` or `exec` your shell

```
$ source ~/.bashrc
```

Once `go` is installed, and `$PATH` is updated you can run:
```
$ git clone git@github.com:rentpath/rprel.git
$ cd rprel
$ make build
```

# Usage

`Rprel` will publish a release to GitHub. This takes advantage of the
[GitHub Release API](https://developer.github.com/v3/repos/releases/). In particular,
it uses [Create a Release](https://developer.github.com/v3/repos/releases/#create-a-release)
and [Upload a release asset](https://developer.github.com/v3/repos/releases/#upload-a-release-asset).

To use `Rprel` and build a release simply run:
` $ rprel --version="<version_number>" --repo="<repo_name>" build.tgz`

As you can see, there are two required flags:

- Version: This is the version to release.

- Repo: The repo to build the artifact from.

For example:
```
 $ rprel --version="1.2.3" --repo="ag" build.tgz
 ```
will build version `1.2.3` of `ApartmentGuide`.


# Running the tests

To run the tests:
` $ make`

# Contributing

-  Follow the instructions above to install `go` and get the repo running.
-  If you modify code, add a corresponding test (if applicable).
-  Create a Pull Request (please squash to one concise commit).
-  Thanks!

# License

[MIT](https://github.com/rentpath/rprel/blob/master/LICENSE)
