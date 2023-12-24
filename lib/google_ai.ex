defmodule GoogleAI do
  @moduledoc """
  `GoogleAI` is an Elixir library that provides a community-maintained client for the Google AI API.
  """
  alias GoogleAI.Client

  @default_api_version "v1beta"
  @default_base_url "https://generativelanguage.googleapis.com"
  @new_opts_schema NimbleOptions.new!(
                     api_key: [
                       type: :string,
                       required: true,
                       doc: "The API key for the Google AI APIs."
                     ],
                     api_version: [
                       type: {:in, ["v1", "v1beta"]},
                       default: @default_api_version,
                       doc:
                         "The version of the API to use. Certain features are only available in later version."
                     ],
                     base_url: [
                       type: :string,
                       default: @default_base_url,
                       doc: "The base URL for the Google AI APIs."
                     ]
                   )

  @doc """
  Create a new GoogleAI client with the given `opts`.

  ## Options

  #{NimbleOptions.docs(@new_opts_schema)}
  ## Examples

    iex> GoogleAI.client(api_key: "asdfasdf")
    %GoogleAI.Client{
      req: Req.new(
        base_url: "https://generativelanguage.googleapis.com", 
        params: [key: "asdfasdf"], 
        path_params: [version: "v1beta"]
      )
    }

    iex> GoogleAI.client(api_key: "asdfasdf", base_url: "https://example.com", api_version: "v1")
    %GoogleAI.Client{
      req: Req.new(
        base_url: "https://example.com", 
        params: [key: "asdfasdf"], 
        path_params: [version: "v1"]
      )
    }

  """
  @spec client(opts :: Keyword.t()) :: Client.t()
  def client(opts \\ []) do
    opts =
      opts
      |> Keyword.put_new(:api_key, get_api_key())
      |> NimbleOptions.validate!(@new_opts_schema)

    req =
      Req.new(
        base_url: opts[:base_url],
        params: [key: opts[:api_key]],
        path_params: [version: opts[:api_version]]
      )

    %Client{req: req}
  end

  @spec get_api_key() :: String.t()
  defp get_api_key do
    Application.get_env(:google_ai, :api_key)
  end
end
