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
          },
          taskType: String.t()
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

  @embed_content_schema NimbleOptions.new!(
                          task_type: [
                            type:
                              {:in,
                               [
                                 :retrieval_query,
                                 :retrieval_document,
                                 :semantic_similarity,
                                 :classification,
                                 :clustering
                               ]},
                            doc: "The type of task to perform with the input."
                          ]
                        )

  @doc """
  Create an embedding using the given `model` for the given `input`.

  ## Arguments

  * `:model` - The `GoogleAI.Model` to use for this request.
  * `:input` - Either a single string or a list of strings. In the case that it is a list,
  the `batchEmbedContents` action will be used.
  * `:opts` - options to include with the request.  

  ## Options

  #{NimbleOptions.docs(@embed_content_schema)}
  ## Returns

  A map containing the fields of the embedding response.

  See https://ai.google.dev/tutorials/rest_quickstart#embedding.

  """
  @spec create(Model.t(), String.t() | [String.t()], Keyword.t()) ::
          Http.response(embed_response() | batch_embed_response())
  def create(model, input, opts \\ []) do
    opts = NimbleOptions.validate!(opts, @embed_content_schema)
    Http.post(model, get_action(input), build_request(model, input, opts))
  end

  @spec get_action(String.t()) :: String.t()
  defp get_action(inputs) when is_binary(inputs), do: "embedContent"
  defp get_action(inputs) when is_list(inputs), do: "batchEmbedContents"

  @spec build_request(Model.t(), String.t() | [String.t()], Keyword.t()) ::
          embed_request() | batch_embed_request()
  defp build_request(%{model: model}, input, opts) when is_binary(input) do
    %{
      model: "models/#{model}",
      content: %{
        parts: [
          %{text: input}
        ]
      }
    }
    |> maybe_put_task_type(opts[:task_type])
  end

  defp build_request(model, inputs, opts) when is_list(inputs) do
    %{
      requests: Enum.map(inputs, &build_request(model, &1, opts))
    }
  end

  defp maybe_put_task_type(map, task_type) do
    if task_type do
      Map.put(map, :taskType, map_task_type(task_type))
    else
      map
    end
  end

  @spec map_task_type(atom() | nil) :: String.t() | nil
  defp map_task_type(type) do
    case type do
      :retrieval_query -> "RETRIEVAL_QUERY"
      :retrieval_document -> "RETRIEVAL_DOCUMENT"
      :semantic_similarity -> "SEMANTIC_SIMILARITY"
      :classification -> "CLASSIFICATION"
      :clustering -> "CLUSTERING"
      _ -> nil
    end
  end
end
