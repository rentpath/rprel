defmodule Rprel.Build.CreateGzip do

  def get_cwd(), do: File.cwd!()

  def create_tmp_dir() do
    File.rm_rf("tmp")
    File.mkdir!("tmp")
  end

  def copy_dir_to_tmp() do
    File.cp!(get_cwd, create_tmp_dir)
  end
end

