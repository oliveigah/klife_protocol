defmodule KlifeProtocol.Deserializer do
  import Bitwise
  alias KlifeProtocol.RecordBatch
  @compile {:inline, do_deserialize_value: 2}
  @compile {:inline, deserialize_unsigned_varint: 1}
  @compile {:inline, do_deserialize: 3}
  @compile {:inline, maybe_copy: 1}

  def execute(data, schema) do
    {:ok, do_deserialize(schema, data, [])}
  catch
    reason ->
      {:error, reason}
  end

  # The result is accumulated as a key value list and converted to a map
  # only once at the end, which is cheaper than updating a map per field.
  defp do_deserialize(schema, data, acc) do
    case schema do
      [{_key, {:tag_buffer, _} = type} | rest_schema] ->
        {val, rest_data} = do_deserialize_value(type, data)
        do_deserialize(rest_schema, rest_data, val ++ acc)

      [{key, {type, _}} | rest_schema] ->
        {val, rest_data} = do_deserialize_value(type, data)
        do_deserialize(rest_schema, rest_data, [{key, val} | acc])

      [] ->
        {:maps.from_list(acc), data}
    end
  end

  # Copies the value out of the underlying received buffer, so that holding
  # a field value does not prevent the whole message binary from being
  # garbage collected. When the value spans at least half of the underlying
  # buffer the reference is kept instead, since the copy would not save
  # relevant memory.
  defp maybe_copy(val) do
    if byte_size(val) * 2 >= :binary.referenced_byte_size(val),
      do: val,
      else: :binary.copy(val)
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
      <<len::16-signed, val::size(len)-binary, rest::binary>> -> {maybe_copy(val), rest}
    end
  end

  defp do_deserialize_value(:bytes, data) do
    case data do
      <<-1::32-signed, rest_data::binary>> -> {nil, rest_data}
      <<len::32-signed, val::size(len)-binary, rest::binary>> -> {maybe_copy(val), rest}
    end
  end

  defp do_deserialize_value(:uuid, data) do
    <<val::binary-size(16), rest_data::binary>> = data

    <<p1::binary-size(8), p2::binary-size(4), p3::binary-size(4), p4::binary-size(4),
      p5::binary-size(12)>> = Base.encode16(val, case: :lower)

    result = <<p1::binary, ?-, p2::binary, ?-, p3::binary, ?-, p4::binary, ?-, p5::binary>>

    {result, rest_data}
  end

  defp do_deserialize_value({:object, schema}, data) do
    case data do
      # 255 is -1 encoded as unsigned_varint
      <<255, rest_data::binary>> -> {nil, rest_data}
      <<1, rest_data::binary>> -> do_deserialize(schema, rest_data, [])
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
    {len, rest_binary} = deserialize_unsigned_varint(data)

    if len > 0 do
      len = len - 1
      <<val::binary-size(len), rest_binary::binary>> = rest_binary
      {maybe_copy(val), rest_binary}
    else
      {nil, rest_binary}
    end
  end

  defp do_deserialize_value(:compact_string, data) do
    {len, rest_binary} = deserialize_unsigned_varint(data)

    if len > 0 do
      len = len - 1
      <<val::binary-size(len), rest_binary::binary>> = rest_binary
      {maybe_copy(val), rest_binary}
    else
      {nil, rest_binary}
    end
  end

  defp do_deserialize_value({:compact_array, schema}, data) do
    {len, rest_binary} = deserialize_unsigned_varint(data)

    if len > 0,
      do: deserialize_array(rest_binary, len - 1, schema, []),
      else: {nil, rest_binary}
  end

  defp do_deserialize_value(:unsigned_varint, data) do
    deserialize_unsigned_varint(data)
  end

  defp do_deserialize_value(:varint, data) do
    {val, rest_binary} = deserialize_unsigned_varint(data)
    # zigzag decode
    {bxor(bsr(val, 1), -band(val, 1)), rest_binary}
  end

  defp do_deserialize_value({:tag_buffer, tagged_fields}, data) do
    {len, rest_binary} = deserialize_unsigned_varint(data)

    if len > 0,
      do: deserialize_tag_buffer(rest_binary, len, tagged_fields, []),
      else: {[], rest_binary}
  end

  defp do_deserialize_value(:record_batch, data) do
    {len, rest_binary} = do_deserialize_value(:int32, data)
    <<rest_binary::size(len)-binary, rest::binary>> = rest_binary
    {resp, <<>>} = deserialize_record_batch(rest_binary, [])
    {resp, rest}
  end

  defp do_deserialize_value(:compact_record_batch, data) do
    {len, rest_binary} = deserialize_unsigned_varint(data)
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
        {maybe_copy(record), rest}
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

  # Tagged fields are encoded as (tag, size, payload) where size is the exact
  # byte size of the payload, so unknown tags are skipped by dropping size
  # bytes (KIP-482). Tagged structs are encoded as their raw fields, without
  # the presence byte used by nullable struct fields elsewhere, since the tag
  # itself already conveys presence.
  defp deserialize_tag_buffer(data, len, tagged_fields, result) do
    {field_tag, rest_binary} = deserialize_unsigned_varint(data)
    {field_len, rest_binary} = deserialize_unsigned_varint(rest_binary)

    case Map.get(tagged_fields, field_tag) do
      nil ->
        <<_::field_len*8, rest_binary::binary>> = rest_binary
        deserialize_tag_buffer(rest_binary, len - 1, tagged_fields, result)

      {{field_name, {:object, schema}}, %{is_nullable?: false}} ->
        {field_value, rest_binary} = do_deserialize(schema, rest_binary, [])

        deserialize_tag_buffer(rest_binary, len - 1, tagged_fields, [
          {field_name, field_value} | result
        ])

      {{field_name, field_schema}, _} ->
        {field_value, rest_binary} = do_deserialize_value(field_schema, rest_binary)
        deserialize_tag_buffer(rest_binary, len - 1, tagged_fields, [
          {field_name, field_value} | result
        ])
    end
  end

  defp deserialize_array(rest_data, 0, _schema, result),
    do: {Enum.reverse(result), rest_data}

  defp deserialize_array(data, len, schema, acc_result) when is_list(schema) do
    {new_result, rest_data} = do_deserialize(schema, data, [])
    deserialize_array(rest_data, len - 1, schema, [new_result | acc_result])
  end

  defp deserialize_array(data, len, type, acc_result) do
    {new_result, rest_data} = do_deserialize_value(type, data)
    deserialize_array(rest_data, len - 1, type, [new_result | acc_result])
  end

  def deserialize_unsigned_varint(data) do
    case data do
      <<0::1, b1::7, rest::binary>> ->
        {b1, rest}

      <<1::1, b1::7, 0::1, b2::7, rest::binary>> ->
        {b1 ||| b2 <<< 7, rest}

      <<1::1, b1::7, 1::1, b2::7, 0::1, b3::7, rest::binary>> ->
        {b1 ||| b2 <<< 7 ||| b3 <<< 14, rest}

      <<1::1, b1::7, 1::1, b2::7, 1::1, b3::7, 0::1, b4::7, rest::binary>> ->
        {b1 ||| b2 <<< 7 ||| b3 <<< 14 ||| b4 <<< 21, rest}

      <<1::1, b1::7, 1::1, b2::7, 1::1, b3::7, 1::1, b4::7, rest::binary>> ->
        {val, rest} = deserialize_unsigned_varint(rest)
        {b1 ||| b2 <<< 7 ||| b3 <<< 14 ||| b4 <<< 21 ||| val <<< 28, rest}
    end
  end

  def deserialize_records_array(rest_data, 0, _schema, acc_result),
    do: {Enum.reverse(acc_result), rest_data}

  def deserialize_records_array(data, len, schema, acc_result) do
    {_rec_size, rest_bin} = do_deserialize_value(:varint, data)
    {rec, rest_bin} = do_deserialize(schema, rest_bin, [])
    deserialize_records_array(rest_bin, len - 1, schema, [rec | acc_result])
  end

  def deserialize_record_headers(rest_data, 0, _schema, acc_result),
    do: {Enum.reverse(acc_result), rest_data}

  def deserialize_record_headers(data, len, schema, acc_result) do
    {header, rest_bin} = do_deserialize(schema, data, [])
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
