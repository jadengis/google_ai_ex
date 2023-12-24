defmodule GoogleAI.ModelTest do
  use GoogleAI.HttpCase, async: true
  doctest GoogleAI.Model

  alias GoogleAI.Model

  describe "Model.new/2" do
    test "raises validation error when given bad opts", %{
      client: client
    } do
      assert_raise NimbleOptions.ValidationError, fn -> Model.new(client, model: 12345) end
    end

    test "returns a a new Model struct", %{client: client} do
      assert %Model{client: client, model: "gemini-pro"} = Model.new(client, model: "gemini-pro")

      assert %{req: %Req.Request{url: url, options: options}} =
               client

      assert url == URI.parse("/:version/models/:model::action")
      assert options[:path_params] == [version: "v1beta", model: "gemini-pro"]
    end
  end

  describe "Model.get/2" do
    test "returns a success tuple with model response when given a model name", %{
      bypass: bypass,
      client: client
    } do
      Bypass.expect_once(bypass, "GET", "/v1beta/models/gemini-pro", fn conn ->
        assert conn.query_params["key"] == "asdfasdf"

        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(200, get_model_payload())
      end)

      assert {:ok,
              %{
                "name" => "models/gemini-pro",
                "version" => "001",
                "displayName" => "Gemini Pro"
              }} =
               Model.get(client, "gemini-pro")
    end
  end

  defp get_model_payload do
    ~S<{
  "name": "models/gemini-pro",
  "version": "001",
  "displayName": "Gemini Pro",
  "description": "The best model for scaling across a wide range of tasks",
  "inputTokenLimit": 30720,
  "outputTokenLimit": 2048,
  "supportedGenerationMethods": [
    "generateContent",
    "countTokens"
  ],
  "temperature": 0.9,
  "topP": 1,
  "topK": 1
}>
  end

  describe "Model.list/1" do
    test "returns a success tuple with model list response", %{
      bypass: bypass,
      client: client
    } do
      Bypass.expect_once(bypass, "GET", "/v1beta/models", fn conn ->
        assert conn.query_params["key"] == "asdfasdf"

        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(200, list_models_payload())
      end)

      assert {:ok,
              %{
                "models" => [
                  %{
                    "name" => "models/chat-bison-001",
                    "version" => "001",
                    "displayName" => "Chat Bison"
                  }
                  | _rest
                ]
              }} =
               Model.list(client)
    end
  end

  defp list_models_payload do
    ~S<{
  "models": [
    {
      "name": "models/chat-bison-001",
      "version": "001",
      "displayName": "Chat Bison",
      "description": "Chat-optimized generative language model.",
      "inputTokenLimit": 4096,
      "outputTokenLimit": 1024,
      "supportedGenerationMethods": [
        "generateMessage",
        "countMessageTokens"
      ],
      "temperature": 0.25,
      "topP": 0.95,
      "topK": 40
    },
    {
      "name": "models/text-bison-001",
      "version": "001",
      "displayName": "Text Bison",
      "description": "Model targeted for text generation.",
      "inputTokenLimit": 8196,
      "outputTokenLimit": 1024,
      "supportedGenerationMethods": [
        "generateText",
        "countTextTokens",
        "createTunedTextModel"
      ],
      "temperature": 0.7,
      "topP": 0.95,
      "topK": 40
    },
    {
      "name": "models/embedding-gecko-001",
      "version": "001",
      "displayName": "Embedding Gecko",
      "description": "Obtain a distributed representation of a text.",
      "inputTokenLimit": 1024,
      "outputTokenLimit": 1,
      "supportedGenerationMethods": [
        "embedText",
        "countTextTokens"
      ]
    },
    {
      "name": "models/embedding-gecko-002",
      "version": "002",
      "displayName": "Embedding Gecko 002",
      "description": "Obtain a distributed representation of a text.",
      "inputTokenLimit": 2048,
      "outputTokenLimit": 1,
      "supportedGenerationMethods": [
        "embedText",
        "countTextTokens"
      ]
    },
    {
      "name": "models/gemini-pro",
      "version": "001",
      "displayName": "Gemini Pro",
      "description": "The best model for scaling across a wide range of tasks",
      "inputTokenLimit": 30720,
      "outputTokenLimit": 2048,
      "supportedGenerationMethods": [
        "generateContent",
        "countTokens"
      ],
      "temperature": 0.9,
      "topP": 1,
      "topK": 1
    },
    {
      "name": "models/gemini-pro-vision",
      "version": "001",
      "displayName": "Gemini Pro Vision",
      "description": "The best image understanding model to handle a broad range of applications",
      "inputTokenLimit": 12288,
      "outputTokenLimit": 4096,
      "supportedGenerationMethods": [
        "generateContent",
        "countTokens"
      ],
      "temperature": 0.4,
      "topP": 1,
      "topK": 32
    },
    {
      "name": "models/gemini-ultra",
      "version": "001",
      "displayName": "Gemini Ultra",
      "description": "The most capable model for highly complex tasks",
      "inputTokenLimit": 30720,
      "outputTokenLimit": 2048,
      "supportedGenerationMethods": [
        "generateContent",
        "countTokens"
      ],
      "temperature": 0.9,
      "topP": 1,
      "topK": 32
    },
    {
      "name": "models/embedding-001",
      "version": "001",
      "displayName": "Embedding 001",
      "description": "Obtain a distributed representation of a text.",
      "inputTokenLimit": 2048,
      "outputTokenLimit": 1,
      "supportedGenerationMethods": [
        "embedContent",
        "countTextTokens"
      ]
    },
    {
      "name": "models/aqa",
      "version": "001",
      "displayName": "Model that performs Attributed Question Answering.",
      "description": "Model trained to return answers to questions that are grounded in provided sources, along with estimating answerable probability.",
      "inputTokenLimit": 7168,
      "outputTokenLimit": 1024,
      "supportedGenerationMethods": [
        "generateAnswer"
      ],
      "temperature": 0.2,
      "topP": 1,
      "topK": 40
    }
  ]
}>
  end
end
