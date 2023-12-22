defmodule GoogleAI.ContentTest do
  use GoogleAI.HttpCase, async: true

  alias GoogleAI.Content

  describe "Content.generate/3" do
    setup %{client: client} do
      model = GoogleAI.Model.new(client, model: "gemini-pro")
      [model: model]
    end

    test "returns a success tuple with generate response when given single prompt", %{
      bypass: bypass,
      model: model
    } do
      prompt = "This is a prompt"

      Bypass.expect_once(bypass, "POST", "/v1beta/models/gemini-pro:generateContent", fn conn ->
        conn = parse_body(conn)
        assert conn.query_params["key"] == "asdfasdf"
        assert %{"contents" => [%{"parts" => [%{"text" => ^prompt}]}]} = conn.params

        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(200, generate_content_payload())
      end)

      assert {:ok,
              %{
                "candidates" => [
                  %{
                    "content" => %{
                      "role" => "model",
                      "parts" => [%{"text" => "This is a response"}]
                    }
                  }
                ]
              }} =
               Content.generate(model, prompt)
    end

    test "support generation config and safety settings", %{bypass: bypass, model: model} do
      prompt = "This is a prompt"

      Bypass.expect_once(bypass, "POST", "/v1beta/models/gemini-pro:generateContent", fn conn ->
        conn = parse_body(conn)
        assert conn.query_params["key"] == "asdfasdf"

        assert %{
                 "contents" => [%{"parts" => [%{"text" => ^prompt}]}],
                 "generationConfig" => generation_config,
                 "safetySettings" => [_ | _]
               } = conn.params

        assert %{"candidateCount" => 5} = generation_config

        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(200, generate_content_payload())
      end)

      assert {:ok,
              %{
                "candidates" => [
                  %{
                    "content" => %{
                      "role" => "model",
                      "parts" => [%{"text" => "This is a response"}]
                    }
                  }
                ]
              }} =
               Content.generate(model, prompt,
                 generation_config: [candidate_count: 5],
                 safety_settings: [
                   [category: "HARM_CATEGORY_SEXUALLY_EXPLICIT", threshold: "POSSIBLE"]
                 ]
               )
    end
  end

  defp generate_content_payload do
    ~S<{
  "candidates": [
    {
      "content": {
        "parts": [
          {
            "text": "This is a response"
          }
        ],
        "role": "model"
      },
      "finishReason": "STOP",
      "index": 0,
      "safetyRatings": [
        {
          "category": "HARM_CATEGORY_SEXUALLY_EXPLICIT",
          "probability": "NEGLIGIBLE"
        },
        {
          "category": "HARM_CATEGORY_HATE_SPEECH",
          "probability": "NEGLIGIBLE"
        },
        {
          "category": "HARM_CATEGORY_HARASSMENT",
          "probability": "NEGLIGIBLE"
        },
        {
          "category": "HARM_CATEGORY_DANGEROUS_CONTENT",
          "probability": "NEGLIGIBLE"
        }
      ]
    }
  ],
  "promptFeedback": {
    "safetyRatings": [
      {
        "category": "HARM_CATEGORY_SEXUALLY_EXPLICIT",
        "probability": "NEGLIGIBLE"
      },
      {
        "category": "HARM_CATEGORY_HATE_SPEECH",
        "probability": "NEGLIGIBLE"
      },
      {
        "category": "HARM_CATEGORY_HARASSMENT",
        "probability": "NEGLIGIBLE"
      },
      {
        "category": "HARM_CATEGORY_DANGEROUS_CONTENT",
        "probability": "NEGLIGIBLE"
      }
    ]
  }
}>
  end

  describe "Content.count_tokens/2" do
    setup %{client: client} do
      model = GoogleAI.Model.new(client, model: "gemini-pro")
      [model: model]
    end

    test "returns a success tuple with generate response when given single prompt", %{
      bypass: bypass,
      model: model
    } do
      prompt = "This is a prompt"

      Bypass.expect_once(bypass, "POST", "/v1beta/models/gemini-pro:countTokens", fn conn ->
        conn = parse_body(conn)
        assert conn.query_params["key"] == "asdfasdf"
        assert %{"contents" => [%{"parts" => [%{"text" => ^prompt}]}]} = conn.params

        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(200, count_tokens_payload())
      end)

      assert {:ok, %{"totalTokens" => 8}} = Content.count_tokens(model, prompt)
    end
  end

  defp count_tokens_payload do
    ~S<{
  "totalTokens": 8
}>
  end

  defp parse_body(conn) do
    opts =
      Plug.Parsers.init(
        parsers: [:json],
        pass: ["*/*"],
        json_decoder: Jason
      )

    Plug.Parsers.call(conn, opts)
  end
end
