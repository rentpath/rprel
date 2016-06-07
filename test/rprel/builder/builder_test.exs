defmodule Rprel.BuildTest do
  use ExUnit.Case, async: true

  test "it finds the cwd" do
    assert Rprel.Build.CreateGzip.get_cwd() == File.cwd!()
    refute Rprel.Build.CreateGzip.get_cwd() == {:error, ""}
  end

  test "it creates a temp dir to write to" do
    assert Rprel.Build.CreateGzip.create_tmp_dir() == :ok
  end

  test "it copies the dir over" do
    assert Rprel.Build.CreateGzip.copy_dir_to_tmp() == ""
  end

  test "it has the correct permissions" do
  end

  test "it creates a build-info file" do
  end
end
