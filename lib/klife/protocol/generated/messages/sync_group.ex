defmodule Klife.Protocol.Messages.SyncGroup do
  alias Klife.Protocol.Deserializer
  alias Klife.Protocol.Serializer
  alias Klife.Protocol.Header

  @api_key 14
  @min_flexible_version_req 4
  @min_flexible_version_res 4

  def deserialize_response(data, version) do
    with {headers, rest_data} <- Header.deserialize_response(data, res_header_version(version)),
         {content, _} <- Deserializer.execute(rest_data, response_schema(version)) do
      %{headers: headers, content: content}
    end
  end

  def serialize_request(input, version) do
    input
    |> Map.put(:request_api_key, @api_key)
    |> Map.put(:request_api_version, version)
    |> Header.serialize_request(req_header_version(version))
    |> then(&Serializer.execute(input, request_schema(version), &1))
  end

  defp req_header_version(msg_version),
    do: if(msg_version >= @min_flexible_version_req, do: 2, else: 1)

  defp res_header_version(msg_version),
    do: if(msg_version >= @min_flexible_version_res, do: 1, else: 0)

  defp request_schema(0),
    do: [
      group_id: :string,
      generation_id: :int32,
      member_id: :string,
      assignments: {:array, [member_id: :string, assignment: :bytes]}
    ]

  defp request_schema(1),
    do: [
      group_id: :string,
      generation_id: :int32,
      member_id: :string,
      assignments: {:array, [member_id: :string, assignment: :bytes]}
    ]

  defp request_schema(2),
    do: [
      group_id: :string,
      generation_id: :int32,
      member_id: :string,
      assignments: {:array, [member_id: :string, assignment: :bytes]}
    ]

  defp request_schema(3),
    do: [
      group_id: :string,
      generation_id: :int32,
      member_id: :string,
      group_instance_id: :string,
      assignments: {:array, [member_id: :string, assignment: :bytes]}
    ]

  defp request_schema(4),
    do: [
      group_id: :compact_string,
      generation_id: :int32,
      member_id: :compact_string,
      group_instance_id: :compact_string,
      assignments:
        {:compact_array,
         [member_id: :compact_string, assignment: :compact_bytes, tag_buffer: {:tag_buffer, %{}}]},
      tag_buffer: {:tag_buffer, %{}}
    ]

  defp request_schema(5),
    do: [
      group_id: :compact_string,
      generation_id: :int32,
      member_id: :compact_string,
      group_instance_id: :compact_string,
      protocol_type: :compact_string,
      protocol_name: :compact_string,
      assignments:
        {:compact_array,
         [member_id: :compact_string, assignment: :compact_bytes, tag_buffer: {:tag_buffer, %{}}]},
      tag_buffer: {:tag_buffer, %{}}
    ]

  defp response_schema(0), do: [error_code: :int16, assignment: :bytes]
  defp response_schema(1), do: [throttle_time_ms: :int32, error_code: :int16, assignment: :bytes]
  defp response_schema(2), do: [throttle_time_ms: :int32, error_code: :int16, assignment: :bytes]
  defp response_schema(3), do: [throttle_time_ms: :int32, error_code: :int16, assignment: :bytes]

  defp response_schema(4),
    do: [
      throttle_time_ms: :int32,
      error_code: :int16,
      assignment: :compact_bytes,
      tag_buffer: {:tag_buffer, %{}}
    ]

  defp response_schema(5),
    do: [
      throttle_time_ms: :int32,
      error_code: :int16,
      protocol_type: :compact_string,
      protocol_name: :compact_string,
      assignment: :compact_bytes,
      tag_buffer: {:tag_buffer, %{}}
    ]
end