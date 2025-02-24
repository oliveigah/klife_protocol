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

    # There is a simple rule that define the request header version to be used
    # for all the messages. This rule is coded inside the eex template

    # But for ControlledShutdown in version 0 is always 0

    # Other messages can be added to the map in order to
    # achieve a similar behaviour.
    @req_header_exceptions %{
      "ControlledShutdown" => {:versions, [0], 0}
    }

    # There is a simple rule that define the response header version to be used
    # for all the messages. This rule is coded inside the eex template

    # But ApiVersions message is always 0

    # Other messages can be added to the map in order to
    # achieve a similar behaviour.
    @res_header_exceptions %{
      "ApiVersions" => {:fixed, 0}
    }

    # By default all messages are supported.

    # But Fetch versions below 4 uses a different serialization
    # for record batch that are not supported yet.

    # This configuration prev prevent the generation for such versions.

    # Other messages can be added to the map in order to
    # achieve a similar behaviour.
    @version_exceptions %{
      "Fetch" => [0, 1, 2, 3]
    }

    def run(args) do
      kafka_commoms_path = List.first(args)

      result =
        (kafka_commoms_path <> "/*")
        |> Path.wildcard()
        |> Enum.map(&Path.split/1)
        |> Enum.map(&List.last/1)
        # Filter only for files of request messages.
        # We get the response counter part inside the `parse_file/1`
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
      # Every message is composed by 2 files, one request and one response.
      # Since we started  the process on `run/1` filtering only for files
      # that `Request` on their name, we need to get the `Response`
      # counter part in order to be able to generate the module correctly.
      res_file_path = String.replace(req_file_path, "Request", "Response")

      # Parse both json files to elixir maps
      req_map = path_to_map(req_file_path)
      res_map = path_to_map(res_file_path)

      # The name of the generated module must always be the same name
      # of the json file used to generate it. Removes only the qualifier
      # `Request` because we are grouping both request and response
      # on the same module
      module_name = req_map.name |> String.replace("Request", "")

      # Traverse the map for build all schemas for the message being handled
      request_schemas = parse_message_schema(req_map)
      response_schemas = parse_message_schema(res_map)

      case {request_schemas, response_schemas} do
        {:skip, :skip} ->
          "#{req_file_path} - SKIPPED"

        {request_schemas, response_schemas} ->
          # In order to keep backward compatibility we must keep
          # versions that may be removed by the current kafka
          # release. So we need to manually get the current version
          # of the schemas and keep them on the new file.

          {mod, curr_min_v, curr_max_v} =
            if module_name == "Header" do
              mod = String.to_atom("Elixir.KlifeProtocol.#{module_name}")

              {mod, 0, 2}
            else
              mod = String.to_atom("Elixir.KlifeProtocol.Messages.#{module_name}")
              curr_min_v = apply(mod, :min_supported_version, [])
              curr_max_v = apply(mod, :max_supported_version, [])

              {mod, curr_min_v, curr_max_v}
            end

          {max_request_version, _schema} = List.last(request_schemas)

          compatible_request_schemas =
            Enum.map(0..max_request_version, fn v ->
              new_val = Enum.find(request_schemas, fn {k, _v} -> k == v end)
              already_on_schema? = new_val != nil
              current_exists? = v >= curr_min_v and v <= curr_max_v

              cond do
                already_on_schema? -> new_val
                current_exists? -> {v, apply(mod, :request_schema, [v])}
                true -> raise "Unexpected gap for file #{req_file_path}"
              end
            end)

          {max_response_version, _schema} = List.last(response_schemas)

          compatible_response_schemas =
            Enum.map(0..max_response_version, fn v ->
              new_val = Enum.find(response_schemas, fn {k, _v} -> k == v end)
              already_on_schema? = new_val != nil
              current_exists? = v >= curr_min_v and v <= curr_max_v

              cond do
                already_on_schema? -> new_val
                current_exists? -> {v, apply(mod, :response_schema, [v])}
                true -> raise "Unexpected gap for file #{req_file_path}"
              end
            end)

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
                  request_schemas: compatible_request_schemas,
                  response_schemas: compatible_response_schemas,
                  req_flexible_version: req_flex_version,
                  res_flexible_version: res_flex_version,
                  req_header_exceptions: Map.get(@req_header_exceptions, module_name),
                  res_header_exceptions: Map.get(@res_header_exceptions, module_name),
                  req_versions_comments: get_versions_comments(req_file_path),
                  res_versions_comments: get_versions_comments(res_file_path),
                  req_field_comments: get_fields_comments(req_map),
                  res_field_comments: get_fields_comments(res_map),
                  version_exceptions: Map.get(@version_exceptions, module_name, [])
                ]

              "priv/header_module_template.eex" ->
                [
                  request_schemas: request_schemas,
                  response_schemas: response_schemas,
                  req_field_comments: get_fields_comments(req_map),
                  res_field_comments: get_fields_comments(res_map)
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
      end
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

    defp get_versions_comments(path) do
      path
      |> File.read!()
      |> String.split("{", parts: 2)
      |> List.last()
      |> String.split("validVersions", parts: 2)
      |> List.first()
      |> String.split("\n")
      |> Enum.filter(fn line -> String.contains?(line, "//") end)
      |> Enum.map(fn line -> String.replace(line, "//", "") end)
      |> Enum.map(&String.trim/1)
      |> Enum.chunk_by(fn e -> e == "" end)
      |> Enum.filter(fn e -> e != [""] end)
    end

    defp get_fields_comments(map) do
      common_structs =
        Enum.map(map[:commonStructs] || [], fn struct ->
          {struct.name, parse_field_comments(struct.fields, %{common_structs: %{}}, 0, [])}
        end)
        |> Map.new()

      metadata = %{common_structs: common_structs}

      parse_field_comments(map.fields, metadata, 0, [])
    end

    defp parse_field_comments([], _metadata, _depth, acc), do: acc

    defp parse_field_comments([field | rest], metadata, depth, acc) do
      append_data =
        if(Map.has_key?(field, :fields)) do
          line = build_field_comment_line(field)
          base = [{line, depth}]
          parse_field_comments(field.fields, metadata, depth + 1, base)
        else
          if String.starts_with?(field.type, "[]") do
            "[]" <> type = field.type

            case Map.get(metadata.common_structs, type) do
              nil ->
                [{build_field_comment_line(field), depth}]

              append_data ->
                append_data = Enum.map(append_data, fn {line, _} -> {line, depth + 1} end)

                [{build_field_comment_line(field), depth}] ++ append_data
            end
          else
            [{build_field_comment_line(field), depth}]
          end
        end

      parse_field_comments(rest, metadata, depth, acc ++ append_data)
    end

    defp build_field_comment_line(field) do
      name = to_snake_case(field.name)

      "- #{name}: #{field[:about] || ""} (#{field.type} | versions #{field[:versions] || field[:taggedVersions]})"
    end

    defp parse_message_schema(message) do
      type =
        cond do
          String.contains?(message.name, "Response") -> :response
          String.contains?(message.name, "Request") -> :request
        end

      message_type = message.type |> to_snake_case() |> String.to_atom()

      case get_versions(message.validVersions) do
        [min_version, max_version] ->
          schema_array =
            Enum.map(min_version..max_version, fn version ->
              is_flexible = is_flexible_version?(message, version)

              msg_metadata = %{
                type: type,
                version: version,
                is_flexible: is_flexible,
                message_type: message_type
              }

              # Common structs are complex types that can be reused on multiple fields of the message
              # and because of it, the field that refers to a common struct does not have
              # the key `fields` that usually indicates the schema of that complex type.
              # Therefore we need to handle the common structs first nd add it to the msg metadata
              # in order to copy their schema into the field when they are used.
              # Ex: ConsumerGroupHeartbeatResponse, DescribeQuorumResponse and many others
              common_structs = parse_commom_structs(message[:commonStructs] || [], msg_metadata)
              msg_metadata = Map.put(msg_metadata, :common_structs, common_structs)

              # Traverse the list of fields for properly build the schema
              schema = parse_schema(message.fields, msg_metadata)

              {version, schema}
            end)

          schema_array

        :skip ->
          :skip
      end
    end

    defp parse_commom_structs(common_structs, msg_metadata) do
      grouped_structs =
        Enum.group_by(common_structs, &is_recursive_common_struct?(&1, msg_metadata))

      # Some common structs can refer to other common structs, i've called them recursives
      # therefore we need to build the non recursive ones first, in order to reuse them
      # on the recursive common structs that refer to them
      # Example: AddPartitionsToTxnResponse
      non_recursive_structs = grouped_structs[false] || []
      recursive_structs = grouped_structs[true] || []

      base_commom_structs =
        non_recursive_structs
        |> Enum.map(&Map.put_new(&1, :type, &1.name))
        |> parse_schema(msg_metadata)

      recursive_commom_structs =
        recursive_structs
        |> Enum.map(&Map.put_new(&1, :type, &1.name))
        |> parse_schema(Map.put(msg_metadata, :common_structs, base_commom_structs))

      base_commom_structs ++ recursive_commom_structs
    end

    defp is_recursive_common_struct?(common_struct, msg_metadata) do
      Enum.map(common_struct.fields, fn f ->
        cond do
          get_type(f.type, msg_metadata, false) in [:array, :compact_array, :not_found] ->
            case Map.get(f, :fields) do
              nil ->
                true

              nested_fields ->
                is_recursive_common_struct?(nested_fields, msg_metadata)
            end

          true ->
            false
        end
      end)
      |> List.flatten()
      |> Enum.any?()
    end

    # Recursivelly parse fields into klife protocol schemas
    defp parse_schema(fields, msg_metadata),
      do: do_parse_schema(fields, msg_metadata, [], [])

    # Tag buffers are always added at the end of complex type fields in flexible versions.
    # Request tag buffers must be a list, because we receive a map as te input
    # and we need to know the exact order of the tagged fields
    defp do_parse_schema([], %{type: :request, is_flexible: true}, schema, tag_buffer),
      do: schema ++ [{:tag_buffer, {:tag_buffer, tag_buffer}}]

    # Response tag buffers can be a map because the order is already given
    # by the binary input and we just need to pull out the proper schema for the
    # tagged_fields based on their tag number at the begining of the binary
    defp do_parse_schema([], %{type: :response, is_flexible: true}, schema, tag_buffer),
      do: schema ++ [{:tag_buffer, {:tag_buffer, Map.new(tag_buffer)}}]

    # Tag buffers must not be added on not flexible versions
    defp do_parse_schema([], %{is_flexible: false}, schema, _tag_buffer),
      do: schema

    defp do_parse_schema(
           [field | rest_fields],
           %{version: version} = msg_metadata,
           schema,
           tag_buffer
         ) do
      version? = available_in_version?(field, version)
      tagged_field? = is_tagged_field?(field)

      field_metadata = %{
        is_nullable?: is_nullable?(field, version)
      }

      # Check if the current field is present on the version being handled
      # If it is not, just go to the next field.
      # If it is present, check if it is a tagged field.
      # Tagged fields must be handled different because of 2 main reasons:
      # 1 - They need to be accumulated on the tag buffer and not on the main schema
      # 2 - They have a tag` attribute in order to proper order them
      # Beside this 2 reasons, the process is the same for tagged and non tagged.
      # The `parse_tagged_field/2` delegates to `do_parse_schema_field/2` the heavy work.
      case {version?, tagged_field?} do
        {false, _} ->
          do_parse_schema(rest_fields, msg_metadata, schema, tag_buffer)

        {true, false} ->
          {name, type} = do_parse_schema_field(field, msg_metadata)
          parsed_field = {name, {type, field_metadata}}
          do_parse_schema(rest_fields, msg_metadata, schema ++ [parsed_field], tag_buffer)

        {true, true} ->
          {name, type} = parse_tagged_field(field, msg_metadata)
          parsed_field = {name, {type, field_metadata}}
          do_parse_schema(rest_fields, msg_metadata, schema, tag_buffer ++ [parsed_field])
      end
    end

    defp do_parse_schema_field(field, msg_metadata) do
      name = field.name |> to_snake_case() |> String.to_atom()

      has_fields? = Map.has_key?(field, :fields)

      type_is_common_struct? =
        Keyword.has_key?(msg_metadata[:common_structs] || [], get_type_name(field.type))

      should_raise_on_get_type? = !has_fields? && !type_is_common_struct?
      # This function maps the kafka types to the klife protocol types
      # We need the metadata in order to differentiate betewen compact and
      # non compact fields.
      # The raise part is just to know if something is missing. Otherwise
      # even if some basic type is missing the modules are generated
      # successfully but with types `:not_found`.
      case get_type(field.type, msg_metadata, should_raise_on_get_type?) do
        :array ->
          if has_fields? do
            {name, {:array, parse_schema(field.fields, msg_metadata)}}
          else
            {{:object, schema}, _} =
              Keyword.fetch!(msg_metadata.common_structs, get_type_name(field.type))

            {name, {:array, schema}}
          end

        :compact_array ->
          if has_fields? do
            {name, {:compact_array, parse_schema(field.fields, msg_metadata)}}
          else
            {{:object, schema}, _} =
              Keyword.fetch!(msg_metadata.common_structs, get_type_name(field.type))

            {name, {:compact_array, schema}}
          end

        :not_found ->
          if has_fields? do
            {name, {:object, parse_schema(field.fields, msg_metadata)}}
          else
            {{:object, schema}, _} =
              Keyword.fetch!(msg_metadata.common_structs, get_type_name(field.type))

            {name, {:object, schema}}
          end

        val ->
          {name, val}
      end
    end

    defp parse_tagged_field(field, %{type: :response} = msg_metadata) do
      {name, type} = do_parse_schema_field(field, msg_metadata)
      {field.tag, {name, type}}
    end

    defp parse_tagged_field(field, %{type: :request} = msg_metadata) do
      {name, type} = do_parse_schema_field(field, msg_metadata)
      {name, {field.tag, type}}
    end

    defp get_versions(valid_versions) do
      is_range? = String.contains?(valid_versions, "-")
      is_none? = valid_versions == "none"

      cond do
        is_range? ->
          valid_versions
          |> String.split("-")
          |> Enum.map(&String.to_integer/1)

        is_none? ->
          # To remove from the file generation.
          :skip

        true ->
          [
            String.to_integer(valid_versions),
            String.to_integer(valid_versions)
          ]
      end
    end

    defp available_in_version?(field, current_version) do
      # For some reason only the ReplicaState field of the fetchRequest message
      # does not have a version key, therefore we are using the taggedVersion as a fallback.
      # I've open a PR about this on the kafka repo: https://github.com/apache/kafka/pull/13680
      (field[:versions] || field[:taggedVersions])
      |> parse_versions_string()
      |> check_version(current_version)
    end

    defp is_flexible_version?(message, current_version) do
      message.flexibleVersions
      |> parse_versions_string()
      |> check_version(current_version)
    end

    defp is_nullable?(field, current_version) do
      field
      |> Map.get(:nullableVersions)
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

    defp get_type(string_type, msg_metadata, raise?)

    defp get_type("int8", _msg_metadata, _raise?), do: :int8
    defp get_type("int16", _msg_metadata, _raise?), do: :int16
    defp get_type("int32", _msg_metadata, _raise?), do: :int32
    defp get_type("int64", _msg_metadata, _raise?), do: :int64
    defp get_type("string", %{message_type: :header}, _raise?), do: :string
    defp get_type("string", %{is_flexible: false}, _raise?), do: :string
    defp get_type("string", %{is_flexible: true}, _raise?), do: :compact_string
    defp get_type("bool", _msg_metadata, _raise?), do: :boolean
    defp get_type("uuid", _msg_metadata, _raise?), do: :uuid
    defp get_type("float64", _msg_metadata, _raise?), do: :float64
    defp get_type("bytes", %{message_type: :header}, _raise?), do: :bytes
    defp get_type("bytes", %{is_flexible: false}, _raise?), do: :bytes
    defp get_type("bytes", %{is_flexible: true}, _raise?), do: :compact_bytes
    defp get_type("uint16", _msg_metadata, _raise?), do: :uint16
    defp get_type("records", %{is_flexible: true}, _raise?), do: :compact_record_batch
    defp get_type("records", _msg_metadata, _raise?), do: :record_batch

    defp get_type("[]" <> type, %{message_type: :header} = msg_metadata, _raise?) do
      case get_type(type, msg_metadata, false) do
        :not_found ->
          :array

        val ->
          {:array, val}
      end
    end

    defp get_type("[]" <> type, %{is_flexible: false} = msg_metadata, _raise?) do
      case get_type(type, msg_metadata, false) do
        :not_found ->
          :array

        val ->
          {:array, val}
      end
    end

    defp get_type("[]" <> type, %{is_flexible: true} = msg_metadata, _raise?) do
      case get_type(type, msg_metadata, false) do
        :not_found ->
          :compact_array

        val ->
          {:compact_array, val}
      end
    end

    defp get_type(_, _, false), do: :not_found

    defp get_type_name("[]" <> name), do: name |> to_snake_case() |> String.to_atom()
    defp get_type_name(name), do: name |> to_snake_case() |> String.to_atom()

    defp to_snake_case(string), do: Macro.underscore(string)
  end
end
