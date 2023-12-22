defmodule GoogleAI.Client do
  @moduledoc """
  The API client underlying calls to Google AI APIs.
  """
  @enforce_keys [:req]
  defstruct req: nil

  @typedoc """
  The type of the Google AI client.
  """
  @type t :: %__MODULE__{
          req: Req.Request.t()
        }
end
