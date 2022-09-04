defmodule KAFE.Protocol.Serializer do
  def execute(input, schema, append_binary \\ <<>>) do
    do_serialize(schema, input, append_binary)
  end

  defp do_serialize([], map, result_data) when is_map(map), do: result_data
  defp do_serialize(schema, [], result_data) when is_list(schema), do: result_data
  defp do_serialize(schema, [], result_data) when is_atom(schema), do: result_data

  defp do_serialize([{key, type} | rest_schema], %{} = input_map, acc_data) do
    input_map
    |> Map.get(key)
    |> serialize_value(type)
    |> then(&do_serialize(rest_schema, input_map, acc_data <> &1))
  end

  defp do_serialize(schema, [val | rest_val], acc_data) when is_list(schema) do
    schema
    |> do_serialize(val, acc_data)
    |> then(&do_serialize(schema, rest_val, &1))
  end

  defp do_serialize(schema, [val | rest_val], acc_data) when is_atom(schema) do
    val
    |> serialize_value(schema)
    |> then(&do_serialize(schema, rest_val, acc_data <> &1))
  end

  defp serialize_value(val, :int16), do: <<val::16-signed>>
  defp serialize_value(val, :int32), do: <<val::32-signed>>
  defp serialize_value(nil, :string), do: <<-1::16-signed>>
  defp serialize_value(val, :string) when is_binary(val), do: <<byte_size(val)::16-signed>> <> val
  defp serialize_value(nil, {:array, _array_type}), do: <<-1::32-signed>>

  defp serialize_value(val, {:array, array_type}) do
    do_serialize(array_type, val, <<length(val)::32-signed>>)
  end
end
