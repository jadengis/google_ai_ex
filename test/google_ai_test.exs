defmodule GoogleAITest do
  use ExUnit.Case
  doctest GoogleAI

  alias GoogleAI.Client

  setup do
    Application.put_env(:google_ai, :api_key, "api-key")
    :ok
  end

  describe "client/0" do
    test "will create the default configured API client" do
      assert %Client{req: req} = GoogleAI.client()

      assert %Req.Request{
               options: %{base_url: base_url, params: params, path_params: path_params}
             } = req

      assert base_url ==
               "https://generativelanguage.googleapis.com/:version/models/:model::action"

      assert params == [key: "api-key"]
      assert path_params == [version: "v1beta"]
    end
  end

  describe "client/1" do
    test "allows overriding of underlying client properies" do
      opts = [api_key: "api-key-2", api_version: "v1", base_url: "https://example.com"]
      assert %Client{req: req} = GoogleAI.client(opts)

      assert %Req.Request{
               options: %{base_url: base_url, params: params, path_params: path_params}
             } = req

      assert base_url == "#{opts[:base_url]}/:version/models/:model::action"
      assert params == [key: opts[:api_key]]
      assert path_params == [version: opts[:api_version]]
    end
  end
end
