defmodule Rprel.Build do

  def create(path, build_number, sha) do
    # create build info file
    # build num and sha
    # timestamp
    create_build_info(path, build_number, sha)
  end

  def get_cwd(), do: File.cwd!()

  def create_build_info(path, build_number, sha) do
    build_info_template = ~s"""
      ---
      version: 20160607-109-39b38b6
      build_number: 109
      git_commit: 39b38b6a397f665a186788370f97006574d760cf
    """
    File.write!(Path.join(path, "BUILD-INFO"), build_info_template)
  end
end


