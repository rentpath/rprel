defmodule Rprel.GithubRelease.HTTPTest do
  use ExUnit.Case, async: true

  @token "iamatoken"
  @commit "abc1234"
  @full_repo_name "rentpath/test-bed"
  @release_id 1234
  @version "v1.1.2"
  @branch "fml/123/fake_branch"
  @normal_release %Rprel.GithubRelease{name: @full_repo_name, version: @version, commit: @commit, branch: @branch}

  def release_upload_url do
    "#{Application.get_env(:rprel, :github_upload_endpoint)}/repos/#{@full_repo_name}/releases/#{@release_id}/assets{?name,label}"
  end

  def release_created_json_resp do
    ~s<{"upload_url": "#{release_upload_url()}", "id": #{@release_id}, "tag_name": "#{@version}", "target_commitish": "#{@commit}", "name": "#{@version}", "body": "", "draft": false, "prerelease": true, "created_at": "2013-02-27T19:35:32Z", "published_at": "2013-02-27T19:35:32Z", "author": {"login": "octocat", "id": 1}, "assets": []}>
  end

  setup do
    api_bypass = Bypass.open()
    upload_bypass = Bypass.open()
    Application.put_env(:rprel, :github_api_endpoint, "http://localhost:#{api_bypass.port}")
    Application.put_env(:rprel, :github_upload_endpoint, "http://localhost:#{upload_bypass.port}")
    {:ok, api_bypass: api_bypass, upload_bypass: upload_bypass}
  end

  test "tokens can be validated", %{api_bypass: api_bypass} do
    Bypass.expect(api_bypass, fn (conn) ->
      assert "/" == conn.request_path
      assert "GET" == conn.method
      assert ["token #{@token}"] == Plug.Conn.get_req_header(conn, "authorization")
      Plug.Conn.resp(conn, 200, ~s<{}>) |> Plug.Conn.put_resp_header("X-OAuth-Scopes", "gist, repo, user")
    end)

    assert Rprel.GithubRelease.HTTP.valid_token?(@token)
  end

  test "tokens without repo scope are invalid", %{api_bypass: api_bypass} do
    Bypass.expect(api_bypass, fn (conn) ->
      assert "/" == conn.request_path
      assert "GET" == conn.method
      assert ["token #{@token}"] == Plug.Conn.get_req_header(conn, "authorization")
      Plug.Conn.resp(conn, 200, ~s<{}>) |> Plug.Conn.put_resp_header("X-Oauth-Scopes", "public_repo, user")
    end)

    refute Rprel.GithubRelease.HTTP.valid_token?(@token)
  end

  test "a release is created", %{api_bypass: api_bypass} do
    Bypass.expect(api_bypass, fn (conn) ->
      assert conn.request_path =~ ~r{^/repos/#{@full_repo_name}/(?:releases|git/tags|git/refs|git/trees)}
      status =
        case conn.method do
          "POST" ->
            if conn.request_path == "/repos/#{@full_repo_name}/releases" do
              assert "POST" == conn.method
              assert ["token #{@token}"] == Plug.Conn.get_req_header(conn, "authorization")
              {:ok, body, _} = Plug.Conn.read_body(conn)
              body_data = Poison.decode!(body)
              assert body_data["tag_name"] == @version
              assert is_nil(body_data["target_commitish"])
              assert body_data["name"] == @version
              assert body_data["prerelease"] == true
              assert body_data["body"] == "branch: #{@branch}"
            end
            201
          _ -> 200
        end

      Plug.Conn.resp(conn, status, release_created_json_resp())
    end)

    assert Rprel.GithubRelease.HTTP.create_release(@normal_release, [], [token: @token]) == {:ok, @release_id}
  end

  test "error is returned if release already exists", %{api_bypass: api_bypass} do
    Bypass.expect(api_bypass, fn (conn) ->
      status =
        case conn.method do
          "POST" ->
            case conn.request_path do
              "/repos/#{@full_repo_name}/releases" -> 422
              _ -> 201
            end
          _ -> 200
        end
      Plug.Conn.resp(conn, status, release_created_json_resp())
    end)

    assert Rprel.GithubRelease.HTTP.create_release(@normal_release, [], [token: @token]) == {:error, :release_already_exists}
  end

  test "error is returned if there is an unknown error creating the release", %{api_bypass: api_bypass} do
    Bypass.expect(api_bypass, fn (conn) ->
      status =
        case conn.method do
          "POST" -> 500
          _ -> 200
        end

      Plug.Conn.resp(conn, status, release_created_json_resp())
    end)

    assert Rprel.GithubRelease.HTTP.create_release(@normal_release, [], [token: @token]) == {:error, :unspecified_error}
  end

  test "error is returned if the repo is missing", %{api_bypass: api_bypass} do
    Bypass.expect(api_bypass, fn (conn) ->
      Plug.Conn.resp(conn, 404, release_created_json_resp())
    end)

    assert Rprel.GithubRelease.HTTP.create_release(@normal_release, [], [token: @token]) == {:error, :repository_not_found}
  end

  test "the files provided are uploaded as assets for a release", %{api_bypass: api_bypass, upload_bypass: upload_bypass} do
    files = [Path.join(__DIR__, "foo.txt"), Path.join(__DIR__, "bar.txt")]

    Bypass.expect(api_bypass, fn (conn) ->
      status =
        case conn.method do
          "POST" -> 201
          _ -> 200
        end
      Plug.Conn.resp(conn, status, release_created_json_resp())
    end)

    parent = self()
    Bypass.expect(upload_bypass, fn (conn) ->
      send(parent, :request_received)
      Plug.Conn.resp(conn, 201, "")
    end)

    assert Rprel.GithubRelease.HTTP.create_release(@normal_release, files, [token: @token]) == {:ok, @release_id}
    Enum.each(files, fn (_) -> assert_receive :request_received end)
  end

  test "tag was created", %{api_bypass: api_bypass, upload_bypass: upload_bypass} do
    files = [Path.join(__DIR__, "foo.txt"), Path.join(__DIR__, "bar.txt")]

    Agent.start_link(fn -> [] end, name: :requested_urls)

    parent = self()
    Bypass.expect(upload_bypass, fn (conn) ->
      assert "POST" == conn.method
      send(parent, :request_received)
      Plug.Conn.resp(conn, 201, "")
    end)

    Bypass.expect(
      api_bypass,
      fn(conn) ->
        status =
          case conn.method do
            "POST" ->
              Agent.update(:requested_urls, &([conn.request_path | &1]))
              201
            _ -> 200
          end

        Plug.Conn.resp(conn, status, release_created_json_resp())
      end
    )

    Rprel.GithubRelease.HTTP.create_release(@normal_release, files, [token: @token])

    assert required_urls() == Agent.get(:requested_urls, &(&1)) |> Enum.reverse()
  end

  test "error is returned if tag already exists", %{api_bypass: api_bypass} do
    Bypass.expect(api_bypass, fn (conn) ->
      status =
        case conn.method do
          "POST" -> 422
          _ -> 200
        end

      Plug.Conn.resp(conn, status, release_created_json_resp())
    end)

    assert Rprel.GithubRelease.HTTP.create_release(@normal_release, [], [token: @token]) == {:error, :tag_already_exists}
  end

  defp required_urls do
    [
      "/repos/rentpath/test-bed/git/tags",
      "/repos/rentpath/test-bed/git/refs",
      "/repos/rentpath/test-bed/releases",
    ]
  end
end
