defmodule GoogleAI.Content do
  @moduledoc """
  The module provides an implementation of the Google AI content generation APIs.
  The API reference can be found at https://ai.google.dev/tutorials/rest_quickstart.
  """
  alias GoogleAI.Http
  alias GoogleAI.Model
  alias GoogleAI.Utils

  @typedoc """
  The message role assigned to the content.
  """
  @type role :: :user | :model

  @typedoc """
  Options that allow the configuration of the model output.
  """
  @type generation_config :: %{
          optional(:candidateCount) => integer(),
          optional(:stopSequences) => [String.t()],
          optional(:maxOutputTokens) => integer(),
          optional(:temperature) => float(),
          optional(:topP) => float(),
          optional(:topK) => float()
        }

  @typedoc """
  A list of safety settings for the model.
  """
  @type safety_settings :: [
          %{
            category: String.t(),
            threshold: String.t()
          }
        ]

  @typedoc """
  The structure of a Google content generation request.
  """
  @type generation_request :: %{
          :contents => [
            %{
              optional(:role) => role(),
              :parts => [
                %{
                  text: String.t()
                }
              ]
            }
          ],
          optional(:generationConfig) => generation_config(),
          optional(:safetySettings) => safety_settings()
        }

  @typedoc """
  The structure of a GoogleAI embedding response.

  Has the following format:

  ```elixir
  %{
    "candidates" => [
      %{
        "content" => %{
          "role" => "model",
          "parts" => [
            %{
              "text" => "This is a test."
            }
          ]
        },
        "finishReason" => "STOP",
        "index" => 0,
      }
    ]
  }
  ```
  """
  @type generation_response :: %{
          String.t() => [
            %{
              String.t() => %{
                String.t() => String.t(),
                String.t() => [
                  %{
                    String.t() => String.t()
                  }
                ]
              },
              String.t() => String.t()
            }
          ]
        }

  @request_opts_schema NimbleOptions.new!(
                         generation_config: [
                           type: :non_empty_keyword_list,
                           doc: "The generation configuration to use for this request.",
                           keys: [
                             candidate_count: [type: :integer],
                             stop_sequences: [type: {:list, :string}],
                             max_output_tokens: [type: :integer],
                             temperature: [type: :float],
                             top_p: [type: :float],
                             top_k: [type: :float]
                           ]
                         ],
                         safety_settings: [
                           type: {:list, :non_empty_keyword_list},
                           doc: "The safety settings to use for this request."
                         ]
                       )

  @doc """
  Generates a model completion for a given prompt or conversation.

  ## Arguments

  * `:model` - The `GoogleAI.Model` to use for this request.
  * `:prompt` - The text-only input or multi-turn conversation to send as a prompt
  to the AI model.
  * `:opts` - A keyword list of options that can be used to configure the request.

  ## Returns

  A map containing the fields of the content generation response.

  See https://ai.google.dev/tutorials/rest_quickstart#text-only_input.
  """
  @spec generate(Model.t(), String.t(), Keyword.t()) :: Http.response(generation_response())
  def generate(model, prompt, opts \\ []) do
    opts = NimbleOptions.validate!(opts, @request_opts_schema)
    Http.post(model, "generateContent", build_request(model, prompt, opts))
  end

  @typedoc """
  The structure of a GoogleAI count tokens response.

  Has the following format:

  ```elixir
  %{
    "totalTokens" => 8
  }
  ```
  """
  @type count_tokens_response :: %{
          String.t() => integer()
        }

  @doc """
  Generates a model completion for a given prompt or conversation.
  Counts the number of tokens in the given `prompt` using the given model.

  ## Arguments

  * `:model` - The `GoogleAI.Model` to use for this request.
  * `:prompt` - The text prompt to count the tokens in.

  ## Returns

  A map containing the fields of the content tokens response.

  See https://ai.google.dev/tutorials/rest_quickstart#count_tokens.
  """
  @spec count_tokens(Model.t(), String.t()) :: Http.response(count_tokens_response())
  def count_tokens(model, prompt) do
    Http.post(model, "countTokens", build_request(model, prompt, []))
  end

  @spec build_request(Model.t(), String.t(), Keyword.t()) :: generation_request()
  defp build_request(_model, prompt, opts) do
    generation_config = opts[:generation_config]
    safety_settings = opts[:safety_settings]

    request = %{
      contents: [
        %{
          parts: [
            %{text: prompt}
          ]
        }
      ]
    }

    request =
      if generation_config do
        Map.put(request, :generationConfig, Utils.camelize_keys(generation_config))
      else
        request
      end

    request =
      if safety_settings do
        settings =
          safety_settings
          |> Enum.map(fn setting ->
            Utils.camelize_keys(setting)
          end)

        Map.put(request, :safetySettings, settings)
      else
        request
      end

    request
  end
end
