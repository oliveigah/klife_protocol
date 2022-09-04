defmodule Klife.Protocol.Deserializer do
  def execute(data, schema) do
    do_deserialize(schema, data, %{})
  end

  defp do_deserialize([], data, result), do: {result, data}

  defp do_deserialize([{key, schema} | rest_schema], data, acc_result) do
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
end
