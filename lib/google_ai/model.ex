defmodule GoogleAI.Model do
  @moduledoc """
  A struct representing a Google AI model.
  """
  @enforce_keys [:client, :model]
  defstruct client: nil, model: nil, generation_config: nil, safety_settings: nil

  alias GoogleAI.Client

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
                       type: :string,
                       doc:
                         "The model generation configuration. These will be passed to requests as required."
                     ],
                     safety_settings: [
                       type: :string,
                       doc:
                         "The model safety settings. These will be passed to requests as required."
                     ]
                   )

  @doc """
  Create a new GoogleAI model from the given `client` and `opts`.

  The function `new/1` will use the default GoogleAI API configuration.

  ## Options
  #{NimbleOptions.docs(@new_opts_schema)}
  """
  @spec new(client :: Client.t(), opts :: Keyword.t()) :: t()
  def new(%Client{req: req} = client \\ GoogleAI.client(), opts) do
    opts = NimbleOptions.validate!(opts, @new_opts_schema)
    client = %{client | req: Req.update(req, path_params: [model: opts[:model]])}
    struct(__MODULE__, [{:client, client} | opts])
  end
end
