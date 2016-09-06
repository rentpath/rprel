defmodule Rprel.Messages do
  @moduledoc ~s"""
  A collection of messages to display to the user.
  """

  def invalid_repo_name, do: "You must provide a full repo name."
  def invalid_commit, do: "You must provide a commit sha."
  def invalid_version, do: "You must provide a version number."
  def invalid_files, do: "You must provide at least one valid file."
  def invalid_auth_token, do: "You must provide a valid GitHub authentication token."
  def release_already_exists, do: "A release for that version already exists. Please use a different version."
  def unspecified_error, do: "An unknown error has occurred."
  def repo_not_found, do: "Repository not found"

  def help_text do
    ~s"""
    NAME:
       rprel - Build and create releases
    USAGE:
       rprel [global options] command [command options] [arguments...]
    VERSION:
      #{Rprel.version}
    AUTHOR(S):
      Tyler Long
      Colin Rymer
      Eric Himmelreich
    COMMANDS:
      build
      help
      release
    GLOBAL OPTIONS:
      --help, -h           show help
      --version, -v        print the version
    COPYRIGHT:
      2016
    """
  end

  def build_help_text do
    ~s"""
    NAME:
       rprel build - Builds a release artifact

    USAGE:
       rprel build [command options] [arguments...]

       rprel will run ./script/build ./script/archive if they exist

    OPTIONS:
       --build-number NUMBER
           The NUMBER used by the CI service to identify the build` [$BUILD_NUMBER]
       --commit SHA
           The SHA of the build (default: `git rev-parse --verify HEAD`) [$GIT_COMMIT]
       --path PATH
           The path to tar and gzip (default: current working directory )
    """
  end

  def release_help_text do
    ~s"""
    NAME:
       rprel release - Creates GitHub release and upload artifacts

    USAGE:
       rprel release [command options] [arguments...]

    OPTIONS:
       --token TOKEN, -t TOKEN
           The GitHub authentication TOKEN [$GITHUB_AUTH_TOKEN]
       --commit SHA, -c SHA
           The commit SHA that will be used to create the release [$RELEASE_COMMIT]
       --repo OWNER/REPO, -r OWNER/REPO
           The full repo name, OWNER/REPO, where the release will be created [$RELEASE_REPO]
       --version VERSION, -v VERSION
           The release VERSION [$RELEASE_VERSION]
    """
  end
end
