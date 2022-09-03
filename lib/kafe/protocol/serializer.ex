defmodule KAFE.Protocol.Serializer do
  def execute(map, schema, append_binary \\ <<>>) do
    do_serialize(schema, map, append_binary)
  end

  defp do_serialize([], _map, result_data), do: result_data

  defp do_serialize([{key, type} | rest_schema], input_map, acc_data) do
    serialized_value =
      input_map
      |> Map.get(key)
      |> serialize_value(type)

    do_serialize(rest_schema, input_map, acc_data <> serialized_value)
  end

  defp serialize_value(val, :int16), do: <<val::16-signed>>
  defp serialize_value(val, :int32), do: <<val::32-signed>>
  defp serialize_value(nil, :string), do: <<-1::16-signed>>
  defp serialize_value(val, :string) when is_binary(val), do: <<byte_size(val)::16-signed>> <> val
end
