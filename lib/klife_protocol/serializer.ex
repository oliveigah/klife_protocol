defmodule KlifeProtocol.Serializer do
  import Bitwise

  alias KlifeProtocol.RecordBatch

  @compile {:inline, serialize_value: 3}

  def execute(%{} = input, schema, append_list \\ []) do
    do_serialize(schema, input, append_list)
  end

  #  Base case for the main function
  defp do_serialize([], map, result_data) when is_map(map), do: result_data
  #  Base case for arrays
  defp do_serialize(_schema, [], result_data), do: result_data

  # Used for tag buffer
  defp do_serialize([{_key, {:tag_buffer, _} = type} | rest_schema], %{} = input_map, acc_data) do
    val = do_serialize_value(input_map, type)
    do_serialize(rest_schema, input_map, [acc_data, val])
  end

  # Main function - The recursion always start here
  defp do_serialize([{key, type} | rest_schema], %{} = input_map, acc_data) do
    val = serialize_value(Map.get(input_map, key), key, type)
    do_serialize(rest_schema, input_map, [acc_data, val])
  end

  # Used for arrays of complex data types
  defp do_serialize(schema, [val | rest_val], acc_data) when is_list(schema) do
    new_acc = do_serialize(schema, val, acc_data)
    do_serialize(schema, rest_val, new_acc)
  end

  # Used for arrays of simple data types
  defp do_serialize(type, [val | rest_val], acc_data) do
    new_val = do_serialize_value(val, type)
    do_serialize(type, rest_val, [acc_data, new_val])
  end

  defp serialize_value(nil, key, {_, %{is_nullable?: false}} = type) do
    raise """
    Serialization error:

    field: #{inspect({key, type})}

    reason: field is not nullable
    """
  end

  defp serialize_value(val, _key, {type, _metadata}), do: do_serialize_value(val, type)

  defp do_serialize_value(true, :boolean), do: <<1>>
  defp do_serialize_value(false, :boolean), do: <<0>>

  defp do_serialize_value(val, :int8), do: <<val::8-signed>>
  defp do_serialize_value(val, :int16), do: <<val::16-signed>>
  defp do_serialize_value(val, :uint16), do: <<val::16>>
  defp do_serialize_value(val, :int32), do: <<val::32-signed>>
  defp do_serialize_value(val, :uint32), do: <<val::32>>
  defp do_serialize_value(val, :int64), do: <<val::64-signed>>

  defp do_serialize_value(val, :float64), do: <<val::float>>

  defp do_serialize_value(nil, :string), do: <<-1::16-signed>>

  defp do_serialize_value(val, :string) when is_binary(val),
    do: [<<byte_size(val)::16-signed>>, val]

  defp do_serialize_value(
         <<p1::binary-size(8), ?-, p2::binary-size(4), ?-, p3::binary-size(4), ?-,
           p4::binary-size(4), ?-, p5::binary-size(12)>>,
         :uuid
       ) do
    Base.decode16!(
      <<p1::binary, p2::binary, p3::binary, p4::binary, p5::binary>>,
      case: :mixed
    )
  end

  defp do_serialize_value(val, :uuid) when is_binary(val) do
    val
    |> String.replace("-", "")
    |> String.downcase()
    |> Base.decode16!(case: :lower)
  end

  defp do_serialize_value(nil, {:object, _schema}) do
    do_serialize_value(-1, :unsigned_varint)
  end

  defp do_serialize_value(val, {:object, schema}) do
    do_serialize(schema, val, [do_serialize_value(1, :unsigned_varint)])
  end

  defp do_serialize_value(nil, :bytes), do: <<-1::32-signed>>

  defp do_serialize_value(val, :bytes), do: [<<byte_size(val)::32-signed>>, val]

  defp do_serialize_value(nil, {:array, _schema}), do: <<-1::32-signed>>

  defp do_serialize_value(val, {:array, schema}),
    do: do_serialize(schema, val, <<length(val)::32-signed>>)

  defp do_serialize_value(nil, :compact_bytes), do: do_serialize_value(0, :unsigned_varint)

  defp do_serialize_value(val, :compact_bytes),
    do: [do_serialize_value(byte_size(val) + 1, :unsigned_varint), val]

  defp do_serialize_value(nil, :compact_string), do: do_serialize_value(0, :unsigned_varint)

  defp do_serialize_value(val, :compact_string),
    do: [do_serialize_value(byte_size(val) + 1, :unsigned_varint), val]

  defp do_serialize_value(nil, {:compact_array, _schema}),
    do: do_serialize_value(0, :unsigned_varint)

  defp do_serialize_value(val, {:compact_array, schema}),
    do: do_serialize(schema, val, do_serialize_value(length(val) + 1, :unsigned_varint))

  defp do_serialize_value(val, :record_batch) do
    serialized_record_batch = RecordBatch.serialize(val)

    len =
      serialized_record_batch
      |> :erlang.iolist_size()
      |> do_serialize_value(:int32)

    [len | serialized_record_batch]
  end

  defp do_serialize_value(val, :compact_record_batch) do
    serialized_record_batch = RecordBatch.serialize(val)

    len =
      serialized_record_batch
      |> :erlang.iolist_size()
      |> then(&(&1 + 1))
      |> do_serialize_value(:unsigned_varint)

    [len | serialized_record_batch]
  end

  defp do_serialize_value(val, {:records_array, schema}) do
    serialize_records(schema, val, [do_serialize_value(length(val), :int32)])
  end

  defp do_serialize_value(nil, :record_bytes), do: [do_serialize_value(-1, :varint)]

  defp do_serialize_value(val, :record_bytes),
    do: [do_serialize_value(byte_size(val), :varint), val]

  defp do_serialize_value(nil, {:record_headers, schema}) do
    do_serialize_value([], {:record_headers, schema})
  end

  defp do_serialize_value(val, {:record_headers, schema}) do
    do_serialize(schema, val, [do_serialize_value(length(val), :varint)])
  end

  defp do_serialize_value(val, :unsigned_varint) when val < 128, do: <<val>>

  defp do_serialize_value(val, :unsigned_varint) when val < 16_384,
    do: <<1::1, val::7, bsr(val, 7)::8>>

  defp do_serialize_value(val, :unsigned_varint) when val < 2_097_152,
    do: <<1::1, val::7, 1::1, bsr(val, 7)::7, bsr(val, 14)::8>>

  defp do_serialize_value(val, :unsigned_varint) when val < 268_435_456,
    do: <<1::1, val::7, 1::1, bsr(val, 7)::7, 1::1, bsr(val, 14)::7, bsr(val, 21)::8>>

  defp do_serialize_value(val, :unsigned_varint),
    do: [<<1::1, val::7>>, do_serialize_value(bsr(val, 7), :unsigned_varint)]

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

    value = serialize_value(raw_value, key, {type, metadata})
    size = do_serialize_value(:erlang.iolist_size(value) + 1, :unsigned_varint)
    tag = do_serialize_value(tag, :unsigned_varint)

    final_val = [tag, size, value]

    serialize_tag_buffer(rest_schema, input_map, [acc_data, final_val])
  end

  defp serialize_records(_schema, [], acc_data), do: acc_data

  defp serialize_records(schema, [val | rest_val], acc_data) when is_list(schema) do
    serialized_record = do_serialize(schema, val, [])
    serialized_len = do_serialize_value(:erlang.iolist_size(serialized_record), :varint)
    serialize_records(schema, rest_val, [acc_data, serialized_len, serialized_record])
  end
end
