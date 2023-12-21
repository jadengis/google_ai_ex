defmodule GoogleAI.Http do
  @moduledoc """
  HTTP utilities for GoogleAI APIs.
  """
  alias GoogleAI.Model
  alias GoogleAI.Utils

  @default_receive_timeout 60_000

  @typedoc """
  The structure of data returned from the post function.
  """
  @type response(body_type) :: {:ok, body_type} | {:error, Exception.t()}

  @type response() :: response(map())

  @doc """
  Dispatch a GET request with the given `client`.

  ## Arguments

  * `:client` - A `Req.Request` configured to dispatch as a GET request.

  ## Returns

  A tuple indicating success or failure and containing the request body.

  """
  @spec get(client :: Req.Request.t()) :: response()
  def get(%Req.Request{} = req) do
    case Req.get(req) do
      {:ok, %Req.Response{body: data}} -> {:ok, data}
      error -> error
    end
  end

  @doc """
  Dispatch a POST request for the given `model` and `action`.

  ## Arguments

  * `:model` - A `GoogleAI.Model` to use for the request.
  * `:action` - The action to dispatch for the model.
  * `:json` - The JSON body to send with the request.

  ## Returns

  A tuple indicating success or failure and containing the request body.

  """
  @spec post(model :: Model.t(), action :: String.t(), json :: map()) :: response()
  def post(%Model{client: %{req: req}}, action, json) when is_binary(action) do
    req =
      req
      |> Utils.merge_path_params(action: action)
      |> Req.update(
        json: json,
        receive_timeout: @default_receive_timeout
      )

    case Req.post(req) do
      {:ok, %Req.Response{body: data}} -> {:ok, data}
      error -> error
    end
  end
end
