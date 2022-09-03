defmodule KAFE.Protocol.Deserializer do
  def execute(data, schema) do
    do_deserialize(schema, data, %{})
  end

  defp do_deserialize([], data, result), do: {result, data}

  defp do_deserialize([{key, type} | rest_schema], data, acc_result) do
    {val, rest_data} = deserialize_value(data, type)
    new_result = Map.put(acc_result, key, val)
    do_deserialize(rest_schema, rest_data, new_result)
  end

  defp deserialize_value(<<val::16-signed, rest_data::binary>>, :int16), do: {val, rest_data}
  defp deserialize_value(<<val::32-signed, rest_data::binary>>, :int32), do: {val, rest_data}

  defp deserialize_value(<<-1::16-signed, rest_data::binary>>, :string), do: {nil, rest_data}

  defp deserialize_value(<<len::16-signed, rest_data::binary>>, :string) do
    <<val::size(len)-binary, rest_data::binary>> = rest_data
    {val, rest_data}
  end

  defp deserialize_value(<<-1::32-signed, rest_data::binary>>, {:array, _schema}),
    do: {[], rest_data}

  defp deserialize_value(<<len::32-signed, rest_data::binary>>, {:array, schema}),
    do: deserialize_array(rest_data, len, schema, [])

  defp deserialize_array(rest_data, 0, _schema, result), do: {Enum.reverse(result), rest_data}

  # TODO: Improve algorithm to insert elements in the array with propoer order
  # so we can remove the call to Enum.reverse/1 on return
  defp deserialize_array(data, len, schema, acc_result) do
    {new_result, rest_data} = do_deserialize(schema, data, %{})
    deserialize_array(rest_data, len - 1, schema, [new_result | acc_result])
  end
end
