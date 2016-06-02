# rprel
Rprel (arr-pee-rell) is a tool for creating GitHub releases from a build artifact.

**Contents**
- [Installation](#installation)
- [Usage](#usage)
- [Running the Tests](#running-the-tests)
- [Contributing](#contributing)
- [License](#license)

# Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add rprel to your list of dependencies in `mix.exs`:

        def deps do
          [{:rprel, "~> 0.0.1"}]
        end

  2. Ensure rprel is started before your application:

        def application do
          [applications: [:rprel]]
        end

# Building from source

*Rprel* is built in [Elixir](http://elixir-lang.org/) so you will need `Erlang && Elixir`
installed to use/modify it.

You can find instructions on installation [here](http://elixir-lang.org/getting-started/introduction.html).


Once everything is installed, you can run:
```
$ git clone git@github.com:rentpath/rprel.git
$ cd rprel
$ mix escript.build
```

This builds the executable.

# Usage

`Rprel` will publish a release to GitHub. This takes advantage of the
[GitHub Release API](https://developer.github.com/v3/repos/releases/). In particular,
it uses [Create a Release](https://developer.github.com/v3/repos/releases/#create-a-release)
and [Upload a release asset](https://developer.github.com/v3/repos/releases/#upload-a-release-asset).

To use `Rprel` and build a release simply run:
` $ rprel --version="<version_number>" --repo="<repo_owner/repo_name>" build.tgz`

As you can see, there are two required flags:

- Version: This is the version to release.

- Repo: The repo where the release will be created.

For example:
```
 $ rprel --version="1.2.3" --repo="rentpath/rpenv" build.tgz
 ```
will create release `1.2.3` of `rpenv` and will upload `build.tgz` as a release artifact.


# Running the tests
To run all the tests using `make`:
` $ make`

All the tests can also be run with:
` $ mix test `

# Contributing
-  Follow the instructions above to install `elixir` and get the repo running.
-  If you modify code, add a corresponding test (if applicable).
-  Create a Pull Request (please squash to one concise commit).
-  Thanks!

# License
[MIT](https://github.com/rentpath/rprel/blob/master/LICENSE)
