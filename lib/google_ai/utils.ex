defmodule GoogleAI.Utils do
  @moduledoc """
  Miscellaneous utilities functions.
  """

  @doc """
  Merges any path params already set in the given `req` with the incoming list
  of `path_params`.
  """
  @spec merge_path_params(Req.Request.t(), Keyword.t()) :: Req.t()
  def merge_path_params(%Req.Request{} = req, path_params) do
    Req.update(req, path_params: Keyword.merge(req.options[:path_params], path_params))
  end
end
