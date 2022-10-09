if Mix.env() == :dev do
  defmodule Mix.Tasks.GenerateFiles do
    use Mix.Task
    @preferred_cli_env :dev

    @template_by_module %{
      "Header" => "priv/header_module_template.eex",
      "default" => "priv/message_module_template.eex"
    }

    @write_path_by_module %{
      "Header" => "lib/klife_protocol/generated/",
      "default" => "lib/klife_protocol/generated/messages/"
    }

    @req_header_exceptions %{
      "ControlledShutdown" => {:versions, [0], 0}
    }
    @res_header_exceptions %{
      "ApiVersions" => {:fixed, 0}
    }

    def run(args) do
      kafka_commoms_path = List.first(args)

      result =
        (kafka_commoms_path <> "/*")
        |> Path.wildcard()
        |> Enum.map(&Path.split/1)
        |> Enum.map(&List.last/1)
        |> Enum.filter(&String.contains?(&1, "Request"))
        |> Enum.map(fn req_file_name -> kafka_commoms_path <> "/#{req_file_name}" end)
        |> Enum.map(&parse_file/1)

      IO.puts("Generated #{length(result)} files successfully!\n")

      IO.puts("Generated files:\n")

      Enum.each(result, &IO.puts/1)

      IO.puts("\nRecompiling...\n")

      Mix.Tasks.Compile.Elixir.run(["--warnings-as-errors"])

      IO.puts("Automatic file generation complete!")
    end

    defp parse_file(req_file_path) do
      res_file_path = String.replace(req_file_path, "Request", "Response")

      req_map = path_to_map(req_file_path)
      res_map = path_to_map(res_file_path)

      module_name = req_map.name |> String.replace("Request", "")
      request_schemas = parse_message_schema(req_map)
      response_schemas = parse_message_schema(res_map)

      template_path = @template_by_module[module_name] || @template_by_module["default"]
      write_base_path = @write_path_by_module[module_name] || @write_path_by_module["default"]

      req_flex_version =
        case parse_versions_string(req_map.flexibleVersions) do
          {:min, v} -> v
          v -> v
        end

      res_flex_version =
        case parse_versions_string(res_map.flexibleVersions) do
          {:min, v} -> v
          v -> v
        end

      bindings =
        case template_path do
          "priv/message_module_template.eex" ->
            [
              module_name: module_name,
              api_key: req_map.apiKey,
              request_schemas: request_schemas,
              response_schemas: response_schemas,
              req_flexible_version: req_flex_version,
              res_flexible_version: res_flex_version,
              req_header_exceptions: Map.get(@req_header_exceptions, module_name),
              res_header_exceptions: Map.get(@res_header_exceptions, module_name)
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
        cond do
          String.contains?(message.name, "Response") -> :response
          String.contains?(message.name, "Request") -> :request
        end

      message_type = message.type |> to_snake_case() |> String.to_atom()

      [min_version, max_version] = get_versions(message.validVersions)

      schema_array =
        Enum.map(min_version..max_version, fn version ->
          is_flexible = is_flexible_version?(message, version)

          metadata = %{
            type: type,
            version: version,
            is_flexible: is_flexible,
            message_type: message_type
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

    defp do_parse_schema([], %{type: :request, is_flexible: true}, schema, tag_buffer),
      do: schema ++ [{:tag_buffer, {:tag_buffer, tag_buffer}}]

    defp do_parse_schema([], %{type: :response, is_flexible: true}, schema, tag_buffer),
      do: schema ++ [{:tag_buffer, {:tag_buffer, Map.new(tag_buffer)}}]

    defp do_parse_schema([], %{is_flexible: false}, schema, _tag_buffer),
      do: schema

    defp do_parse_schema(
           [field | rest_fields],
           %{version: version} = metadata,
           schema,
           tag_buffer
         ) do
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

      case get_type(field.type, metadata, !has_fields?) do
        :array ->
          if has_fields? do
            {name, {:array, parse_schema(field.fields, metadata)}}
          else
            {:object, schema} = Keyword.fetch!(metadata.common_structs, get_type_name(field.type))
            {name, {:array, schema}}
          end

        :compact_array ->
          if has_fields? do
            {name, {:compact_array, parse_schema(field.fields, metadata)}}
          else
            {:object, schema} = Keyword.fetch!(metadata.common_structs, get_type_name(field.type))
            {name, {:compact_array, schema}}
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
      field.versions
      |> parse_versions_string()
      |> check_version(current_version)
    end

    defp is_flexible_version?(message, current_version) do
      message.flexibleVersions
      |> parse_versions_string()
      |> check_version(current_version)
    end

    defp parse_versions_string(versions) do
      cond do
        versions in [nil, "none"] ->
          :none

        String.contains?(versions, "+") ->
          version =
            versions
            |> String.split("+")
            |> List.first()
            |> String.to_integer()

          {:min, version}

        String.contains?(versions, "-") ->
          [min, max] =
            versions
            |> String.split("-")
            |> Enum.map(&String.to_integer/1)

          {:list, min..max}

        Integer.parse(versions) != :error ->
          {:exact, String.to_integer(versions)}

        true ->
          raise "Unkown versions string #{versions}"
      end
    end

    defp check_version(:none, _current), do: false
    defp check_version({:min, version}, current), do: current >= version
    defp check_version({:exact, version}, current), do: current == version
    defp check_version({:list, versions}, current), do: Enum.any?(versions, &(&1 == current))

    defp is_tagged_field?(field), do: Map.get(field, :tag) != nil

    defp get_type(string_type, metadata, raise?)

    defp get_type("int8", _metadata, _raise?), do: :int8
    defp get_type("int16", _metadata, _raise?), do: :int16
    defp get_type("int32", _metadata, _raise?), do: :int32
    defp get_type("int64", _metadata, _raise?), do: :int64
    defp get_type("string", %{message_type: :header}, _raise?), do: :string
    defp get_type("string", %{is_flexible: false}, _raise?), do: :string
    defp get_type("string", %{is_flexible: true}, _raise?), do: :compact_string
    defp get_type("bool", _metadata, _raise?), do: :boolean
    defp get_type("uuid", _metadata, _raise?), do: :uuid
    defp get_type("float64", _metadata, _raise?), do: :float64
    defp get_type("bytes", %{message_type: :header}, _raise?), do: :bytes
    defp get_type("bytes", %{is_flexible: false}, _raise?), do: :bytes
    defp get_type("bytes", %{is_flexible: true}, _raise?), do: :compact_bytes
    defp get_type("uint16", _metadata, _raise?), do: :uint16
    defp get_type("records", _metadata, _raise?), do: :records

    defp get_type("[]" <> type, %{message_type: :header} = metadata, _raise?) do
      case get_type(type, metadata, false) do
        :not_found ->
          :array

        val ->
          {:array, val}
      end
    end

    defp get_type("[]" <> type, %{is_flexible: false} = metadata, _raise?) do
      case get_type(type, metadata, false) do
        :not_found ->
          :array

        val ->
          {:array, val}
      end
    end

    defp get_type("[]" <> type, %{is_flexible: true} = metadata, _raise?) do
      case get_type(type, metadata, false) do
        :not_found ->
          :compact_array

        val ->
          {:compact_array, val}
      end
    end

    defp get_type(_, _, false), do: :not_found

    defp get_type_name("[]" <> name), do: name |> to_snake_case() |> String.to_atom()

    defp to_snake_case(string), do: Macro.underscore(string)
  end
end
