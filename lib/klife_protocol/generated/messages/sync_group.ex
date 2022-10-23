defmodule KlifeProtocol.Messages.SyncGroup do
  alias KlifeProtocol.Deserializer
  alias KlifeProtocol.Serializer
  alias KlifeProtocol.Header

  @api_key 14
  @min_flexible_version_req 4
  @min_flexible_version_res 4

  def serialize_request(%{headers: headers, content: content}, version) do
    headers
    |> Map.put(:request_api_key, @api_key)
    |> Map.put(:request_api_version, version)
    |> Header.serialize_request(req_header_version(version))
    |> then(&Serializer.execute(content, request_schema(version), &1))
  end

  def deserialize_response(data, version) do
    {headers, rest_data} = Header.deserialize_response(data, res_header_version(version))
    {content, <<>>} = Deserializer.execute(rest_data, response_schema(version))

    %{headers: headers, content: content}
  end

  defp req_header_version(msg_version),
    do: if(msg_version >= @min_flexible_version_req, do: 2, else: 1)

  defp res_header_version(msg_version),
    do: if(msg_version >= @min_flexible_version_res, do: 1, else: 0)

  defp request_schema(0),
    do: [
      group_id: {:string, %{is_nullable?: false}},
      generation_id: {:int32, %{is_nullable?: false}},
      member_id: {:string, %{is_nullable?: false}},
      assignments:
        {{:array,
          [
            member_id: {:string, %{is_nullable?: false}},
            assignment: {:bytes, %{is_nullable?: false}}
          ]}, %{is_nullable?: false}}
    ]

  defp request_schema(1),
    do: [
      group_id: {:string, %{is_nullable?: false}},
      generation_id: {:int32, %{is_nullable?: false}},
      member_id: {:string, %{is_nullable?: false}},
      assignments:
        {{:array,
          [
            member_id: {:string, %{is_nullable?: false}},
            assignment: {:bytes, %{is_nullable?: false}}
          ]}, %{is_nullable?: false}}
    ]

  defp request_schema(2),
    do: [
      group_id: {:string, %{is_nullable?: false}},
      generation_id: {:int32, %{is_nullable?: false}},
      member_id: {:string, %{is_nullable?: false}},
      assignments:
        {{:array,
          [
            member_id: {:string, %{is_nullable?: false}},
            assignment: {:bytes, %{is_nullable?: false}}
          ]}, %{is_nullable?: false}}
    ]

  defp request_schema(3),
    do: [
      group_id: {:string, %{is_nullable?: false}},
      generation_id: {:int32, %{is_nullable?: false}},
      member_id: {:string, %{is_nullable?: false}},
      group_instance_id: {:string, %{is_nullable?: true}},
      assignments:
        {{:array,
          [
            member_id: {:string, %{is_nullable?: false}},
            assignment: {:bytes, %{is_nullable?: false}}
          ]}, %{is_nullable?: false}}
    ]

  defp request_schema(4),
    do: [
      group_id: {:compact_string, %{is_nullable?: false}},
      generation_id: {:int32, %{is_nullable?: false}},
      member_id: {:compact_string, %{is_nullable?: false}},
      group_instance_id: {:compact_string, %{is_nullable?: true}},
      assignments:
        {{:compact_array,
          [
            member_id: {:compact_string, %{is_nullable?: false}},
            assignment: {:compact_bytes, %{is_nullable?: false}},
            tag_buffer: {:tag_buffer, []}
          ]}, %{is_nullable?: false}},
      tag_buffer: {:tag_buffer, []}
    ]

  defp request_schema(5),
    do: [
      group_id: {:compact_string, %{is_nullable?: false}},
      generation_id: {:int32, %{is_nullable?: false}},
      member_id: {:compact_string, %{is_nullable?: false}},
      group_instance_id: {:compact_string, %{is_nullable?: true}},
      protocol_type: {:compact_string, %{is_nullable?: true}},
      protocol_name: {:compact_string, %{is_nullable?: true}},
      assignments:
        {{:compact_array,
          [
            member_id: {:compact_string, %{is_nullable?: false}},
            assignment: {:compact_bytes, %{is_nullable?: false}},
            tag_buffer: {:tag_buffer, []}
          ]}, %{is_nullable?: false}},
      tag_buffer: {:tag_buffer, []}
    ]

  defp response_schema(0),
    do: [
      error_code: {:int16, %{is_nullable?: false}},
      assignment: {:bytes, %{is_nullable?: false}}
    ]

  defp response_schema(1),
    do: [
      throttle_time_ms: {:int32, %{is_nullable?: false}},
      error_code: {:int16, %{is_nullable?: false}},
      assignment: {:bytes, %{is_nullable?: false}}
    ]

  defp response_schema(2),
    do: [
      throttle_time_ms: {:int32, %{is_nullable?: false}},
      error_code: {:int16, %{is_nullable?: false}},
      assignment: {:bytes, %{is_nullable?: false}}
    ]

  defp response_schema(3),
    do: [
      throttle_time_ms: {:int32, %{is_nullable?: false}},
      error_code: {:int16, %{is_nullable?: false}},
      assignment: {:bytes, %{is_nullable?: false}}
    ]

  defp response_schema(4),
    do: [
      throttle_time_ms: {:int32, %{is_nullable?: false}},
      error_code: {:int16, %{is_nullable?: false}},
      assignment: {:compact_bytes, %{is_nullable?: false}},
      tag_buffer: {:tag_buffer, %{}}
    ]

  defp response_schema(5),
    do: [
      throttle_time_ms: {:int32, %{is_nullable?: false}},
      error_code: {:int16, %{is_nullable?: false}},
      protocol_type: {:compact_string, %{is_nullable?: true}},
      protocol_name: {:compact_string, %{is_nullable?: true}},
      assignment: {:compact_bytes, %{is_nullable?: false}},
      tag_buffer: {:tag_buffer, %{}}
    ]
end