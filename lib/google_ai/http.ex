defmodule GoogleAI.Http do
  @moduledoc """
  HTTP utilities for GoogleAI APIs.
  """
  alias GoogleAI.Model

  @default_receive_timeout 60_000

  @typedoc"""
  The structure of data returned from the post function.
  """
  @type response(body_type) :: {:ok, body_type} | {:error, Exception.t()}

  @type response() :: response(map()) 

  @doc """
  Dispatch a POST request for the given `model` and `action`.
  """
  @spec post(model :: Model.t(), action :: String.t(), json :: map()) :: response()
  def post(%Model{client: %{req: req}}, action, json) when is_binary(action) do
    req =
      req
      |> Req.update(
        path_params: [action: action],
        json: json,
        receive_timeout: @default_receive_timeout
      )

    case Req.post(req) do
      {:ok, %Req.Response{body: data}} -> {:ok, data}
      error -> error
    end
  end
end
