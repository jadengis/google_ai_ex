# README

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

## Configuration
You can configure `google_ai` in your mix config.exs (default $project_root/config/config.exs). If you're using Phoenix add the configuration in your config/dev.exs|test.exs|prod.exs files. An example config is:

```elixir
import Config

config :google_ai,
  # find it at https://makersuite.google.com/app/apikey
  api_key: "your-api-key",

```

