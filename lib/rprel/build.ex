defmodule Rprel.Build do

  def create(path, build_number, sha) do
    date = Timex.format(Timex.Date.today, "%Y%m%d", :strftime) |> elem(1)
    short_sha = String.slice(sha, 0..6)
    version_string =  "#{date}-#{build_number}-#{short_sha}"
    create_build_info(path, build_number, sha, version_string)
    archive(path, version_string)
  end

  def create_build_info(path, build_number, sha, version_string) do
    build_info_template = ~s"""
    ---
    version: #{version_string}
    build_number: #{build_number}
    git_commit: #{sha}
    """
    File.write!(Path.join(path, "BUILD-INFO"), build_info_template)
  end

  def archive(path, version_string) do
    archive_path = Path.join(System.tmp_dir(), "#{version_string}.tgz")
    System.cmd("tar", ["--dereference", "-czf", archive_path, path])
    System.cmd("mv", [archive_path, path])
  end
end


