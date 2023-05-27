defmodule KlifeProtocol.Deserializer do
  import Bitwise
  alias KlifeProtocol.RecordBatch

  def execute(<<data::binary>>, schema) do
    {:ok, do_deserialize(schema, data, %{})}
  catch
    reason ->
      {:error, reason}
  end

  defp do_deserialize([], <<data::binary>>, result), do: {result, data}

  defp do_deserialize(
         [{_key, {:tag_buffer, _} = schema} | rest_schema],
         <<data::binary>>,
         acc_result
       ) do
    {val, rest_data} = do_deserialize_value(data, schema)
    new_result = Map.merge(acc_result, val)
    do_deserialize(rest_schema, rest_data, new_result)
  end

  defp do_deserialize([{key, {_type, _} = schema} | rest_schema], <<data::binary>>, acc_result) do
    {val, rest_data} = deserialize_value(data, schema)
    new_result = Map.put(acc_result, key, val)
    do_deserialize(rest_schema, rest_data, new_result)
  end

  defp deserialize_value(<<val::binary>>, {type, _}), do: do_deserialize_value(val, type)

  defp do_deserialize_value(<<1, rest_data::binary>>, :boolean), do: {true, rest_data}
  defp do_deserialize_value(<<0, rest_data::binary>>, :boolean), do: {false, rest_data}

  defp do_deserialize_value(<<val::8-signed, rest_data::binary>>, :int8), do: {val, rest_data}
  defp do_deserialize_value(<<val::16-signed, rest_data::binary>>, :int16), do: {val, rest_data}
  defp do_deserialize_value(<<val::16, rest_data::binary>>, :uint16), do: {val, rest_data}
  defp do_deserialize_value(<<val::32-signed, rest_data::binary>>, :int32), do: {val, rest_data}
  defp do_deserialize_value(<<val::32, rest_data::binary>>, :uint32), do: {val, rest_data}
  defp do_deserialize_value(<<val::64-signed, rest_data::binary>>, :int64), do: {val, rest_data}

  defp do_deserialize_value(<<val::float, rest_data::binary>>, :float64), do: {val, rest_data}

  defp do_deserialize_value(<<-1::16-signed, rest_data::binary>>, :string), do: {nil, rest_data}

  defp do_deserialize_value(<<len::16-signed, val::size(len)-binary, rest::binary>>, :string),
    do: {val, rest}

  defp do_deserialize_value(<<-1::32-signed, rest_data::binary>>, :bytes), do: {nil, rest_data}

  defp do_deserialize_value(<<len::32-signed, val::size(len)-binary, rest::binary>>, :bytes),
    do: {val, rest}

  defp do_deserialize_value(<<val::binary-size(16), rest_data::binary>>, :uuid) do
    <<
      s1::binary-size(4),
      s2::binary-size(2),
      s3::binary-size(2),
      s4::binary-size(2),
      s5::binary-size(6)
    >> = val

    result =
      [s1, s2, s3, s4, s5]
      |> Enum.map(&Base.encode16(&1, case: :lower))
      |> Enum.join("-")

    {result, rest_data}
  end

  defp do_deserialize_value(<<-1::32-signed, rest_data::binary>>, {:array, _schema}),
    do: {nil, rest_data}

  defp do_deserialize_value(<<0::32-signed, rest_data::binary>>, {:array, _schema}),
    do: {[], rest_data}

  defp do_deserialize_value(<<len::32-signed, rest_data::binary>>, {:array, schema}),
    do: deserialize_array(rest_data, len, schema, [])

  defp do_deserialize_value(<<data::binary>>, :compact_bytes) do
    {len, rest_binary} = do_deserialize_value(data, :unsigned_varint)

    if len > 0 do
      len = len - 1
      <<val::binary-size(len), rest_binary::binary>> = rest_binary
      {val, rest_binary}
    else
      {nil, rest_binary}
    end
  end

  defp do_deserialize_value(<<data::binary>>, :compact_string) do
    {len, rest_binary} = do_deserialize_value(data, :unsigned_varint)

    if len > 0 do
      len = len - 1
      <<val::binary-size(len), rest_binary::binary>> = rest_binary
      {val, rest_binary}
    else
      {nil, rest_binary}
    end
  end

  defp do_deserialize_value(<<data::binary>>, {:compact_array, schema}) do
    {len, rest_binary} = do_deserialize_value(data, :unsigned_varint)
    if len > 0, do: deserialize_array(rest_binary, len - 1, schema, []), else: {nil, rest_binary}
  end

  defp do_deserialize_value(<<data::binary>>, :unsigned_varint),
    do: deserialize_unsigned_varint(data)

  defp do_deserialize_value(<<data::binary>>, :varint) do
    case deserialize_unsigned_varint(data) do
      {val, rest_binary} when rem(val, 2) == 0 ->
        {trunc(val / 2), rest_binary}

      {val, rest_binary} ->
        {trunc(-1 * ceil(val / 2)), rest_binary}
    end
  end

  defp do_deserialize_value(<<data::binary>>, {:tag_buffer, tagged_fields}) do
    {len, rest_binary} = do_deserialize_value(data, :unsigned_varint)

    if len > 0,
      do: deserialize_tag_buffer(rest_binary, len, tagged_fields, %{}),
      else: {%{}, rest_binary}
  end

  defp do_deserialize_value(<<data::binary>>, :record_batch) do
    {len, rest_binary} = do_deserialize_value(data, :int32)
    <<rest_binary::size(len)-binary, rest::binary>> = rest_binary
    {resp, <<>>} = deserialize_record_batch(rest_binary, [])
    {resp, rest}
  end

  defp do_deserialize_value(<<data::binary>>, :compact_record_batch) do
    {len, rest_binary} = do_deserialize_value(data, :unsigned_varint)
    <<rest_binary::size(len - 1)-binary, rest::binary>> = rest_binary
    {resp, <<>>} = deserialize_record_batch(rest_binary, [])
    {resp, rest}
  end

  defp do_deserialize_value(<<data::binary>>, {:records_array, schema}) do
    {len, rest_binary} = do_deserialize_value(data, :int32)
    deserialize_records_array(rest_binary, len, schema, [])
  end

  defp do_deserialize_value(<<data::binary>>, :record_bytes) do
    case do_deserialize_value(data, :varint) do
      {-1, rest_binary} ->
        {nil, rest_binary}

      {0, rest_binary} ->
        {<<>>, rest_binary}

      {len, rest_binary} ->
        <<record::binary-size(len), rest::binary>> = rest_binary
        {record, rest}
    end
  end

  defp do_deserialize_value(<<data::binary>>, {:record_headers, schema}) do
    case do_deserialize_value(data, :varint) do
      {-1, rest_binary} ->
        {nil, rest_binary}

      {0, rest_binary} ->
        {[], rest_binary}

      {len, rest_binary} ->
        deserialize_record_headers(rest_binary, len, schema, [])
    end
  end

  defp deserialize_tag_buffer(<<rest_data::binary>>, 0, _tagged_fields, result),
    do: {result, rest_data}

  defp deserialize_tag_buffer(<<data::binary>>, len, tagged_fields, result) do
    {field_tag, rest_binary} = do_deserialize_value(data, :unsigned_varint)
    {field_len, rest_binary} = do_deserialize_value(rest_binary, :unsigned_varint)
    field_len = field_len - 1

    case Map.get(tagged_fields, field_tag) do
      nil ->
        <<_::field_len*8, rest_binary::binary>> = rest_binary
        deserialize_tag_buffer(rest_binary, len - 1, tagged_fields, result)

      {{field_name, field_schema}, _} ->
        {field_value, rest_binary} = do_deserialize_value(rest_binary, field_schema)
        new_result = Map.put(result, field_name, field_value)
        deserialize_tag_buffer(rest_binary, len - 1, tagged_fields, new_result)
    end
  end

  # TODO: Improve deserialize_array/4 algorithm to insert elements in the array with proper order
  # so we can remove the call to Enum.reverse/1 on return
  defp deserialize_array(<<rest_data::binary>>, 0, _schema, result),
    do: {Enum.reverse(result), rest_data}

  defp deserialize_array(<<data::binary>>, len, schema, acc_result) when is_list(schema) do
    {new_result, rest_data} = do_deserialize(schema, data, %{})
    deserialize_array(rest_data, len - 1, schema, [new_result | acc_result])
  end

  defp deserialize_array(<<data::binary>>, len, type, acc_result) do
    {new_result, rest_data} = do_deserialize_value(data, type)
    deserialize_array(rest_data, len - 1, type, [new_result | acc_result])
  end

  def deserialize_unsigned_varint(<<data::binary>>, acc \\ 0, counter \\ 0) do
    <<msb::1, rest_byte::7, rest_data::binary>> = data
    result = acc + bsl(rest_byte, counter * 7)

    if msb === 0 do
      {result, rest_data}
    else
      deserialize_unsigned_varint(rest_data, result, counter + 1)
    end
  end

  def deserialize_records_array(<<rest_data::binary>>, 0, _schema, acc_result),
    do: {Enum.reverse(acc_result), rest_data}

  def deserialize_records_array(<<data::binary>>, len, schema, acc_result) do
    {_rec_size, rest_bin} = do_deserialize_value(data, :varint)
    {rec, rest_bin} = do_deserialize(schema, rest_bin, %{})
    deserialize_records_array(rest_bin, len - 1, schema, [rec | acc_result])
  end

  def deserialize_record_headers(<<rest_data::binary>>, 0, _schema, acc_result),
    do: {Enum.reverse(acc_result), rest_data}

  def deserialize_record_headers(<<data::binary>>, len, schema, acc_result) do
    {header, rest_bin} = do_deserialize(schema, data, %{})
    deserialize_record_headers(rest_bin, len - 1, schema, [header | acc_result])
  end

  def deserialize_record_batch(<<data::binary>>, acc_result) when byte_size(data) < 12,
    do: {Enum.reverse(acc_result), <<>>}

  def deserialize_record_batch(<<data::binary>>, acc_result) do
    case RecordBatch.deserialize(data) do
      :incomplete_batch ->
        deserialize_record_batch(<<>>, acc_result)

      :redundancy_check_failed ->
        throw(:redudancy_check_failed)

      :unsupported_magic ->
        raise "Unsupported kafka magic version"

      {:error, reason} ->
        raise "Unexpected error. #{inspect(reason)}"

      {res, rest_data} ->
        deserialize_record_batch(rest_data, [res | acc_result])
    end
  end
end
