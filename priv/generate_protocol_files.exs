Mix.install([{:jason, "~> 1.4"}])

defmodule Klife.Protocol.FileParser do
  @template_by_module %{
    "Header" => "priv/header_module_template.eex",
    "default" => "priv/message_module_template.eex"
  }

  @write_path_by_module %{
    "Header" => "lib/klife/protocol/generated/",
    "default" => "lib/klife/protocol/generated/messages/"
  }

  def run_all(kafka_commoms_path) do
    (kafka_commoms_path <> "/*")
    |> Path.wildcard()
    |> Enum.map(&Path.split/1)
    |> Enum.map(&List.last/1)
    |> Enum.filter(&String.contains?(&1, "Request"))
    |> Enum.map(fn req_file_name -> kafka_commoms_path <> "/#{req_file_name}" end)
    |> Enum.map(&run/1)
  end

  def run(req_file_path) do
    res_file_path = String.replace(req_file_path, "Request", "Response")

    req_map = path_to_map(req_file_path)
    res_map = path_to_map(res_file_path)

    module_name = req_map.name |> String.replace("Request", "")
    request_schemas = parse_message_schema(req_map)
    response_schemas = parse_message_schema(res_map)

    template_path = @template_by_module[module_name] || @template_by_module["default"]
    write_base_path = @write_path_by_module[module_name] || @write_path_by_module["default"]

    bindings =
      case template_path do
        "priv/message_module_template.eex" ->
          [
            module_name: module_name,
            api_key: req_map.apiKey,
            request_schemas: request_schemas,
            response_schemas: response_schemas
          ]

        "priv/header_module_template.eex" ->
          [
            request_schemas: request_schemas,
            response_schemas: response_schemas
          ]
      end

    module_content =
      template_path
      |> Path.relative()
      |> File.read!()
      |> EEx.eval_string(bindings)
      |> tap(fn e ->
        if String.contains?(e, [":not_found", "nil"]), do: raise("maluco")
      end)
      |> Code.format_string!()

    file_name = to_snake_case(module_name)

    File.mkdir_p!(write_base_path)

    (write_base_path <> "#{file_name}.ex")
    |> Path.relative()
    |> File.write!(module_content)

    write_base_path <> "#{file_name}.ex"
  rescue
    e ->
      IO.puts("Error while parsing file #{req_file_path}")
      reraise e, __STACKTRACE__
  end

  defp path_to_map(path) do
    path
    |> File.read!()
    |> String.split("\n")
    |> Enum.filter(fn line -> !String.contains?(line, "//") end)
    |> Enum.join()
    |> Jason.decode!(keys: :atoms)
  end

  defp parse_message_schema(message) do
    type =
      message.type
      |> to_snake_case()
      |> String.to_atom()

    [min_version, max_version] = get_versions(message.validVersions)

    schema_array =
      Enum.map(min_version..max_version, fn version ->
        is_flexible = is_flexible_version?(message, version)

        metadata = %{
          type: type,
          version: version,
          is_flexible: is_flexible
        }

        common_structs = parse_commom_structs(message[:commonStructs] || [], metadata)

        metadata =
          if length(common_structs) > 0,
            do: Map.put(metadata, :common_structs, common_structs),
            else: metadata

        schema = parse_schema(message.fields, metadata)

        {version, schema}
      end)

    schema_array
  end

  defp parse_commom_structs(common_structs, metadata) do
    common_structs
    |> Enum.map(&Map.put_new(&1, :type, &1.name))
    |> parse_schema(metadata)
    |> Keyword.delete(:tag_buffer)
  end

  defp parse_schema(fields, metadata),
    do: do_parse_schema(fields, metadata, [], [])

  defp do_parse_schema([], %{is_flexible: true}, schema, tag_buffer),
    do: schema ++ [{:tag_buffer, Map.new(tag_buffer)}]

  defp do_parse_schema([], %{is_flexible: false}, schema, _tag_buffer),
    do: schema

  defp do_parse_schema([field | rest_fields], %{version: version} = metadata, schema, tag_buffer) do
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

  defp do_parse_schema_field(field, metadata) do
    name = field.name |> to_snake_case() |> String.to_atom()
    has_fields? = Map.has_key?(field, :fields)

    case get_type(field.type, !has_fields?) do
      :array ->
        if has_fields? do
          {name, {:array, parse_schema(field.fields, metadata)}}
        else
          {:object, schema} = Keyword.fetch!(metadata.common_structs, get_type_name(field.type))
          {name, {:array, schema}}
        end

      :not_found ->
        if has_fields? do
          {name, {:object, parse_schema(field.fields, metadata)}}
        else
          {:object, schema} = Keyword.fetch!(metadata.common_structs, get_type_name(field.type))
          {name, {:object, schema}}
        end

      val ->
        {name, val}
    end
  end

  defp parse_tagged_field(field, %{type: :response} = metadata) do
    {name, type} = do_parse_schema_field(field, metadata)
    {field.tag, {name, type}}
  end

  defp parse_tagged_field(field, %{type: :request} = metadata) do
    {name, type} = do_parse_schema_field(field, metadata)
    {name, {field.tag, type}}
  end

  defp get_versions(valid_versions) do
    if String.contains?(valid_versions, "-"),
      do:
        valid_versions
        |> String.split("-")
        |> Enum.map(&String.to_integer/1),
      else: [
        String.to_integer(valid_versions),
        String.to_integer(valid_versions)
      ]
  end

  defp available_in_version?(field, current_version) do
    case get_available_versions(field.versions) do
      {:min, min_version} ->
        current_version >= min_version

      {:list, versions} ->
        Enum.any?(versions, &(&1 == current_version))

      {:exact, verion} ->
        current_version == verion
    end
  end

  defp get_available_versions(field_versions) do
    cond do
      String.contains?(field_versions, "+") ->
        version =
          field_versions
          |> String.split("+")
          |> List.first()
          |> String.to_integer()

        {:min, version}

      String.contains?(field_versions, "-") ->
        versions =
          field_versions
          |> String.split("-")
          |> Enum.map(&String.to_integer/1)

        {:list, versions}

      Integer.parse(field_versions) != :error ->
        {:exact, String.to_integer(field_versions)}

      true ->
        raise "Unkown available versions #{field_versions}"
    end
  end

  defp is_flexible_version?(message, current_version) do
    case get_flexible_versions(message.flexibleVersions) do
      {:min, min_version} -> current_version >= min_version
      :none -> false
    end
  end

  defp get_flexible_versions(flexible_versions) do
    cond do
      String.contains?(flexible_versions, "+") ->
        version =
          flexible_versions
          |> String.split("+")
          |> List.first()
          |> String.to_integer()

        {:min, version}

      flexible_versions == "none" ->
        :none

      true ->
        raise "Unkown flexible versions #{flexible_versions}"
    end
  end

  defp is_tagged_field?(field), do: Map.get(field, :tag) != nil

  defp get_type(string_type, raise?)

  defp get_type("int8", _raise?), do: :int8
  defp get_type("int16", _raise?), do: :int16
  defp get_type("int32", _raise?), do: :int32
  defp get_type("int64", _raise?), do: :int64
  defp get_type("string", _raise?), do: :string
  defp get_type("bool", _raise?), do: :boolean
  defp get_type("uuid", _raise?), do: :uuid
  defp get_type("float64", _raise?), do: :float64
  defp get_type("bytes", _raise?), do: :bytes
  defp get_type("uint16", _raise?), do: :uint16
  defp get_type("records", _raise?), do: :records

  defp get_type("[]" <> type, _raise?) do
    case get_type(type, false) do
      :not_found ->
        :array

      val ->
        {:array, val}
    end
  end

  defp get_type(_, false), do: :not_found

  defp get_type_name("[]" <> name), do: name |> to_snake_case() |> String.to_atom()

  defp to_snake_case(string), do: Macro.underscore(string)
end

case IO.gets("Please, enter the folder containing JSON files of kafka commons?\n") do
  {:error, reason} ->
    IO.puts("Error. reason: #{inspect(reason)}")

  data ->
    result =
      data
      |> String.trim()
      |> Klife.Protocol.FileParser.run_all()

    IO.puts("Generated #{length(result)} files successfully.")
    IO.puts("Details:")
    IO.inspect(result)
end
