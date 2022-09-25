defmodule Klife.Protocol.Messages.Parser do
  def run(file_path) do
    file_path
    |> File.read!()
    |> String.split("\n")
    |> Enum.filter(fn line -> !String.contains?(line, "//") end)
    |> Enum.join()
    |> Jason.decode!(keys: :atoms)
    |> parse_message()
  end

  defp parse_message(message) do
    name =
      message.name
      |> to_snake_case()
      |> String.split("_#{message.type}")
      |> List.first()
      |> String.to_atom()

    type =
      message.type
      |> to_snake_case()
      |> String.to_atom()

    [min_version, max_version] =
      message.validVersions
      |> String.split("-")
      |> Enum.map(&String.to_integer/1)

    Enum.map(min_version..max_version, fn version ->
      is_flexible = is_flexible_version?(message, version)
      schema = parse_schema(message.fields, {type, version, is_flexible})

      %{
        key: {name, type, version},
        value: %{
          api_key: message.apiKey,
          schema: schema
        }
      }
    end)
  end

  defp parse_schema(fields, {_type, _version, _is_flexible} = metadata),
    do: do_parse_schema(fields, metadata, [], [])

  defp do_parse_schema([], {_type, _version, true}, schema, tag_buffer),
    do: schema ++ [{:tag_buffer, Map.new(tag_buffer)}]

  defp do_parse_schema([], {_type, _version, false}, schema, _tag_buffer),
    do: schema

  defp do_parse_schema([field | rest_fields], metadata, schema, tag_buffer) do
    {_type, version, _is_flexible} = metadata
    version? = available_in_version?(field, version)
    tagged_field? = is_tagged_field?(field)

    case {version?, tagged_field?} do
      {false, _} ->
        do_parse_schema(rest_fields, metadata, schema, tag_buffer)

      {true, false} ->
        parsed_field = do_parse_schema_field(field, metadata)

        do_parse_schema(rest_fields, metadata, schema ++ [parsed_field], tag_buffer)

      {true, true} ->
        tagged_field = parse_tagged_field(field, metadata)
        do_parse_schema(rest_fields, metadata, schema, tag_buffer ++ [tagged_field])
    end
  end

  defp do_parse_schema_field(field, {type, version, is_flexible}) do
    name = field.name |> to_snake_case() |> String.to_atom()

    case get_type(field.type) do
      :array ->
        {name, {:array, parse_schema(field.fields, {type, version, is_flexible})}}

      val ->
        {name, val}
    end
  end

  defp parse_tagged_field(field, {:response, _version, _is_flexible} = metadata) do
    {name, type} = do_parse_schema_field(field, metadata)
    {field.tag, {name, type}}
  end

  defp parse_tagged_field(field, {:request, _version, _is_flexible} = metadata) do
    {name, type} = do_parse_schema_field(field, metadata)
    {name, {field.tag, type}}
  end

  defp available_in_version?(field, current_version) do
    min_version =
      String.split(field.versions, "+")
      |> List.first()
      |> String.to_integer()

    current_version >= min_version
  end

  defp is_flexible_version?(message, current_version) do
    min_version =
      String.split(message.flexibleVersions, "+")
      |> List.first()
      |> String.to_integer()

    current_version >= min_version
  end

  defp is_tagged_field?(field), do: Map.get(field, :tag) != nil

  defp get_type("int8"), do: :int8
  defp get_type("int16"), do: :int16
  defp get_type("int32"), do: :int32
  defp get_type("int64"), do: :int64
  defp get_type("string"), do: :string
  defp get_type("bool"), do: :boolean
  defp get_type("uuid"), do: :uuid

  defp get_type(val) do
    case String.split(val, "[]", parts: 2) do
      ["", type] ->
        case get_type(type) do
          nil ->
            :array

          val ->
            {:array, val}
        end

      _ ->
        nil
    end
  end

  defp to_snake_case(string), do: Macro.underscore(string)
end
