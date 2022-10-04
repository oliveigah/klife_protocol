defmodule Klife.Protocol.Messages.JoinGroup do
  alias Klife.Protocol.Deserializer
  alias Klife.Protocol.Serializer
  alias Klife.Protocol.Header

  @api_key 11
  @min_flexible_version_req 6
  @min_flexible_version_res 6

  def deserialize_response(data, version) do
    with {headers, rest_data} <- Header.deserialize_response(data, res_header_version(version)),
         {content, <<>>} <- Deserializer.execute(rest_data, response_schema(version)) do
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
      session_timeout_ms: :int32,
      member_id: :string,
      protocol_type: :string,
      protocols: {:array, [name: :string, metadata: :bytes]}
    ]

  defp request_schema(1),
    do: [
      group_id: :string,
      session_timeout_ms: :int32,
      rebalance_timeout_ms: :int32,
      member_id: :string,
      protocol_type: :string,
      protocols: {:array, [name: :string, metadata: :bytes]}
    ]

  defp request_schema(2),
    do: [
      group_id: :string,
      session_timeout_ms: :int32,
      rebalance_timeout_ms: :int32,
      member_id: :string,
      protocol_type: :string,
      protocols: {:array, [name: :string, metadata: :bytes]}
    ]

  defp request_schema(3),
    do: [
      group_id: :string,
      session_timeout_ms: :int32,
      rebalance_timeout_ms: :int32,
      member_id: :string,
      protocol_type: :string,
      protocols: {:array, [name: :string, metadata: :bytes]}
    ]

  defp request_schema(4),
    do: [
      group_id: :string,
      session_timeout_ms: :int32,
      rebalance_timeout_ms: :int32,
      member_id: :string,
      protocol_type: :string,
      protocols: {:array, [name: :string, metadata: :bytes]}
    ]

  defp request_schema(5),
    do: [
      group_id: :string,
      session_timeout_ms: :int32,
      rebalance_timeout_ms: :int32,
      member_id: :string,
      group_instance_id: :string,
      protocol_type: :string,
      protocols: {:array, [name: :string, metadata: :bytes]}
    ]

  defp request_schema(6),
    do: [
      group_id: :string,
      session_timeout_ms: :int32,
      rebalance_timeout_ms: :int32,
      member_id: :string,
      group_instance_id: :string,
      protocol_type: :string,
      protocols: {:array, [name: :string, metadata: :bytes, tag_buffer: %{}]},
      tag_buffer: %{}
    ]

  defp request_schema(7),
    do: [
      group_id: :string,
      session_timeout_ms: :int32,
      rebalance_timeout_ms: :int32,
      member_id: :string,
      group_instance_id: :string,
      protocol_type: :string,
      protocols: {:array, [name: :string, metadata: :bytes, tag_buffer: %{}]},
      tag_buffer: %{}
    ]

  defp request_schema(8),
    do: [
      group_id: :string,
      session_timeout_ms: :int32,
      rebalance_timeout_ms: :int32,
      member_id: :string,
      group_instance_id: :string,
      protocol_type: :string,
      protocols: {:array, [name: :string, metadata: :bytes, tag_buffer: %{}]},
      reason: :string,
      tag_buffer: %{}
    ]

  defp request_schema(9),
    do: [
      group_id: :string,
      session_timeout_ms: :int32,
      rebalance_timeout_ms: :int32,
      member_id: :string,
      group_instance_id: :string,
      protocol_type: :string,
      protocols: {:array, [name: :string, metadata: :bytes, tag_buffer: %{}]},
      reason: :string,
      tag_buffer: %{}
    ]

  defp response_schema(0),
    do: [
      error_code: :int16,
      generation_id: :int32,
      protocol_name: :string,
      leader: :string,
      member_id: :string,
      members: {:array, [member_id: :string, metadata: :bytes]}
    ]

  defp response_schema(1),
    do: [
      error_code: :int16,
      generation_id: :int32,
      protocol_name: :string,
      leader: :string,
      member_id: :string,
      members: {:array, [member_id: :string, metadata: :bytes]}
    ]

  defp response_schema(2),
    do: [
      throttle_time_ms: :int32,
      error_code: :int16,
      generation_id: :int32,
      protocol_name: :string,
      leader: :string,
      member_id: :string,
      members: {:array, [member_id: :string, metadata: :bytes]}
    ]

  defp response_schema(3),
    do: [
      throttle_time_ms: :int32,
      error_code: :int16,
      generation_id: :int32,
      protocol_name: :string,
      leader: :string,
      member_id: :string,
      members: {:array, [member_id: :string, metadata: :bytes]}
    ]

  defp response_schema(4),
    do: [
      throttle_time_ms: :int32,
      error_code: :int16,
      generation_id: :int32,
      protocol_name: :string,
      leader: :string,
      member_id: :string,
      members: {:array, [member_id: :string, metadata: :bytes]}
    ]

  defp response_schema(5),
    do: [
      throttle_time_ms: :int32,
      error_code: :int16,
      generation_id: :int32,
      protocol_name: :string,
      leader: :string,
      member_id: :string,
      members: {:array, [member_id: :string, group_instance_id: :string, metadata: :bytes]}
    ]

  defp response_schema(6),
    do: [
      throttle_time_ms: :int32,
      error_code: :int16,
      generation_id: :int32,
      protocol_name: :string,
      leader: :string,
      member_id: :string,
      members:
        {:array,
         [member_id: :string, group_instance_id: :string, metadata: :bytes, tag_buffer: %{}]},
      tag_buffer: %{}
    ]

  defp response_schema(7),
    do: [
      throttle_time_ms: :int32,
      error_code: :int16,
      generation_id: :int32,
      protocol_type: :string,
      protocol_name: :string,
      leader: :string,
      member_id: :string,
      members:
        {:array,
         [member_id: :string, group_instance_id: :string, metadata: :bytes, tag_buffer: %{}]},
      tag_buffer: %{}
    ]

  defp response_schema(8),
    do: [
      throttle_time_ms: :int32,
      error_code: :int16,
      generation_id: :int32,
      protocol_type: :string,
      protocol_name: :string,
      leader: :string,
      member_id: :string,
      members:
        {:array,
         [member_id: :string, group_instance_id: :string, metadata: :bytes, tag_buffer: %{}]},
      tag_buffer: %{}
    ]

  defp response_schema(9),
    do: [
      throttle_time_ms: :int32,
      error_code: :int16,
      generation_id: :int32,
      protocol_type: :string,
      protocol_name: :string,
      leader: :string,
      skip_assignment: :boolean,
      member_id: :string,
      members:
        {:array,
         [member_id: :string, group_instance_id: :string, metadata: :bytes, tag_buffer: %{}]},
      tag_buffer: %{}
    ]
end