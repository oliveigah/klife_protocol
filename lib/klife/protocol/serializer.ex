defmodule Klife.Protocol.Serializer do
  import Bitwise

  def execute(input, schema, append_binary \\ <<>>) do
    do_serialize(schema, input, append_binary)
  end

  defp do_serialize([], map, result_data) when is_map(map), do: result_data
  defp do_serialize(_schema, [], result_data), do: result_data

  defp do_serialize([{key, type} | rest_schema], %{} = input_map, acc_data) do
    input_map
    |> Map.get(key)
    |> serialize_value(type)
    |> then(&do_serialize(rest_schema, input_map, acc_data <> &1))
  end

  # Used in arrays of complex data types
  defp do_serialize(schema, [val | rest_val], acc_data) when is_list(schema) do
    schema
    |> do_serialize(val, acc_data)
    |> then(&do_serialize(schema, rest_val, &1))
  end

  # Used in arrays of simple data types
  defp do_serialize(schema, [val | rest_val], acc_data) when is_atom(schema) do
    val
    |> serialize_value(schema)
    |> then(&do_serialize(schema, rest_val, acc_data <> &1))
  end

  # Used in arrays of tag buffers
  defp do_serialize(schema, [{tag, tag_val}, rest], acc_data) when is_map(schema) do
    schema
    |> Map.get(tag)
    |> then(&serialize_value(tag_val, &1))
    |> then(&do_serialize(schema, rest, acc_data <> &1))
  end

  defp serialize_value(val, :int16), do: <<val::16-signed>>
  defp serialize_value(val, :int32), do: <<val::32-signed>>
  defp serialize_value(nil, :string), do: <<-1::16-signed>>
  defp serialize_value(val, :string) when is_binary(val), do: <<byte_size(val)::16-signed>> <> val
  defp serialize_value(nil, {:array, _array_type}), do: <<-1::32-signed>>

  defp serialize_value(val, {:array, array_type}) do
    do_serialize(array_type, val, <<length(val)::32-signed>>)
  end

  defp serialize_value(nil, {:tag_buffer, _tag_schema}), do: serialize_value(17, :varint)

  defp serialize_value(val, {:tag_buffer, tag_schema}) do
    ordered_tags = Enum.sort(val, fn {k1, _v1}, {k2, _v2} -> k1 < k2 end)
    do_serialize(tag_schema, ordered_tags, serialize_value(length(val), :varint))
  end

  defp serialize_value(val, :varint) when val <= 127 and val >= 0, do: <<val>>

  defp serialize_value(val, :varint) when val > 127,
    do: <<1::1, band(val, 127)::7>> <> serialize_value(bsr(val, 7), :varint)

  def serialize_varint(val), do: serialize_value(val, :varint)
end
