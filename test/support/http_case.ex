defmodule GoogleAI.HttpCase do
  @moduledoc """
  This module desings the setup for tests that require a mock HTTP server.
  """
  use ExUnit.CaseTemplate

  using do
    quote do
      import GoogleAI.HttpCase
    end
  end

  setup do
    api_key = Application.get_env(:google_ai, :api_key) || "asdfasdf"
    bypass = Bypass.open()
    client = GoogleAI.client(base_url: "http://localhost:#{bypass.port}", api_key: api_key)
    [bypass: bypass, client: client, api_key: api_key]
  end
end
