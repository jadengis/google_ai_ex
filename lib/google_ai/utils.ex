defmodule GoogleAI.Utils do
  @moduledoc """
  Miscellaneous utilities functions.
  """

  @doc """
  Merges any path params already set in the given `req` with the incoming list
  of `path_params`.
  """
  @spec merge_path_params(Req.Request.t(), Keyword.t()) :: Req.Request.t()
  def merge_path_params(%Req.Request{} = req, path_params) do
    Req.update(req, path_params: Keyword.merge(req.options[:path_params], path_params))
  end

  @doc """
  Camelize all keys in the given map or keyword-list.

  ## Arguments

  * `:input` - A map or keyword-list to camelize.

  ## Returns

  A string-keyed map with camelized keys.

  ## Examples

    iex> GoogleAI.Utils.camelize_keys(%{"foo_bar" => "baz"})
    %{"fooBar" => "baz"}

    iex> GoogleAI.Utils.camelize_keys(foo_bar: "baz")
    %{"fooBar" => "baz"}

  """
  @spec camelize_keys(map() | Keyword.t()) :: map()
  def camelize_keys(input) when is_map(input) or is_list(input) do
    input
    |> Stream.map(fn {key, value} ->
      <<first::binary-size(1), rest::binary>> = to_string(key) |> Macro.camelize()
      key = String.downcase(first) <> rest
      {key, value}
    end)
    |> Enum.into(%{})
  end
end
