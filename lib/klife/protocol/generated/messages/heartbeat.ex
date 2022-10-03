defmodule Klife.Protocol.Messages.Heartbeat do
  alias Klife.Protocol.Deserializer
  alias Klife.Protocol.Serializer
  alias Klife.Protocol.Header

  def get_api_key(), do: 12

  def request_schema(0), do: [group_id: :string, generation_id: :int32, member_id: :string]
  def request_schema(1), do: [group_id: :string, generation_id: :int32, member_id: :string]
  def request_schema(2), do: [group_id: :string, generation_id: :int32, member_id: :string]

  def request_schema(3),
    do: [group_id: :string, generation_id: :int32, member_id: :string, group_instance_id: :string]

  def request_schema(4),
    do: [
      group_id: :string,
      generation_id: :int32,
      member_id: :string,
      group_instance_id: :string,
      tag_buffer: %{}
    ]

  def response_schema(0), do: [error_code: :int16]
  def response_schema(1), do: [throttle_time_ms: :int32, error_code: :int16]
  def response_schema(2), do: [throttle_time_ms: :int32, error_code: :int16]
  def response_schema(3), do: [throttle_time_ms: :int32, error_code: :int16]
  def response_schema(4), do: [throttle_time_ms: :int32, error_code: :int16, tag_buffer: %{}]
end