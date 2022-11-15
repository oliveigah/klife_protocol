defmodule KlifeProtocol.Serializer do
  import Bitwise

  def execute(input, schema, append_binary \\ <<>>)

  def execute(input, schema, append_binary) when is_map(input) do
    do_serialize(schema, input, append_binary)
  end

  def execute(input, schema, append_binary) when is_list(input) do
    do_serialize(schema, input, append_binary)
  end

  def execute(input, {_, {_, _}} = schema, append_binary) do
    append_binary <> serialize_value(input, schema)
  end

  def execute(input, {_, _} = type, append_binary) do
    append_binary <> serialize_value(input, {:none, type})
  end

  def execute(input, type, append_binary) do
    append_binary <> serialize_value(input, {:none, {type, %{}}})
  end

  defp do_serialize([], map, result_data) when is_map(map), do: result_data
  defp do_serialize(_schema, [], result_data), do: result_data

  # Used for tag buffer
  defp do_serialize([{_key, {:tag_buffer, _} = type} | rest_schema], %{} = input_map, acc_data) do
    input_map
    |> do_serialize_value(type)
    |> then(&do_serialize(rest_schema, input_map, acc_data <> &1))
  end

  # Main function
  defp do_serialize([{key, type} | rest_schema], %{} = input_map, acc_data) do
    input_map
    |> Map.get(key)
    |> serialize_value({key, type})
    |> then(&do_serialize(rest_schema, input_map, acc_data <> &1))
  end

  # Used for arrays of complex data types
  defp do_serialize(schema, [val | rest_val], acc_data) when is_list(schema) do
    schema
    |> do_serialize(val, acc_data)
    |> then(&do_serialize(schema, rest_val, &1))
  end

  # Used for arrays of simple data types
  defp do_serialize(type, [val | rest_val], acc_data) do
    val
    |> do_serialize_value(type)
    |> then(&do_serialize(type, rest_val, acc_data <> &1))
  end

  defp do_serialize_records(schema, [], acc_data) when is_list(schema),
    do: acc_data

  defp do_serialize_records(schema, [val | rest_val], acc_data) when is_list(schema) do
    serialized_record = do_serialize(schema, val, <<>>)
    len = byte_size(serialized_record)
    serialized_len = do_serialize_value(len, :varint)
    new_acc = acc_data <> serialized_len <> serialized_record
    do_serialize_records(schema, rest_val, new_acc)
  end

  defp serialize_value(nil, {key, {_, %{is_nullable?: false}} = type}) do
    raise """
    Serialization error:

    field: #{inspect({key, type})}

    reason: field is not nullable
    """
  end

  defp serialize_value(val, {_key, {type, _metadata}}), do: do_serialize_value(val, type)

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

  defp do_serialize_value(nil, :bytes), do: <<-1::32-signed>>

  defp do_serialize_value(val, :bytes), do: <<byte_size(val)::32-signed>> <> val

  defp do_serialize_value(nil, :compact_bytes), do: do_serialize_value(0, :unsigned_varint)

  defp do_serialize_value(val, :compact_bytes),
    do: do_serialize_value(byte_size(val) + 1, :unsigned_varint) <> val

  defp do_serialize_value(nil, :compact_string), do: do_serialize_value(0, :unsigned_varint)

  defp do_serialize_value(val, :compact_string),
    do: do_serialize_value(byte_size(val) + 1, :unsigned_varint) <> val

  defp do_serialize_value(nil, {:compact_array, _schema}),
    do: do_serialize_value(0, :unsigned_varint)

  defp do_serialize_value(val, {:compact_array, schema}),
    do: do_serialize(schema, val, do_serialize_value(length(val) + 1, :unsigned_varint))

  defp do_serialize_value(val, :record_batch) do
    serialized_record_batch = KlifeProtocol.RecordBatch.serialize(val)
    do_serialize_value(byte_size(serialized_record_batch), :int32) <> serialized_record_batch
  end

  defp do_serialize_value(val, {:records_array, schema}) do
    len = do_serialize_value(length(val), :int32)
    do_serialize_records(schema, val, len)
  end

  defp do_serialize_value(val, :record_bytes) do
    do_serialize_value(byte_size(val), :varint) <> val
  end

  defp do_serialize_value(val, {:record_headers, schema}) do
    len = do_serialize_value(length(val), :varint)
    do_serialize(schema, val, len)
  end

  defp do_serialize_value(val, :unsigned_varint) when val <= 127, do: <<val>>

  defp do_serialize_value(val, :unsigned_varint),
    do: <<1::1, val::7, do_serialize_value(bsr(val, 7), :unsigned_varint)::binary>>

  defp do_serialize_value(val, :varint) when val >= 0,
    do: do_serialize_value(2 * val, :unsigned_varint)

  defp do_serialize_value(val, :varint) when val < 0,
    do: do_serialize_value(-2 * val - 1, :unsigned_varint)

  defp do_serialize_value(_input_map, {:tag_buffer, []}),
    do: do_serialize_value(0, :unsigned_varint)

  defp do_serialize_value(input_map, {:tag_buffer, tag_schema}) do
    existing_schema = Enum.filter(tag_schema, fn {key, _} -> Map.has_key?(input_map, key) end)
    len = length(existing_schema)
    serialize_tag_buffer(existing_schema, input_map, do_serialize_value(len, :unsigned_varint))
  end

  defp serialize_tag_buffer([], _input_map, acc_data), do: acc_data

  defp serialize_tag_buffer(
         [{key, {{tag, type}, metadata}} | rest_schema],
         %{} = input_map,
         acc_data
       ) do
    raw_value = Map.fetch!(input_map, key)

    value = serialize_value(raw_value, {key, {type, metadata}})
    size = do_serialize_value(byte_size(value) + 1, :unsigned_varint)
    tag = do_serialize_value(tag, :unsigned_varint)

    final_val = tag <> size <> value

    serialize_tag_buffer(rest_schema, input_map, acc_data <> final_val)
  end
end
