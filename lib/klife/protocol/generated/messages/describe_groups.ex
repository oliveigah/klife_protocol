defmodule Klife.Protocol.Messages.DescribeGroups do
  alias Klife.Protocol.Deserializer
  alias Klife.Protocol.Serializer
  alias Klife.Protocol.Header

  @api_key 15
  @min_flexible_version_req 5
  @min_flexible_version_res 5

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

  defp request_schema(0), do: [groups: {:array, :string}]
  defp request_schema(1), do: [groups: {:array, :string}]
  defp request_schema(2), do: [groups: {:array, :string}]
  defp request_schema(3), do: [groups: {:array, :string}, include_authorized_operations: :boolean]
  defp request_schema(4), do: [groups: {:array, :string}, include_authorized_operations: :boolean]

  defp request_schema(5),
    do: [
      groups: {:compact_array, :compact_string},
      include_authorized_operations: :boolean,
      tag_buffer: {:tag_buffer, %{}}
    ]

  defp response_schema(0),
    do: [
      groups:
        {:array,
         [
           error_code: :int16,
           group_id: :string,
           group_state: :string,
           protocol_type: :string,
           protocol_data: :string,
           members:
             {:array,
              [
                member_id: :string,
                client_id: :string,
                client_host: :string,
                member_metadata: :bytes,
                member_assignment: :bytes
              ]}
         ]}
    ]

  defp response_schema(1),
    do: [
      throttle_time_ms: :int32,
      groups:
        {:array,
         [
           error_code: :int16,
           group_id: :string,
           group_state: :string,
           protocol_type: :string,
           protocol_data: :string,
           members:
             {:array,
              [
                member_id: :string,
                client_id: :string,
                client_host: :string,
                member_metadata: :bytes,
                member_assignment: :bytes
              ]}
         ]}
    ]

  defp response_schema(2),
    do: [
      throttle_time_ms: :int32,
      groups:
        {:array,
         [
           error_code: :int16,
           group_id: :string,
           group_state: :string,
           protocol_type: :string,
           protocol_data: :string,
           members:
             {:array,
              [
                member_id: :string,
                client_id: :string,
                client_host: :string,
                member_metadata: :bytes,
                member_assignment: :bytes
              ]}
         ]}
    ]

  defp response_schema(3),
    do: [
      throttle_time_ms: :int32,
      groups:
        {:array,
         [
           error_code: :int16,
           group_id: :string,
           group_state: :string,
           protocol_type: :string,
           protocol_data: :string,
           members:
             {:array,
              [
                member_id: :string,
                client_id: :string,
                client_host: :string,
                member_metadata: :bytes,
                member_assignment: :bytes
              ]},
           authorized_operations: :int32
         ]}
    ]

  defp response_schema(4),
    do: [
      throttle_time_ms: :int32,
      groups:
        {:array,
         [
           error_code: :int16,
           group_id: :string,
           group_state: :string,
           protocol_type: :string,
           protocol_data: :string,
           members:
             {:array,
              [
                member_id: :string,
                group_instance_id: :string,
                client_id: :string,
                client_host: :string,
                member_metadata: :bytes,
                member_assignment: :bytes
              ]},
           authorized_operations: :int32
         ]}
    ]

  defp response_schema(5),
    do: [
      throttle_time_ms: :int32,
      groups:
        {:compact_array,
         [
           error_code: :int16,
           group_id: :compact_string,
           group_state: :compact_string,
           protocol_type: :compact_string,
           protocol_data: :compact_string,
           members:
             {:compact_array,
              [
                member_id: :compact_string,
                group_instance_id: :compact_string,
                client_id: :compact_string,
                client_host: :compact_string,
                member_metadata: :compact_bytes,
                member_assignment: :compact_bytes,
                tag_buffer: {:tag_buffer, %{}}
              ]},
           authorized_operations: :int32,
           tag_buffer: {:tag_buffer, %{}}
         ]},
      tag_buffer: {:tag_buffer, %{}}
    ]
end