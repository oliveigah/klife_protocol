defmodule KlifeProtocol.Deserializer do
  import Bitwise

  def execute(data, schema) do
    do_deserialize(schema, data, %{})
  end

  defp do_deserialize([], data, result), do: {result, data}

  defp do_deserialize([{_key, {:tag_buffer, _} = schema} | rest_schema], data, acc_result) do
    {val, rest_data} = do_deserialize_value(data, schema)
    new_result = Map.merge(acc_result, val)
    do_deserialize(rest_schema, rest_data, new_result)
  end

  defp do_deserialize([{key, {_type, _} = schema} | rest_schema], data, acc_result) do
    {val, rest_data} = deserialize_value(data, schema)
    new_result = Map.put(acc_result, key, val)
    do_deserialize(rest_schema, rest_data, new_result)
  end

  defp deserialize_value(val, {type, _}), do: do_deserialize_value(val, type)

  defp do_deserialize_value(<<1, rest_data::binary>>, :boolean), do: {true, rest_data}
  defp do_deserialize_value(<<0, rest_data::binary>>, :boolean), do: {false, rest_data}

  defp do_deserialize_value(<<val::8-signed, rest_data::binary>>, :int8), do: {val, rest_data}
  defp do_deserialize_value(<<val::16-signed, rest_data::binary>>, :int16), do: {val, rest_data}
  defp do_deserialize_value(<<val::32-signed, rest_data::binary>>, :int32), do: {val, rest_data}
  defp do_deserialize_value(<<val::64-signed, rest_data::binary>>, :int64), do: {val, rest_data}

  defp do_deserialize_value(<<-1::16-signed, rest_data::binary>>, :string), do: {nil, rest_data}

  defp do_deserialize_value(
         <<len::16-signed, val::size(len)-binary, rest_data::binary>>,
         :string
       ),
       do: {val, rest_data}

  defp do_deserialize_value(<<-1::32-signed, rest_data::binary>>, {:array, _schema}),
    do: {nil, rest_data}

  defp do_deserialize_value(<<0::32-signed, rest_data::binary>>, {:array, _schema}),
    do: {[], rest_data}

  defp do_deserialize_value(<<len::32-signed, rest_data::binary>>, {:array, schema}),
    do: deserialize_array(rest_data, len, schema, [])

  defp do_deserialize_value(binary, :compact_bytes) do
    {len, rest_binary} = do_deserialize_value(binary, :varint)

    if len > 0 do
      len = len - 1
      <<val::binary-size(len), rest_binary::binary>> = rest_binary
      {val, rest_binary}
    else
      {nil, rest_binary}
    end
  end

  defp do_deserialize_value(binary, :compact_string) do
    {len, rest_binary} = do_deserialize_value(binary, :varint)

    if len > 0 do
      len = len - 1
      <<val::binary-size(len), rest_binary::binary>> = rest_binary
      {val, rest_binary}
    else
      {nil, rest_binary}
    end
  end

  defp do_deserialize_value(binary, {:compact_array, schema}) do
    {len, rest_binary} = do_deserialize_value(binary, :varint)
    if len > 0, do: deserialize_array(rest_binary, len - 1, schema, []), else: {nil, rest_binary}
  end

  defp do_deserialize_value(binary, :varint), do: deserialize_varint(binary)

  defp do_deserialize_value(binary, {:tag_buffer, tagged_fields}) do
    {len, rest_binary} = do_deserialize_value(binary, :varint)

    if len > 0,
      do: deserialize_tag_buffer(rest_binary, len, tagged_fields, %{}),
      else: {%{}, rest_binary}
  end

  defp deserialize_tag_buffer(rest_data, 0, _tagged_fields, result), do: {result, rest_data}

  defp deserialize_tag_buffer(data, len, tagged_fields, result) do
    {field_tag, rest_binary} = do_deserialize_value(data, :varint)
    {field_len, rest_binary} = do_deserialize_value(rest_binary, :varint)
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
  defp deserialize_array(rest_data, 0, _schema, result), do: {Enum.reverse(result), rest_data}

  defp deserialize_array(data, len, schema, acc_result) when is_list(schema) do
    {new_result, rest_data} = do_deserialize(schema, data, %{})
    deserialize_array(rest_data, len - 1, schema, [new_result | acc_result])
  end

  defp deserialize_array(data, len, type, acc_result) do
    {new_result, rest_data} = do_deserialize_value(data, type)
    deserialize_array(rest_data, len - 1, type, [new_result | acc_result])
  end

  def deserialize_varint(binary, acc \\ 0, counter \\ 0) do
    <<msb::1, rest_byte::7, rest_data::binary>> = binary
    result = acc + bsl(rest_byte, counter * 7)

    if msb === 0 do
      {result, rest_data}
    else
      deserialize_varint(rest_data, result, acc + 1)
    end
  end
end
