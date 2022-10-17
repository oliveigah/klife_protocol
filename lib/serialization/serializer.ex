defmodule KlifeProtocol.Serializer do
  import Bitwise

  def execute(input, schema, append_binary \\ <<>>) do
    do_serialize(schema, input, append_binary)
  end

  defp do_serialize([], map, result_data) when is_map(map), do: result_data
  defp do_serialize(_schema, [], result_data), do: result_data

  defp do_serialize([{_key, {:tag_buffer, _} = type} | rest_schema], %{} = input_map, acc_data) do
    input_map
    |> serialize_value(type)
    |> then(&do_serialize(rest_schema, input_map, acc_data <> &1))
  end

  defp do_serialize([{key, type} | rest_schema], %{} = input_map, acc_data) do
    input_map
    |> Map.get(key)
    |> serialize_value_with_key({key, type})
    |> then(&do_serialize(rest_schema, input_map, acc_data <> &1))
  end

  # Used in arrays of complex data types
  defp do_serialize(schema, [val | rest_val], acc_data) when is_list(schema) do
    schema
    |> do_serialize(val, acc_data)
    |> then(&do_serialize(schema, rest_val, &1))
  end

  # Used in arrays of simple data types
  defp do_serialize({_, _} = schema, [val | rest_val], acc_data) do
    val
    |> serialize_value(schema)
    |> then(&do_serialize(schema, rest_val, acc_data <> &1))
  end

  defp serialize_value_with_key(nil, {key, {_, %{is_nullable?: false}} = type}) do
    raise """
    Serialization error:

    field: #{inspect({key, type})}

    reason: field is not nullable
    """
  end

  defp serialize_value_with_key(val, {_key, {type, _metadata}}), do: do_serialize_value(val, type)

  defp serialize_value(nil, {type, %{is_nullable?: false}}) do
    raise """
    Serialization error:

    field: #{inspect(type)}

    reason: field is not nullable
    """
  end

  defp serialize_value(val, {:tag_buffer, schema} = type) when is_list(schema),
    do: do_serialize_value(val, type)

  defp serialize_value(val, {type, _metadata}), do: do_serialize_value(val, type)

  defp do_serialize_value(true, :boolean), do: <<1>>
  defp do_serialize_value(false, :boolean), do: <<0>>

  defp do_serialize_value(val, :int8), do: <<val::8-signed>>
  defp do_serialize_value(val, :int16), do: <<val::16-signed>>
  defp do_serialize_value(val, :int32), do: <<val::32-signed>>
  defp do_serialize_value(val, :int64), do: <<val::64-signed>>

  defp do_serialize_value(nil, :string), do: <<-1::16-signed>>

  defp do_serialize_value(val, :string) when is_binary(val),
    do: <<byte_size(val)::16-signed>> <> val

  defp do_serialize_value(nil, {:array, _schema}), do: <<-1::32-signed>>

  defp do_serialize_value(val, {:array, schema}),
    do: do_serialize(schema, val, <<length(val)::32-signed>>)

  defp do_serialize_value(nil, :compact_bytes), do: do_serialize_value(0, :varint)

  defp do_serialize_value(val, :compact_bytes),
    do: do_serialize_value(byte_size(val) + 1, :varint) <> val

  defp do_serialize_value(nil, :compact_string), do: do_serialize_value(0, :varint)

  defp do_serialize_value(val, :compact_string),
    do: do_serialize_value(byte_size(val) + 1, :varint) <> val

  defp do_serialize_value(nil, {:compact_array, _schema}),
    do: do_serialize_value(0, :varint)

  defp do_serialize_value(val, {:compact_array, schema}),
    do: do_serialize(schema, val, do_serialize_value(length(val) + 1, :varint))

  defp do_serialize_value(val, :varint) when val <= 127 and val >= 0, do: <<val>>

  defp do_serialize_value(val, :varint) when val > 127,
    do: <<1::1, band(val, 127)::7>> <> do_serialize_value(bsr(val, 7), :varint)

  defp do_serialize_value(_input_map, {:tag_buffer, []}), do: do_serialize_value(0, :varint)

  defp do_serialize_value(input_map, {:tag_buffer, tag_schema}) do
    existing_schema = Enum.filter(tag_schema, fn {key, _} -> Map.has_key?(input_map, key) end)
    len = length(existing_schema)
    serialize_tag_buffer(existing_schema, input_map, do_serialize_value(len, :varint))
  end

  defp serialize_tag_buffer([], _input_map, acc_data), do: acc_data

  defp serialize_tag_buffer(
         [{key, {{tag, type}, metadata}} | rest_schema],
         %{} = input_map,
         acc_data
       ) do
    input_map
    |> Map.fetch!(key)
    |> then(&serialize_tagged_field(tag, {type, metadata}, &1))
    |> then(&serialize_tag_buffer(rest_schema, input_map, acc_data <> &1))
  end

  defp serialize_tagged_field(tag, type, val) do
    value = serialize_value(val, type)
    size = do_serialize_value(byte_size(value) + 1, :varint)
    tag = do_serialize_value(tag, :varint)
    tag <> size <> value
  end
end
