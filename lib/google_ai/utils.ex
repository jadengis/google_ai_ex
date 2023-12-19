defmodule GoogleAI.Utils do
  @moduledoc """
  Miscellaneous utilities functions.
  """

  @spec merge_path_params(Req.Request.t(), Keyword.t()) :: Req.t()
  def merge_path_params(%Req.Request{} = req, path_params) do
    Req.update(req, path_params: Keyword.merge(req.options[:path_params], path_params))
  end
end
