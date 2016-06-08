defmodule Rprel.Build do

  def create(path, build_number, sha) do
    # create build info file
    # build num and sha
    # timestamp
    create_build_info(path, build_number, sha)
  end

  def get_cwd(), do: File.cwd!()

  def create_build_info(path, build_number, sha) do
    date = Timex.format(Timex.Date.today, "%Y%m%d", :strftime) |> elem(1)
    short_sha = String.slice(sha, 0..6)
    build_info_template = ~s"""
    ---
    version: #{date}-#{build_number}-#{short_sha}
    build_number: #{build_number}
    git_commit: #{sha}
    """
    File.write!(Path.join(path, "BUILD-INFO"), build_info_template)
  end
end


