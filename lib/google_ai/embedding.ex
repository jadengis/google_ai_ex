defmodule GoogleAI.Embedding do
  @moduledoc """
  This module provides an implementation of the Google AI embeddings API.
  The API reference can be found at https://ai.google.dev/tutorials/rest_quickstart#embedding.
  """
  alias GoogleAI.Http
  alias GoogleAI.Model

  @typedoc """
  The structure of a GoogleAI embedding request.
  """
  @type embed_request :: %{
          model: String.t(),
          content: %{
            parts: [
              %{
                text: String.t()
              }
            ]
          }
        }

  @typedoc """
  The structure of a GoogleAI embedding response.

  Has the following format:

  ```elixir
  %{
    "embedding" => %{
      "values" => [
        0.0234234,
        0.3214135,
        0.5645654,
        ...
      ]
    }
  }
  ```
  """
  @type embed_response :: %{
          String.t() => %{
            String.t() => [float()]
          }
        }

  @typedoc """
  The structure of a GoogleAI batch embedding request.
  """
  @type batch_embed_request :: %{
          requests: [embed_request()]
        }

  @typedoc """
  The structure of a GoogleAI batch embedding response.

  Has the following format:

  ```elixir
  %{
    "embeddings" => [%{
      "values" => [
        0.0234234,
        0.3214135,
        0.5645654,
        ...
      ]
    }]
  }
  ```
  """
  @type batch_embed_response :: %{
          String.t() => [%{String.t() => [float()]}]
        }

  @doc """
  Create an embedding using the given `model` for the given `input`.

  ## Arguments

  * `:model` - The `GoogleAI.Model` to use for this request.
  * `:input` - Either a single string or a list of strings. In the case that it is a list,
  the `batchEmbedContents` action will be used.

  ## Returns

  A map containing the fields of the embedding response.

  See https://ai.google.dev/tutorials/rest_quickstart#embedding.

  """
  @spec create(Model.t(), String.t() | [String.t()]) ::
          Http.response(embed_response() | batch_embed_response())
  def create(model, input) when is_binary(input) do
    Http.post(model, "embedContent", build_request(model, input))
  end

  def create(model, inputs) when is_list(inputs) do
    Http.post(model, "batchEmbedContents", build_request(model, inputs))
  end

  @spec build_request(Model.t(), String.t() | [String.t()]) ::
          embed_request() | batch_embed_request()
  defp build_request(%{model: model}, input) when is_binary(input) do
    %{
      model: "model/#{model}",
      content: %{
        parts: [
          %{text: input}
        ]
      }
    }
  end

  defp build_request(model, inputs) when is_list(inputs) do
    %{
      requests: Enum.map(inputs, &build_request(model, &1))
    }
  end
end
