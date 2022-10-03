defmodule Klife.Protocol.Messages.LeaveGroup do
  alias Klife.Protocol.Deserializer
  alias Klife.Protocol.Serializer
  alias Klife.Protocol.Header

  def get_api_key(), do: 13

  def request_schema(0), do: [group_id: :string, member_id: :string]
  def request_schema(1), do: [group_id: :string]
  def request_schema(2), do: [group_id: :string, member_id: :string]

  def request_schema(3),
    do: [group_id: :string, members: {:array, [member_id: :string, group_instance_id: :string]}]

  def request_schema(4),
    do: [
      group_id: :string,
      members: {:array, [member_id: :string, group_instance_id: :string, tag_buffer: %{}]},
      tag_buffer: %{}
    ]

  def request_schema(5),
    do: [
      group_id: :string,
      members:
        {:array,
         [member_id: :string, group_instance_id: :string, reason: :string, tag_buffer: %{}]},
      tag_buffer: %{}
    ]

  def response_schema(0), do: [error_code: :int16]
  def response_schema(1), do: [throttle_time_ms: :int32, error_code: :int16]
  def response_schema(2), do: [throttle_time_ms: :int32, error_code: :int16]

  def response_schema(3),
    do: [
      throttle_time_ms: :int32,
      error_code: :int16,
      members: {:array, [member_id: :string, group_instance_id: :string, error_code: :int16]}
    ]

  def response_schema(4),
    do: [
      throttle_time_ms: :int32,
      error_code: :int16,
      members:
        {:array,
         [member_id: :string, group_instance_id: :string, error_code: :int16, tag_buffer: %{}]},
      tag_buffer: %{}
    ]

  def response_schema(5),
    do: [
      throttle_time_ms: :int32,
      error_code: :int16,
      members:
        {:array,
         [member_id: :string, group_instance_id: :string, error_code: :int16, tag_buffer: %{}]},
      tag_buffer: %{}
    ]
end