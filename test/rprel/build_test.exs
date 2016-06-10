defmodule Rprel.BuildTest do
  use ExUnit.Case, async: true
  import ExUnit.CaptureIO

  setup_all do
    build_path = Path.relative_to_cwd("test/rprel/test_build")
    build_archive_path = Path.relative_to_cwd("test/rprel/test_build_archive")
    fail_archive_path = Path.relative_to_cwd("test/rprel/test_fail_archive")
    fail_to_build_path = Path.relative_to_cwd("test/rprel/test_build_failure")
    missing_buildsh_path = Path.relative_to_cwd("test/rprel/test_no_buildsh")
    build_number = "109"
    sha = "39b38b6a397f665a186788370f97006574d760cf"
    short_sha = String.slice(sha, 0..6)
    date = Timex.format(Timex.Date.today, "%Y%m%d", :strftime) |> elem(1)

    on_exit fn ->
      File.rm(Path.join(build_path, "BUILD-INFO"))
      File.rm(Path.join(build_path, "#{date}-#{build_number}-#{short_sha}.tgz"))
    end

    {:ok, build_path: build_path, build_number: build_number, sha: sha, short_sha: short_sha, date: date, fail_to_build_path: fail_to_build_path, missing_buildsh_path: missing_buildsh_path, build_archive_path: build_archive_path, fail_archive_path: fail_archive_path}
  end

  test "it creates a build-info file", context do
    capture_io(fn ->
      Rprel.Build.create([path: context[:build_path], build_number: context[:build_number], commit: context[:sha]])
    end)

    assert File.exists?(Path.join(context[:build_path], "BUILD-INFO")) == true
  end

  test "it writes the correct build info template", context do
    capture_io(fn ->
      Rprel.Build.create([path: context[:build_path], build_number: context[:build_number], commit: context[:sha]])
    end)

    assert File.read(Path.join(context[:build_path], "BUILD-INFO")) == {:ok,
     ~s"""
    ---
    version: #{context[:date]}-#{context[:build_number]}-#{context[:short_sha]}
    build_number: #{context[:build_number]}
    git_commit: #{context[:sha]}
    """}
  end

  test "it archives the directory", context do
    message = capture_io(fn ->
      Rprel.Build.create([path: context[:build_path], build_number: context[:build_number], commit: context[:sha]])
    end)

    assert String.contains?(message,"created #{context[:date]}-#{context[:build_number]}-#{context[:short_sha]}.tgz\n")
    assert File.exists?(Path.join(context[:build_path], "#{context[:date]}-#{context[:build_number]}-#{context[:short_sha]}.tgz")) == true
  end

  test "it runs the archive.sh by default", context do
    message = capture_io(fn ->
      Rprel.Build.create([path: context[:build_archive_path], build_number: context[:build_number], commit: context[:sha]])
    end)

    assert String.contains?(message, "running archive.sh")
  end

  test "it stops and prints an error when archive.sh fails", context do
    message = capture_io(fn ->
      Rprel.Build.create([path: context[:fail_archive_path], build_number: context[:build_number], commit: context[:sha]])
    end)

    refute File.exists?(Path.join(context[:fail_archive_path], 'archive.tgz'))
    assert String.contains?(message, "archive.sh returned an error")
  end

  test "it returns an error with an invalid build path", context do
    build = Rprel.Build.create([path: 'missing-directory', build_number: context[:build_number], commit: context[:sha]])
    assert {:error, "You must supply a valid path"} = build
  end

  test "it runs the build.sh by default", context do
    error_message = capture_io(fn ->
      assert Rprel.Build.create([path: context[:build_path], build_number: context[:build_number], commit: context[:sha]]) == {:ok, nil}
    end)

    refute String.contains?(error_message, "build.sh not found, skipping build step")
  end

  test "it returns an error if the build.sh does not work", context do
    error_message = capture_io(fn ->
      Rprel.Build.create([path: context[:fail_to_build_path], build_number: context[:build_number], commit: context[:sha]])
    end)

    assert String.contains?(error_message, "build.sh returned an error")
  end

  test "it returns a warning if the build.sh is missing", context do
    error_message = capture_io(fn ->
      Rprel.Build.create([path: context[:missing_buildsh_path], build_number: context[:build_number], commit: context[:sha]])
    end)

    assert String.contains?(error_message, "build.sh not found, skipping build step")
  end
end
