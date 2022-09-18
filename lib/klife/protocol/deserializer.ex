defmodule Klife.Protocol.Deserializer do
  import Bitwise

  def execute(data, schema) do
    do_deserialize(schema, data, %{})
  end

  defp do_deserialize([], data, result), do: {result, data}

  defp do_deserialize([{key, schema} | rest_schema], data, acc_result) do
    IO.inspect({key, schema})
    {val, rest_data} = deserialize_value(data, schema)
    new_result = Map.put(acc_result, key, val)
    do_deserialize(rest_schema, rest_data, new_result)
  end

  defp deserialize_value(<<val::16-signed, rest_data::binary>>, :int16), do: {val, rest_data}
  defp deserialize_value(<<val::32-signed, rest_data::binary>>, :int32), do: {val, rest_data}
  defp deserialize_value(<<-1::16-signed, rest_data::binary>>, :string), do: {nil, rest_data}

  defp deserialize_value(<<len::16-signed, val::size(len)-binary, rest_data::binary>>, :string),
    do: {val, rest_data}

  defp deserialize_value(<<-1::32-signed, rest_data::binary>>, {:array, _schema}),
    do: {nil, rest_data}

  defp deserialize_value(<<0::32-signed, rest_data::binary>>, {:array, _schema}),
    do: {[], rest_data}

  defp deserialize_value(<<len::32-signed, rest_data::binary>>, {:array, schema}),
    do: deserialize_array(rest_data, len, schema, [])

  defp deserialize_value(binary, :varint), do: deserialize_varint(binary)

  # defp deserialize_value(binary_data, {:tag_buffer, schema}) do
  #   case deserialize_varint(binary_data) do
  #     {0, rest_data} ->
  #       {[], binary_data}

  #     {items, rest_data} ->
  #       IO.inspect(items, label: "asdasudh")
  #       nil
  #   end
  # end

  # TODO: Improve deserialize_array/4 algorithm to insert elements in the array with proper order
  # so we can remove the call to Enum.reverse/1 on return
  defp deserialize_array(rest_data, 0, _schema, result), do: {Enum.reverse(result), rest_data}

  defp deserialize_array(data, len, schema, acc_result) when is_list(schema) do
    {new_result, rest_data} = do_deserialize(schema, data, %{})
    deserialize_array(rest_data, len - 1, schema, [new_result | acc_result])
  end

  defp deserialize_array(data, len, schema, acc_result) when is_atom(schema) do
    {new_result, rest_data} = deserialize_value(data, schema)
    deserialize_array(rest_data, len - 1, schema, [new_result | acc_result])
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
