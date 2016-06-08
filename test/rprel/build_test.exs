defmodule Rprel.BuildTest do
  use ExUnit.Case, async: true

  setup_all do
    build_path = Path.relative_to_cwd("test/rprel/test_build")
    build_number = "109"
    sha = "39b38b6a397f665a186788370f97006574d760cf"
    short_sha = String.slice(sha, 0..6)
    date = Timex.format(Timex.Date.today, "%Y%m%d", :strftime) |> elem(1)

    on_exit fn ->
      File.rm(Path.join(build_path, "BUILD-INFO"))
      File.rm(Path.join(build_path, "#{date}-#{build_number}-#{short_sha}.tgz"))
    end

    {:ok, build_path: build_path, build_number: build_number, sha: sha, short_sha: short_sha, date: date}
  end

  test "it creates a build-info file", context do
    Rprel.Build.create([path: context[:build_path], build_number: context[:build_number], commit: context[:sha]], [])
    assert File.exists?(Path.join(context[:build_path], "BUILD-INFO")) == true
  end

  test "it writes the correct build info template", context do
    Rprel.Build.create([path: context[:build_path], build_number: context[:build_number], commit: context[:sha]], [])
   assert File.read(Path.join(context[:build_path], "BUILD-INFO")) == {:ok,
     ~s"""
    ---
    version: #{context[:date]}-#{context[:build_number]}-#{context[:short_sha]}
    build_number: #{context[:build_number]}
    git_commit: #{context[:sha]}
    """}
  end

  test "it archives the directory", context do
    Rprel.Build.create([path: context[:build_path], build_number: context[:build_number], commit: context[:sha]], [])
    assert File.exists?(Path.join(context[:build_path], "#{context[:date]}-#{context[:build_number]}-#{context[:short_sha]}.tgz")) == true
  end

  test "it returns an error with an invalid build path", context do
    build = Rprel.Build.create([path: 'missing-directory', build_number: context[:build_number], commit: context[:sha]], [])
    assert {:error, "You must supply a valid path"} = build
  end
end
