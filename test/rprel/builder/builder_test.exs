defmodule Rprel.BuildTest do
  use ExUnit.Case, async: true

  setup_all do
    build_path = Path.relative_to_cwd("test/rprel/builder/test_build")
    build_number = "100"
    sha = "abc1234"

    Rprel.Build.create(build_path, build_number, sha)

    on_exit fn ->
      File.rm(Path.join(build_path, "BUILD-INFO"))
      # File.rm(Path.join(build_path, "") the build archive??
    end

    {:ok, build_path: build_path}
  end

  test "it creates a build-info file", context  do
    assert File.exists?(Path.join(context[:build_path], "BUILD-INFO")) == true
  end
end
