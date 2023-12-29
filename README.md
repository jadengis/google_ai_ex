# README

[![License](https://img.shields.io/hexpm/l/google_ai.svg)](https://github.com/jadengis/google_ai_ex/blob/master/LICENSE)
[![Hex Package](https://img.shields.io/hexpm/v/google_ai.svg)](https://hex.pm/packages/google_ai)
[![Hex Docs](https://img.shields.io/badge/hex-docs-blue.svg)](https://hexdocs.pm/google_ai)
[![CI](https://github.com/jadengis/google_ai_ex/actions/workflows/ci.yml/badge.svg)](https://github.com/jadengis/google_ai_ex/actions/workflows/ci.yml)

`GoogleAI` is an Elixir library that provides a community-maintained Google AI API client.

See https://ai.google.dev/tutorials/rest_quickstart for more information of the Google AI REST API.


## Installation

The package can be installed by adding `google_ai` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:google_ai, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/google_ai>.

## Features

- [x] `generateContent` - Text-only input
- [ ] `generateContent` - Text-and-image Input
- [ ] `generateContent` - Multi-turn conversation
- [x] `generateContent` - Configuration
- [ ] `streamGenerateContent`
- [x] `countTokens`
- [x] `embedContent`
- [x] `batchEmbedContents`
- [x] Get model
- [x] List models

## Configuration
You can configure `google_ai` in your mix config.exs (default $project_root/config/config.exs). If you're using Phoenix add the configuration in your config/dev.exs|test.exs|prod.exs files. An example config is:

```elixir
import Config

config :google_ai,
  # find it at https://makersuite.google.com/app/apikey
  api_key: "your-api-key",

```

## License

MIT
