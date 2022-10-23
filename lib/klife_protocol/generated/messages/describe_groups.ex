defmodule KlifeProtocol.Messages.DescribeGroups do
  alias KlifeProtocol.Deserializer
  alias KlifeProtocol.Serializer
  alias KlifeProtocol.Header

  @api_key 15
  @min_flexible_version_req 5
  @min_flexible_version_res 5

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

  defp request_schema(0), do: [groups: {{:array, :string}, %{is_nullable?: false}}]
  defp request_schema(1), do: [groups: {{:array, :string}, %{is_nullable?: false}}]
  defp request_schema(2), do: [groups: {{:array, :string}, %{is_nullable?: false}}]

  defp request_schema(3),
    do: [
      groups: {{:array, :string}, %{is_nullable?: false}},
      include_authorized_operations: {:boolean, %{is_nullable?: false}}
    ]

  defp request_schema(4),
    do: [
      groups: {{:array, :string}, %{is_nullable?: false}},
      include_authorized_operations: {:boolean, %{is_nullable?: false}}
    ]

  defp request_schema(5),
    do: [
      groups: {{:compact_array, :compact_string}, %{is_nullable?: false}},
      include_authorized_operations: {:boolean, %{is_nullable?: false}},
      tag_buffer: {:tag_buffer, []}
    ]

  defp response_schema(0),
    do: [
      groups:
        {{:array,
          [
            error_code: {:int16, %{is_nullable?: false}},
            group_id: {:string, %{is_nullable?: false}},
            group_state: {:string, %{is_nullable?: false}},
            protocol_type: {:string, %{is_nullable?: false}},
            protocol_data: {:string, %{is_nullable?: false}},
            members:
              {{:array,
                [
                  member_id: {:string, %{is_nullable?: false}},
                  client_id: {:string, %{is_nullable?: false}},
                  client_host: {:string, %{is_nullable?: false}},
                  member_metadata: {:bytes, %{is_nullable?: false}},
                  member_assignment: {:bytes, %{is_nullable?: false}}
                ]}, %{is_nullable?: false}}
          ]}, %{is_nullable?: false}}
    ]

  defp response_schema(1),
    do: [
      throttle_time_ms: {:int32, %{is_nullable?: false}},
      groups:
        {{:array,
          [
            error_code: {:int16, %{is_nullable?: false}},
            group_id: {:string, %{is_nullable?: false}},
            group_state: {:string, %{is_nullable?: false}},
            protocol_type: {:string, %{is_nullable?: false}},
            protocol_data: {:string, %{is_nullable?: false}},
            members:
              {{:array,
                [
                  member_id: {:string, %{is_nullable?: false}},
                  client_id: {:string, %{is_nullable?: false}},
                  client_host: {:string, %{is_nullable?: false}},
                  member_metadata: {:bytes, %{is_nullable?: false}},
                  member_assignment: {:bytes, %{is_nullable?: false}}
                ]}, %{is_nullable?: false}}
          ]}, %{is_nullable?: false}}
    ]

  defp response_schema(2),
    do: [
      throttle_time_ms: {:int32, %{is_nullable?: false}},
      groups:
        {{:array,
          [
            error_code: {:int16, %{is_nullable?: false}},
            group_id: {:string, %{is_nullable?: false}},
            group_state: {:string, %{is_nullable?: false}},
            protocol_type: {:string, %{is_nullable?: false}},
            protocol_data: {:string, %{is_nullable?: false}},
            members:
              {{:array,
                [
                  member_id: {:string, %{is_nullable?: false}},
                  client_id: {:string, %{is_nullable?: false}},
                  client_host: {:string, %{is_nullable?: false}},
                  member_metadata: {:bytes, %{is_nullable?: false}},
                  member_assignment: {:bytes, %{is_nullable?: false}}
                ]}, %{is_nullable?: false}}
          ]}, %{is_nullable?: false}}
    ]

  defp response_schema(3),
    do: [
      throttle_time_ms: {:int32, %{is_nullable?: false}},
      groups:
        {{:array,
          [
            error_code: {:int16, %{is_nullable?: false}},
            group_id: {:string, %{is_nullable?: false}},
            group_state: {:string, %{is_nullable?: false}},
            protocol_type: {:string, %{is_nullable?: false}},
            protocol_data: {:string, %{is_nullable?: false}},
            members:
              {{:array,
                [
                  member_id: {:string, %{is_nullable?: false}},
                  client_id: {:string, %{is_nullable?: false}},
                  client_host: {:string, %{is_nullable?: false}},
                  member_metadata: {:bytes, %{is_nullable?: false}},
                  member_assignment: {:bytes, %{is_nullable?: false}}
                ]}, %{is_nullable?: false}},
            authorized_operations: {:int32, %{is_nullable?: false}}
          ]}, %{is_nullable?: false}}
    ]

  defp response_schema(4),
    do: [
      throttle_time_ms: {:int32, %{is_nullable?: false}},
      groups:
        {{:array,
          [
            error_code: {:int16, %{is_nullable?: false}},
            group_id: {:string, %{is_nullable?: false}},
            group_state: {:string, %{is_nullable?: false}},
            protocol_type: {:string, %{is_nullable?: false}},
            protocol_data: {:string, %{is_nullable?: false}},
            members:
              {{:array,
                [
                  member_id: {:string, %{is_nullable?: false}},
                  group_instance_id: {:string, %{is_nullable?: true}},
                  client_id: {:string, %{is_nullable?: false}},
                  client_host: {:string, %{is_nullable?: false}},
                  member_metadata: {:bytes, %{is_nullable?: false}},
                  member_assignment: {:bytes, %{is_nullable?: false}}
                ]}, %{is_nullable?: false}},
            authorized_operations: {:int32, %{is_nullable?: false}}
          ]}, %{is_nullable?: false}}
    ]

  defp response_schema(5),
    do: [
      throttle_time_ms: {:int32, %{is_nullable?: false}},
      groups:
        {{:compact_array,
          [
            error_code: {:int16, %{is_nullable?: false}},
            group_id: {:compact_string, %{is_nullable?: false}},
            group_state: {:compact_string, %{is_nullable?: false}},
            protocol_type: {:compact_string, %{is_nullable?: false}},
            protocol_data: {:compact_string, %{is_nullable?: false}},
            members:
              {{:compact_array,
                [
                  member_id: {:compact_string, %{is_nullable?: false}},
                  group_instance_id: {:compact_string, %{is_nullable?: true}},
                  client_id: {:compact_string, %{is_nullable?: false}},
                  client_host: {:compact_string, %{is_nullable?: false}},
                  member_metadata: {:compact_bytes, %{is_nullable?: false}},
                  member_assignment: {:compact_bytes, %{is_nullable?: false}},
                  tag_buffer: {:tag_buffer, %{}}
                ]}, %{is_nullable?: false}},
            authorized_operations: {:int32, %{is_nullable?: false}},
            tag_buffer: {:tag_buffer, %{}}
          ]}, %{is_nullable?: false}},
      tag_buffer: {:tag_buffer, %{}}
    ]
end