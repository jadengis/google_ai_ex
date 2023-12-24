defmodule GoogleAI.Model do
  @moduledoc """
  A struct representing a Google AI model.
  """
  @enforce_keys [:client, :model]
  defstruct client: nil, model: nil, generation_config: nil, safety_settings: nil

  alias GoogleAI.Client
  alias GoogleAI.Http
  alias GoogleAI.Utils

  @typedoc """
  Configuration used for tweaking model generation.
  """
  @type generation_config :: %{
          candidateCount: integer(),
          stopSequences: [String.t()],
          maxOutputTokens: integer(),
          temperature: float(),
          topP: number(),
          topK: number()
        }

  @typedoc """
  Configuration used for tweaking model safety.
  """
  @type safety_settings :: [
          %{
            category: String.t(),
            threshold: String.t()
          }
        ]

  @typedoc """
  Type of the underlying model struct.
  """
  @type t :: %__MODULE__{
          client: Client.t(),
          model: String.t(),
          generation_config: generation_config(),
          safety_settings: safety_settings()
        }

  @new_opts_schema NimbleOptions.new!(
                     model: [
                       type: :string,
                       required: true,
                       doc: "The model name e.g. gemini-pro, gemini-pro-vision or embedding-001."
                     ],
                     generation_config: [
                       type: :keyword_list,
                       doc:
                         "The model generation configuration. These will be passed to requests as required."
                     ],
                     safety_settings: [
                       type: :keyword_list,
                       doc:
                         "The model safety settings. These will be passed to requests as required."
                     ]
                   )

  @doc """
  Create a new GoogleAI model from the given `client` and `opts`.

  The function `new/1` will use the default GoogleAI API configuration.

  ## Options

  #{NimbleOptions.docs(@new_opts_schema)}
  ## Examples

    iex> client = GoogleAI.client(api_key: "asdfasdf")
    ...> GoogleAI.Model.new(client, model: "gemini-pro")
    %GoogleAI.Model{
      client: %GoogleAI.Client{
        req: Req.new(
          url: "/:version/models/:model::action",
          base_url: "https://generativelanguage.googleapis.com",
          params: [key: "asdfasdf"], 
          path_params: [version: "v1beta", model: "gemini-pro"]
        )
      },
      model: "gemini-pro",
      generation_config: nil,
      safety_settings: nil
    }

  """
  @spec new(client :: Client.t(), opts :: Keyword.t()) :: t()
  def new(%Client{req: req} = client \\ GoogleAI.client(), opts) do
    opts = NimbleOptions.validate!(opts, @new_opts_schema)

    req =
      req
      |> Utils.merge_path_params(model: opts[:model])
      |> Req.update(url: "/:version/models/:model::action")

    client = %{client | req: req}
    struct(__MODULE__, [{:client, client} | opts])
  end

  @typedoc """
  The structure of a GoogleAI get model response.

  Has the following format:

  ```elixir
  %{
    "name" => "models/gemini-pro",
    "version" => "001",
    "displayName" => "Gemini Pro",
    "description" => "The best model for scaling across a wide range of tasks",
    "inputTokenLimit" => 30720,
    "outputTokenLimit" => 2048,
    "supportedGenerationMethods" => [
      "generateContent",
      "countTokens"
    ],
    "temperature" => 0.9,
    "topP" => 1,
    "topK" => 1
  }
  ```
  """
  @type get_model_response :: %{
          String.t() => String.t() | [String.t()]
        }

  @doc """
  Get information about the model with the given `model_name`.

  ## Arguments

  * `:client` - The `GoogleAI.Client` to use for this request.
  * `:model_name` - The name of the model to look up.

  ## Returns

  A map containing the fields of the get model response.

  See https://ai.google.dev/tutorials/rest_quickstart#get_model.

  """
  @spec get(client :: Client.t(), model_name :: String.t()) :: Http.response(get_model_response())
  def get(%Client{req: req} \\ GoogleAI.client(), model_name) do
    req =
      req
      |> Utils.merge_path_params(model: model_name)
      |> Req.update(url: "/:version/models/:model")

    Http.get(req)
  end

  @typedoc """
  The structure of a GoogleAI list models response.

  Has the following format:

  ```elixir
  %{
    "models" => [
      %{
        "name" => "models/gemini-pro",
        "version" => "001",
        "displayName" => "Gemini Pro",
        "description" => "The best model for scaling across a wide range of tasks",
        "inputTokenLimit" => 30720,
        "outputTokenLimit" => 2048,
        "supportedGenerationMethods" => [
          "generateContent",
          "countTokens"
        ],
        "temperature" => 0.9,
        "topP" => 1,
        "topK" => 1
      }
    ]
  }
  ```
  """
  @type list_models_response :: %{
          String.t() => [get_model_response()]
        }

  @doc """
  List information about the all models available on Google AI.

  ## Arguments

  * `:client` - The `GoogleAI.Client` to use for this request.

  ## Returns

  A map containing the fields of the list models response.

  See https://ai.google.dev/tutorials/rest_quickstart#list_models

  """
  @spec list(client :: Client.t()) :: Http.response(list_models_response())
  def list(%Client{req: req} \\ GoogleAI.client()) do
    req = req |> Req.update(url: "/:version/models")
    Http.get(req)
  end
end
