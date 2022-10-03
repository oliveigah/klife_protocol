defmodule Klife.Protocol.Messages.JoinGroup do
  alias Klife.Protocol.Deserializer
  alias Klife.Protocol.Serializer
  alias Klife.Protocol.Header

  def get_api_key(), do: 11

  def request_schema(0),
    do: [
      group_id: :string,
      session_timeout_ms: :int32,
      member_id: :string,
      protocol_type: :string,
      protocols: {:array, [name: :string, metadata: :bytes]}
    ]

  def request_schema(1),
    do: [
      group_id: :string,
      session_timeout_ms: :int32,
      rebalance_timeout_ms: :int32,
      member_id: :string,
      protocol_type: :string,
      protocols: {:array, [name: :string, metadata: :bytes]}
    ]

  def request_schema(2),
    do: [
      group_id: :string,
      session_timeout_ms: :int32,
      rebalance_timeout_ms: :int32,
      member_id: :string,
      protocol_type: :string,
      protocols: {:array, [name: :string, metadata: :bytes]}
    ]

  def request_schema(3),
    do: [
      group_id: :string,
      session_timeout_ms: :int32,
      rebalance_timeout_ms: :int32,
      member_id: :string,
      protocol_type: :string,
      protocols: {:array, [name: :string, metadata: :bytes]}
    ]

  def request_schema(4),
    do: [
      group_id: :string,
      session_timeout_ms: :int32,
      rebalance_timeout_ms: :int32,
      member_id: :string,
      protocol_type: :string,
      protocols: {:array, [name: :string, metadata: :bytes]}
    ]

  def request_schema(5),
    do: [
      group_id: :string,
      session_timeout_ms: :int32,
      rebalance_timeout_ms: :int32,
      member_id: :string,
      group_instance_id: :string,
      protocol_type: :string,
      protocols: {:array, [name: :string, metadata: :bytes]}
    ]

  def request_schema(6),
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

  def request_schema(7),
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

  def request_schema(8),
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

  def request_schema(9),
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

  def response_schema(0),
    do: [
      error_code: :int16,
      generation_id: :int32,
      protocol_name: :string,
      leader: :string,
      member_id: :string,
      members: {:array, [member_id: :string, metadata: :bytes]}
    ]

  def response_schema(1),
    do: [
      error_code: :int16,
      generation_id: :int32,
      protocol_name: :string,
      leader: :string,
      member_id: :string,
      members: {:array, [member_id: :string, metadata: :bytes]}
    ]

  def response_schema(2),
    do: [
      throttle_time_ms: :int32,
      error_code: :int16,
      generation_id: :int32,
      protocol_name: :string,
      leader: :string,
      member_id: :string,
      members: {:array, [member_id: :string, metadata: :bytes]}
    ]

  def response_schema(3),
    do: [
      throttle_time_ms: :int32,
      error_code: :int16,
      generation_id: :int32,
      protocol_name: :string,
      leader: :string,
      member_id: :string,
      members: {:array, [member_id: :string, metadata: :bytes]}
    ]

  def response_schema(4),
    do: [
      throttle_time_ms: :int32,
      error_code: :int16,
      generation_id: :int32,
      protocol_name: :string,
      leader: :string,
      member_id: :string,
      members: {:array, [member_id: :string, metadata: :bytes]}
    ]

  def response_schema(5),
    do: [
      throttle_time_ms: :int32,
      error_code: :int16,
      generation_id: :int32,
      protocol_name: :string,
      leader: :string,
      member_id: :string,
      members: {:array, [member_id: :string, group_instance_id: :string, metadata: :bytes]}
    ]

  def response_schema(6),
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

  def response_schema(7),
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

  def response_schema(8),
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

  def response_schema(9),
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