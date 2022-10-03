defmodule Klife.Protocol.Messages.SyncGroup do
  alias Klife.Protocol.Deserializer
  alias Klife.Protocol.Serializer
  alias Klife.Protocol.Header

  def get_api_key(), do: 14

  def request_schema(0),
    do: [
      group_id: :string,
      generation_id: :int32,
      member_id: :string,
      assignments: {:array, [member_id: :string, assignment: :bytes]}
    ]

  def request_schema(1),
    do: [
      group_id: :string,
      generation_id: :int32,
      member_id: :string,
      assignments: {:array, [member_id: :string, assignment: :bytes]}
    ]

  def request_schema(2),
    do: [
      group_id: :string,
      generation_id: :int32,
      member_id: :string,
      assignments: {:array, [member_id: :string, assignment: :bytes]}
    ]

  def request_schema(3),
    do: [
      group_id: :string,
      generation_id: :int32,
      member_id: :string,
      group_instance_id: :string,
      assignments: {:array, [member_id: :string, assignment: :bytes]}
    ]

  def request_schema(4),
    do: [
      group_id: :string,
      generation_id: :int32,
      member_id: :string,
      group_instance_id: :string,
      assignments: {:array, [member_id: :string, assignment: :bytes, tag_buffer: %{}]},
      tag_buffer: %{}
    ]

  def request_schema(5),
    do: [
      group_id: :string,
      generation_id: :int32,
      member_id: :string,
      group_instance_id: :string,
      protocol_type: :string,
      protocol_name: :string,
      assignments: {:array, [member_id: :string, assignment: :bytes, tag_buffer: %{}]},
      tag_buffer: %{}
    ]

  def response_schema(0), do: [error_code: :int16, assignment: :bytes]
  def response_schema(1), do: [throttle_time_ms: :int32, error_code: :int16, assignment: :bytes]
  def response_schema(2), do: [throttle_time_ms: :int32, error_code: :int16, assignment: :bytes]
  def response_schema(3), do: [throttle_time_ms: :int32, error_code: :int16, assignment: :bytes]

  def response_schema(4),
    do: [throttle_time_ms: :int32, error_code: :int16, assignment: :bytes, tag_buffer: %{}]

  def response_schema(5),
    do: [
      throttle_time_ms: :int32,
      error_code: :int16,
      protocol_type: :string,
      protocol_name: :string,
      assignment: :bytes,
      tag_buffer: %{}
    ]
end