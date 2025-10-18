defmodule KlifeProtocol.Deserializer do
  import Bitwise
  alias KlifeProtocol.RecordBatch
  @compile {:inline, do_deserialize_value: 2}
  @compile {:inline, deserialize_unsigned_varint: 1}
  @compile {:inline, do_deserialize: 3}

  def execute(data, schema) do
    {:ok, do_deserialize(schema, data, %{})}
  catch
    reason ->
      {:error, reason}
  end

  defp do_deserialize(schema, data, result) do
    case schema do
      [{_key, {:tag_buffer, _} = type} | rest_schema] ->
        {val, rest_data} = do_deserialize_value(type, data)
        new_result = Map.merge(result, val)
        do_deserialize(rest_schema, rest_data, new_result)

      [{key, {type, _}} | rest_schema] ->
        {val, rest_data} = do_deserialize_value(type, data)
        new_result = Map.put(result, key, val)
        do_deserialize(rest_schema, rest_data, new_result)

      [] ->
        {result, data}
    end
  end

  defp do_deserialize_value(:boolean, data) do
    case data do
      <<1, rest_data::binary>> -> {true, rest_data}
      <<0, rest_data::binary>> -> {false, rest_data}
    end
  end

  defp do_deserialize_value(:int8, data) do
    <<val::8-signed, rest_data::binary>> = data
    {val, rest_data}
  end

  defp do_deserialize_value(:int16, data) do
    <<val::16-signed, rest_data::binary>> = data
    {val, rest_data}
  end

  defp do_deserialize_value(:uint16, data) do
    <<val::16, rest_data::binary>> = data
    {val, rest_data}
  end

  defp do_deserialize_value(:int32, data) do
    <<val::32-signed, rest_data::binary>> = data
    {val, rest_data}
  end

  defp do_deserialize_value(:uint32, data) do
    <<val::32, rest_data::binary>> = data
    {val, rest_data}
  end

  defp do_deserialize_value(:int64, data) do
    <<val::64-signed, rest_data::binary>> = data
    {val, rest_data}
  end

  defp do_deserialize_value(:float64, data) do
    <<val::float, rest_data::binary>> = data
    {val, rest_data}
  end

  defp do_deserialize_value(:string, data) do
    case data do
      <<-1::16-signed, rest_data::binary>> -> {nil, rest_data}
      <<len::16-signed, val::size(len)-binary, rest::binary>> -> {:binary.copy(val), rest}
    end
  end

  defp do_deserialize_value(:bytes, data) do
    case data do
      <<-1::32-signed, rest_data::binary>> -> {nil, rest_data}
      <<len::32-signed, val::size(len)-binary, rest::binary>> -> {:binary.copy(val), rest}
    end
  end

  defp do_deserialize_value(:uuid, data) do
    <<val::binary-size(16), rest_data::binary>> = data

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

  defp do_deserialize_value({:object, schema}, data) do
    case data do
      # 255 is -1 encoded as unsigned_varint
      <<255, rest_data::binary>> -> {nil, rest_data}
      <<1, rest_data::binary>> -> do_deserialize(schema, rest_data, %{})
    end
  end

  defp do_deserialize_value({:array, schema}, data) do
    case data do
      <<-1::32-signed, rest_data::binary>> -> {nil, rest_data}
      <<0::32-signed, rest_data::binary>> -> {[], rest_data}
      <<len::32-signed, rest_data::binary>> -> deserialize_array(rest_data, len, schema, [])
    end
  end

  defp do_deserialize_value(:compact_bytes, data) do
    {len, rest_binary} = do_deserialize_value(:unsigned_varint, data)

    if len > 0 do
      len = len - 1
      <<val::binary-size(len), rest_binary::binary>> = rest_binary
      {:binary.copy(val), rest_binary}
    else
      {nil, rest_binary}
    end
  end

  defp do_deserialize_value(:compact_string, data) do
    {len, rest_binary} = do_deserialize_value(:unsigned_varint, data)

    if len > 0 do
      len = len - 1
      <<val::binary-size(len), rest_binary::binary>> = rest_binary
      {:binary.copy(val), rest_binary}
    else
      {nil, rest_binary}
    end
  end

  defp do_deserialize_value({:compact_array, schema}, data) do
    {len, rest_binary} = do_deserialize_value(:unsigned_varint, data)

    if len > 0,
      do: deserialize_array(rest_binary, len - 1, schema, []),
      else: {nil, rest_binary}
  end

  defp do_deserialize_value(:unsigned_varint, data) do
    deserialize_unsigned_varint(data)
  end

  defp do_deserialize_value(:varint, data) do
    case deserialize_unsigned_varint(data) do
      {val, rest_binary} when rem(val, 2) == 0 ->
        {trunc(val / 2), rest_binary}

      {val, rest_binary} ->
        {trunc(-1 * ceil(val / 2)), rest_binary}
    end
  end

  defp do_deserialize_value({:tag_buffer, tagged_fields}, data) do
    {len, rest_binary} = do_deserialize_value(:unsigned_varint, data)

    if len > 0,
      do: deserialize_tag_buffer(rest_binary, len, tagged_fields, %{}),
      else: {%{}, rest_binary}
  end

  defp do_deserialize_value(:record_batch, data) do
    {len, rest_binary} = do_deserialize_value(:int32, data)
    <<rest_binary::size(len)-binary, rest::binary>> = rest_binary
    {resp, <<>>} = deserialize_record_batch(rest_binary, [])
    {resp, rest}
  end

  defp do_deserialize_value(:compact_record_batch, data) do
    {len, rest_binary} = do_deserialize_value(:unsigned_varint, data)
    <<rest_binary::size(len - 1)-binary, rest::binary>> = rest_binary
    {resp, <<>>} = deserialize_record_batch(rest_binary, [])
    {resp, rest}
  end

  defp do_deserialize_value({:records_array, schema}, data) do
    {len, rest_binary} = do_deserialize_value(:int32, data)
    deserialize_records_array(rest_binary, len, schema, [])
  end

  defp do_deserialize_value(:record_bytes, data) do
    case do_deserialize_value(:varint, data) do
      {-1, rest_binary} ->
        {nil, rest_binary}

      {0, rest_binary} ->
        {<<>>, rest_binary}

      {len, rest_binary} ->
        <<record::binary-size(len), rest::binary>> = rest_binary
        {:binary.copy(record), rest}
    end
  end

  defp do_deserialize_value({:record_headers, schema}, data) do
    case do_deserialize_value(:varint, data) do
      {-1, rest_binary} ->
        {nil, rest_binary}

      {0, rest_binary} ->
        {[], rest_binary}

      {len, rest_binary} ->
        deserialize_record_headers(rest_binary, len, schema, [])
    end
  end

  defp deserialize_tag_buffer(rest_data, 0, _tagged_fields, result),
    do: {result, rest_data}

  defp deserialize_tag_buffer(data, len, tagged_fields, result) do
    {field_tag, rest_binary} = do_deserialize_value(:unsigned_varint, data)
    {field_len, rest_binary} = do_deserialize_value(:unsigned_varint, rest_binary)
    field_len = field_len - 1

    case Map.get(tagged_fields, field_tag) do
      nil ->
        <<_::field_len*8, rest_binary::binary>> = rest_binary
        deserialize_tag_buffer(rest_binary, len - 1, tagged_fields, result)

      {{field_name, field_schema}, _} ->
        {field_value, rest_binary} = do_deserialize_value(field_schema, rest_binary)
        new_result = Map.put(result, field_name, field_value)
        deserialize_tag_buffer(rest_binary, len - 1, tagged_fields, new_result)
    end
  end

  defp deserialize_array(rest_data, 0, _schema, result),
    do: {Enum.reverse(result), rest_data}

  defp deserialize_array(data, len, schema, acc_result) when is_list(schema) do
    {new_result, rest_data} = do_deserialize(schema, data, %{})
    deserialize_array(rest_data, len - 1, schema, [new_result | acc_result])
  end

  defp deserialize_array(data, len, type, acc_result) do
    {new_result, rest_data} = do_deserialize_value(type, data)
    deserialize_array(rest_data, len - 1, type, [new_result | acc_result])
  end

  def deserialize_unsigned_varint(data, acc \\ 0, counter \\ 0) do
    <<msb::1, rest_byte::7, rest_data::binary>> = data

    if msb == 0,
      do: {acc + bsl(rest_byte, counter * 7), rest_data},
      else: deserialize_unsigned_varint(rest_data, acc + bsl(rest_byte, counter * 7), counter + 1)
  end

  def deserialize_records_array(rest_data, 0, _schema, acc_result),
    do: {Enum.reverse(acc_result), rest_data}

  def deserialize_records_array(data, len, schema, acc_result) do
    {_rec_size, rest_bin} = do_deserialize_value(:varint, data)
    {rec, rest_bin} = do_deserialize(schema, rest_bin, %{})
    deserialize_records_array(rest_bin, len - 1, schema, [rec | acc_result])
  end

  def deserialize_record_headers(rest_data, 0, _schema, acc_result),
    do: {Enum.reverse(acc_result), rest_data}

  def deserialize_record_headers(data, len, schema, acc_result) do
    {header, rest_bin} = do_deserialize(schema, data, %{})
    deserialize_record_headers(rest_bin, len - 1, schema, [header | acc_result])
  end

  def deserialize_record_batch(data, acc_result) when byte_size(data) < 12,
    do: {Enum.reverse(acc_result), <<>>}

  def deserialize_record_batch(data, acc_result) do
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
