defmodule GoogleAI.MixProject do
  use Mix.Project

  @version "0.1.0"
  @description "Community maintained Google AI API client."
  @source_url "https://github.com/jadengis/google_ai_ex/"

  def project do
    [
      app: :google_ai,
      version: @version,
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      docs: docs()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:req, "~> 0.4"},
      {:nimble_options, "~> 1.0"},
      {:bypass, "~> 2.1", only: :test},
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false},
      {:ex_doc, ">= 0.0.0", only: :docs}
    ]
  end

  defp package do
    [
      description: @description,
      licenses: ["MIT"],
      links: %{
        "GitHub" => @source_url
      }
    ]
  end

  defp docs do
    [
      main: "readme",
      source_url: @source_url,
      source_ref: "v#{@version}",
      extras: ["README.md"]
    ]
  end
end
