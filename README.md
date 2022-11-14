# Klife Protocol

Pure elixir implementation of the kafka protocol

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `klife_protocol` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:klife_protocol, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/klife_protocol>.

## Running Tests

```
docker-compose -f ./test/compose_files docker-compose-latest.yml up --force-recreate

mix test
```

## Generating auto generate files

```
mix generate_files PATH_TO_KAFKA_COMMONS_FOLDER
```


## Todos

- Add tests for most used kafka messages
- Add records serialization
- Benchmark serialization
