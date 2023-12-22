defmodule GoogleAI.EmbeddingTest do
  use GoogleAI.HttpCase, async: true

  alias GoogleAI.Embedding

  describe "Embedding.create/2" do
    setup %{client: client} do
      model = GoogleAI.Model.new(client, model: "embedding-001")
      [model: model]
    end

    test "returns a success tuple with embedding response when given single string", %{
      bypass: bypass,
      model: model
    } do
      Bypass.expect_once(bypass, "POST", "/v1beta/models/embedding-001:embedContent", fn conn ->
        assert conn.query_params["key"] == "asdfasdf"

        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(200, create_embedding_payload())
      end)

      assert {:ok, %{"embedding" => %{"values" => values}}} =
               Embedding.create(model, "embed this text")

      assert [0.008624583 | _rest] = values
    end

    test "returns a success tuple with embeddings response when given a list", %{
      bypass: bypass,
      model: model
    } do
      Bypass.expect_once(
        bypass,
        "POST",
        "/v1beta/models/embedding-001:batchEmbedContents",
        fn conn ->
          assert conn.query_params["key"] == "asdfasdf"

          conn
          |> Plug.Conn.put_resp_header("content-type", "application/json")
          |> Plug.Conn.resp(200, create_embeddings_payload())
        end
      )

      assert {:ok, %{"embeddings" => [%{"values" => values}]}} =
               Embedding.create(model, ["embed this text"])

      assert [0.008624583 | _rest] = values
    end
  end

  defp create_embedding_payload do
    ~S<{
  "embedding": {
    "values": [
      0.008624583,
      -0.030451821,
      -0.042496547,
      -0.029230341,
      0.05486475,
      0.006694871,
      0.004025645
    ]
  }
}>
  end

  defp create_embeddings_payload do
    ~S<{
  "embeddings": [
    {
      "values": [
        0.008624583,
        -0.030451821,
        -0.042496547,
        -0.029230341,
        0.05486475,
        0.006694871
      ]
    }
  ]
}>
  end
end
