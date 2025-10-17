defmodule KlifeProtocol.Deserializer do
  import Bitwise
  alias KlifeProtocol.RecordBatch

  def execute(<<data::binary>>, schema) do
    {:ok, do_deserialize(schema, data, %{})}
  catch
    reason ->
      {:error, reason}
  end

  # Optimized main deserialize loop - reduced pattern matching
  defp do_deserialize([], <<data::binary>>, result), do: {result, data}

  defp do_deserialize([{key, schema} | rest_schema], <<data::binary>>, acc_result) do
    case schema do
      {:tag_buffer, _} = tag_schema ->
        {val, rest_data} = do_deserialize_value(data, tag_schema)
        new_result = Map.merge(acc_result, val)
        do_deserialize(rest_schema, rest_data, new_result)

      {type, _} ->
        # Directly inline deserialize_value to avoid wrapper overhead
        {val, rest_data} = do_deserialize_value(data, type)
        new_result = Map.put(acc_result, key, val)
        do_deserialize(rest_schema, rest_data, new_result)
    end
  end

  # Optimized deserialize_value with most frequent types first based on profiling
  defp do_deserialize_value(<<data::binary>>, type) do
    case type do
      # Most frequent: varints (used for lengths and record metadata)
      :unsigned_varint ->
        case data do
          <<b0::8, rest::binary>> when b0 < 128 ->
            {b0, rest}

          <<b0::8, b1::8, rest::binary>> when b1 < 128 ->
            {(b0 &&& 0x7F) ||| (b1 &&& 0x7F) <<< 7, rest}

          <<b0::8, b1::8, b2::8, rest::binary>> when b2 < 128 ->
            {(b0 &&& 0x7F) ||| (b1 &&& 0x7F) <<< 7 ||| (b2 &&& 0x7F) <<< 14, rest}

          _ ->
            fast_unsigned_varint(data)
        end

      :varint ->
        {val, rest} =
          case data do
            <<b0::8, rest::binary>> when b0 < 128 ->
              {b0, rest}

            <<b0::8, b1::8, rest::binary>> when b1 < 128 ->
              {(b0 &&& 0x7F) ||| (b1 &&& 0x7F) <<< 7, rest}

            <<b0::8, b1::8, b2::8, rest::binary>> when b2 < 128 ->
              {(b0 &&& 0x7F) ||| (b1 &&& 0x7F) <<< 7 ||| (b2 &&& 0x7F) <<< 14, rest}

            _ ->
              fast_unsigned_varint(data)
          end

        if rem(val, 2) == 0 do
          # Use bitshift instead of division
          {val >>> 1, rest}
        else
          # More efficient negative calculation
          {-((val + 1) >>> 1), rest}
        end

      # Record bytes - very frequent in records array
      :record_bytes ->
        {val, rest} =
          case data do
            <<b0::8, rest::binary>> when b0 < 128 ->
              {b0, rest}

            <<b0::8, b1::8, rest::binary>> when b1 < 128 ->
              {(b0 &&& 0x7F) ||| (b1 &&& 0x7F) <<< 7, rest}

            _ ->
              fast_unsigned_varint(data)
          end

        len = if rem(val, 2) == 0, do: val >>> 1, else: -((val + 1) >>> 1)

        cond do
          len == -1 ->
            {nil, rest}

          len == 0 ->
            {<<>>, rest}

          true ->
            <<record::binary-size(len), rest::binary>> = rest
            {record, rest}
        end

      # Integers - frequently used for offsets and metadata
      :int8 ->
        <<val::8-signed, rest::binary>> = data
        {val, rest}

      :int16 ->
        <<val::16-signed, rest::binary>> = data
        {val, rest}

      :uint16 ->
        <<val::16, rest::binary>> = data
        {val, rest}

      :int32 ->
        <<val::32-signed, rest::binary>> = data
        {val, rest}

      :uint32 ->
        <<val::32, rest::binary>> = data
        {val, rest}

      :int64 ->
        <<val::64-signed, rest::binary>> = data
        {val, rest}

      :float64 ->
        <<val::float, rest::binary>> = data
        {val, rest}

      # Boolean
      :boolean ->
        <<val::8, rest::binary>> = data
        {val == 1, rest}

      # Strings
      :string ->
        <<len::16-signed, rest::binary>> = data

        if len == -1 do
          {nil, rest}
        else
          <<val::binary-size(len), rest::binary>> = rest
          {val, rest}
        end

      # Bytes
      :bytes ->
        <<len::32-signed, rest::binary>> = data

        if len == -1 do
          {nil, rest}
        else
          <<val::binary-size(len), rest::binary>> = rest
          {val, rest}
        end

      # UUID
      :uuid ->
        <<val::binary-size(16), rest::binary>> = data

        <<s1::binary-size(4), s2::binary-size(2), s3::binary-size(2), s4::binary-size(2),
          s5::binary-size(6)>> = val

        result =
          [
            Base.encode16(s1, case: :lower),
            "-",
            Base.encode16(s2, case: :lower),
            "-",
            Base.encode16(s3, case: :lower),
            "-",
            Base.encode16(s4, case: :lower),
            "-",
            Base.encode16(s5, case: :lower)
          ]
          |> :erlang.iolist_to_binary()

        {result, rest}

      # Arrays
      {:array, schema} ->
        <<len::32-signed, rest::binary>> = data

        cond do
          len == -1 -> {nil, rest}
          len == 0 -> {[], rest}
          true -> deserialize_array(rest, len, schema, [])
        end

      # Compact types - frequent in Kafka protocol
      :compact_bytes ->
        {len, rest} =
          case data do
            <<b0::8, rest::binary>> when b0 < 128 ->
              {b0, rest}

            <<b0::8, b1::8, rest::binary>> when b1 < 128 ->
              {(b0 &&& 0x7F) ||| (b1 &&& 0x7F) <<< 7, rest}

            <<b0::8, b1::8, b2::8, rest::binary>> when b2 < 128 ->
              {(b0 &&& 0x7F) ||| (b1 &&& 0x7F) <<< 7 ||| (b2 &&& 0x7F) <<< 14, rest}

            _ ->
              fast_unsigned_varint(data)
          end

        if len > 0 do
          actual_len = len - 1
          <<val::binary-size(actual_len), rest::binary>> = rest
          {val, rest}
        else
          {nil, rest}
        end

      :compact_string ->
        {len, rest} =
          case data do
            <<b0::8, rest::binary>> when b0 < 128 ->
              {b0, rest}

            <<b0::8, b1::8, rest::binary>> when b1 < 128 ->
              {(b0 &&& 0x7F) ||| (b1 &&& 0x7F) <<< 7, rest}

            <<b0::8, b1::8, b2::8, rest::binary>> when b2 < 128 ->
              {(b0 &&& 0x7F) ||| (b1 &&& 0x7F) <<< 7 ||| (b2 &&& 0x7F) <<< 14, rest}

            _ ->
              fast_unsigned_varint(data)
          end

        if len > 0 do
          actual_len = len - 1
          <<val::binary-size(actual_len), rest::binary>> = rest
          {val, rest}
        else
          {nil, rest}
        end

      # Compact arrays - inline varint for common cases
      {:compact_array, schema} ->
        {len, rest} =
          case data do
            <<b0::8, rest::binary>> when b0 < 128 ->
              {b0, rest}

            <<b0::8, b1::8, rest::binary>> when b1 < 128 ->
              {(b0 &&& 0x7F) ||| (b1 &&& 0x7F) <<< 7, rest}

            _ ->
              fast_unsigned_varint(data)
          end

        if len > 0 do
          deserialize_array(rest, len - 1, schema, [])
        else
          {nil, rest}
        end

      # Objects
      {:object, schema} ->
        <<first_byte::8, rest::binary>> = data

        cond do
          # -1 as unsigned varint
          first_byte == 255 -> {nil, rest}
          first_byte == 1 -> do_deserialize(schema, rest, %{})
          true -> raise "Unexpected object marker: #{first_byte}"
        end

      # Tag buffer - inline varint
      {:tag_buffer, tagged_fields} ->
        {len, rest} =
          case data do
            <<b0::8, rest::binary>> when b0 < 128 ->
              {b0, rest}

            <<b0::8, b1::8, rest::binary>> when b1 < 128 ->
              {(b0 &&& 0x7F) ||| (b1 &&& 0x7F) <<< 7, rest}

            _ ->
              fast_unsigned_varint(data)
          end

        if len > 0 do
          deserialize_tag_buffer(rest, len, tagged_fields, %{})
        else
          {%{}, rest}
        end

      # Record batches
      :record_batch ->
        <<len::32-signed, batch_data::binary-size(len), rest::binary>> = data
        {resp, <<>>} = deserialize_record_batch(batch_data, [])
        {resp, rest}

      :compact_record_batch ->
        {len, rest} =
          case data do
            <<b0::8, rest::binary>> when b0 < 128 ->
              {b0, rest}

            <<b0::8, b1::8, rest::binary>> when b1 < 128 ->
              {(b0 &&& 0x7F) ||| (b1 &&& 0x7F) <<< 7, rest}

            _ ->
              fast_unsigned_varint(data)
          end

        actual_len = len - 1
        <<batch_data::binary-size(actual_len), rest::binary>> = rest
        {resp, <<>>} = deserialize_record_batch(batch_data, [])
        {resp, rest}

      # Records array
      {:records_array, schema} ->
        <<len::32-signed, rest::binary>> = data
        deserialize_records_array(rest, len, schema, [])

      # Record headers
      {:record_headers, schema} ->
        {val, rest} =
          case data do
            <<b0::8, rest::binary>> when b0 < 128 ->
              {b0, rest}

            <<b0::8, b1::8, rest::binary>> when b1 < 128 ->
              {(b0 &&& 0x7F) ||| (b1 &&& 0x7F) <<< 7, rest}

            _ ->
              fast_unsigned_varint(data)
          end

        len = if rem(val, 2) == 0, do: val >>> 1, else: -((val + 1) >>> 1)

        cond do
          len == -1 -> {nil, rest}
          len == 0 -> {[], rest}
          true -> deserialize_record_headers(rest, len, schema, [])
        end
    end
  end

  # Optimized unsigned varint - unrolled loop for common cases
  defp fast_unsigned_varint(<<b0::8, rest::binary>>) when b0 < 128 do
    {b0, rest}
  end

  defp fast_unsigned_varint(<<b0::8, b1::8, rest::binary>>) when b1 < 128 do
    {(b0 &&& 0x7F) ||| (b1 &&& 0x7F) <<< 7, rest}
  end

  defp fast_unsigned_varint(<<b0::8, b1::8, b2::8, rest::binary>>) when b2 < 128 do
    {(b0 &&& 0x7F) ||| (b1 &&& 0x7F) <<< 7 ||| (b2 &&& 0x7F) <<< 14, rest}
  end

  defp fast_unsigned_varint(<<b0::8, b1::8, b2::8, b3::8, rest::binary>>) when b3 < 128 do
    {(b0 &&& 0x7F) ||| (b1 &&& 0x7F) <<< 7 ||| (b2 &&& 0x7F) <<< 14 ||| (b3 &&& 0x7F) <<< 21,
     rest}
  end

  defp fast_unsigned_varint(<<b0::8, b1::8, b2::8, b3::8, b4::8, rest::binary>>) when b4 < 128 do
    {(b0 &&& 0x7F) ||| (b1 &&& 0x7F) <<< 7 ||| (b2 &&& 0x7F) <<< 14 |||
       (b3 &&& 0x7F) <<< 21 ||| (b4 &&& 0x7F) <<< 28, rest}
  end

  # Fallback for larger varints
  defp fast_unsigned_varint(data) do
    deserialize_unsigned_varint(data, 0, 0)
  end

  # Tag buffer deserialization
  defp deserialize_tag_buffer(<<rest_data::binary>>, 0, _tagged_fields, result),
    do: {result, rest_data}

  defp deserialize_tag_buffer(<<data::binary>>, len, tagged_fields, result) do
    # Inline varint parsing for tag buffer fields
    {field_tag, rest} =
      case data do
        <<b0::8, rest::binary>> when b0 < 128 ->
          {b0, rest}

        <<b0::8, b1::8, rest::binary>> when b1 < 128 ->
          {(b0 &&& 0x7F) ||| (b1 &&& 0x7F) <<< 7, rest}

        _ ->
          fast_unsigned_varint(data)
      end

    {field_len, rest} =
      case rest do
        <<b0::8, rest2::binary>> when b0 < 128 ->
          {b0, rest2}

        <<b0::8, b1::8, rest2::binary>> when b1 < 128 ->
          {(b0 &&& 0x7F) ||| (b1 &&& 0x7F) <<< 7, rest2}

        _ ->
          fast_unsigned_varint(rest)
      end

    field_len = field_len - 1

    case Map.get(tagged_fields, field_tag) do
      nil ->
        <<_::binary-size(field_len), rest::binary>> = rest
        deserialize_tag_buffer(rest, len - 1, tagged_fields, result)

      {{field_name, field_schema}, _} ->
        {field_value, rest} = do_deserialize_value(rest, field_schema)
        new_result = Map.put(result, field_name, field_value)
        deserialize_tag_buffer(rest, len - 1, tagged_fields, new_result)
    end
  end

  # Optimized array deserialization
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

  # Original recursive varint for edge cases
  def deserialize_unsigned_varint(<<data::binary>>, acc \\ 0, counter \\ 0) do
    <<msb::1, rest_byte::7, rest_data::binary>> = data
    result = acc ||| rest_byte <<< (counter * 7)

    if msb === 0 do
      {result, rest_data}
    else
      deserialize_unsigned_varint(rest_data, result, counter + 1)
    end
  end

  # Records array deserialization with inline varint
  def deserialize_records_array(<<rest_data::binary>>, 0, _schema, acc_result),
    do: {Enum.reverse(acc_result), rest_data}

  def deserialize_records_array(<<data::binary>>, len, schema, acc_result) do
    # Inline varint parsing for record size
    {val, rest_bin} =
      case data do
        <<b0::8, rest::binary>> when b0 < 128 ->
          {b0, rest}

        <<b0::8, b1::8, rest::binary>> when b1 < 128 ->
          {(b0 &&& 0x7F) ||| (b1 &&& 0x7F) <<< 7, rest}

        _ ->
          fast_unsigned_varint(data)
      end

    _rec_size = if rem(val, 2) == 0, do: val >>> 1, else: -((val + 1) >>> 1)
    {rec, rest_bin} = do_deserialize(schema, rest_bin, %{})
    deserialize_records_array(rest_bin, len - 1, schema, [rec | acc_result])
  end

  # Record headers deserialization
  def deserialize_record_headers(<<rest_data::binary>>, 0, _schema, acc_result),
    do: {Enum.reverse(acc_result), rest_data}

  def deserialize_record_headers(<<data::binary>>, len, schema, acc_result) do
    {header, rest_bin} = do_deserialize(schema, data, %{})
    deserialize_record_headers(rest_bin, len - 1, schema, [header | acc_result])
  end

  # Record batch deserialization
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
