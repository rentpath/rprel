# rprel

[![Build Status](https://travis-ci.org/rentpath/rprel.svg?branch=master)](https://travis-ci.org/rentpath/rprel)

Rprel (arr-pee-rell) is a tool for creating GitHub releases from a build artifact.

**Contents**
- [Building the Executable](#building-the-executable)
- [Usage](#usage)
- [Running the Tests](#running-the-tests)
- [Running Credo](#running-credo)
- [Contributing](#contributing)
- [License](#license)


# Building the exectuable:

*Rprel* is built in [Elixir](http://elixir-lang.org/) so you will need `Erlang && Elixir`
installed to use/modify it.

You can find instructions on installation [here](http://elixir-lang.org/getting-started/introduction.html).

We use [exenv](https://github.com/mururu/exenv) for managing the Elixir version.


Once everything is installed, you can run:
```
$ git clone git@github.com:rentpath/rprel.git
$ cd rprel
$ mix deps.get
$ mix escript.build
```

This builds the executable, which is accessible like so:
```
$ rprel
```

# Usage

`Rprel` will publish a release to GitHub. This takes advantage of the
[GitHub Release API](https://developer.github.com/v3/repos/releases/). In particular,
it uses [Create a Release](https://developer.github.com/v3/repos/releases/#create-a-release)
and [Upload a release asset](https://developer.github.com/v3/repos/releases/#upload-a-release-asset).

You can see information about `rprel` by running:
```
$ rprel --help
```

To access information that is `build` specific:
```
$ rprel build --help
```

To access information that is `release` specific:
```
$ rprel release --help
```

All `--help` commands are aliased to `-h`, so:

`$ rprel -h`
is equivalant to
`$ rprel --help`


To use `Rprel` and create a build simply run:
```bash
cd source_code/
rprel build --commit master --build-number 100
```

As you can see, there are 2 required flags:

- Commit: The current commit sha of the repository you are building.

- Build Number: The build number from your CI test run.

An example build:

```bash
cd source_code/
rprel build --commit 09d5671224b03969c629d9265417bc82c4aac48f --build-number 100
```

This will create a tarball of the directory `source_code/` named `20160613-100-09d5671.tgz` containing a BUILD-INFO file in the following format:

```
---
version: 20160613-100-09d5671
build_number: 100
git_commit: 09d5671224b03969c629d9265417bc82c4aac48f
```


To use `Rprel` and create a release simply run:

` $ rprel release  --repo "repo_owner/repo_name" --version "<version_name>" --commit "<branch_or_sha>" --token "AUTH_TOKEN" [list_of_files]`

As you can see, there are 4 required flags:

- Repo: The repo where the release will be created.

- Version: This is the version to release.

- Commit: The branch or `sha` to be released.

- Token: A GitHub Auth Token [See Here for information about auth tokens](https://help.github.com/articles/creating-an-access-token-for-command-line-use/).  While the GitHub auth token can be set using the `--token` flag, we strongly recommend setting the token in the `GITHUB_AUTH_TOKEN` environment variable to keep the token from appearing in your command history.

- Files: This is a file or list of files to be released, `foo.txt bar.txt` for example, or the tarball created by the `rprel build` step `20160613-100-09d5671.tgz`


An example release:
```
 $ rprel release --repo rentpath/test-bed --version "V1.0.0" --commit "master" 20160613-100-09d5671.tgz
 ```
will create release `V1.0.0` of `rpenv` and will upload `20160613-100-09d5671.tgz`` as a release artifact.

# Running the tests:

All the tests can also be run with:

` $ mix test `

To run the tests on save, run:
` $ mix test.watch`


# Running Credo
`Rprel` uses [Credo](https://github.com/rrrene/credo) for code analysis. To run:
```
$ mix credo --strict
```
Please execute this before commiting, and address issues that `credo` finds.

# Contributing
-  Follow the instructions above to install `elixir` and get the repo running.
-  If you modify code, add a corresponding test (if applicable).
-  Create a Pull Request (please squash to one concise commit).
-  Thanks!

# License
[MIT](https://github.com/rentpath/rprel/blob/master/LICENSE)
