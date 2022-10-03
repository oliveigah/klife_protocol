defmodule Klife.Protocol.Messages.ListGroups do
  alias Klife.Protocol.Deserializer
  alias Klife.Protocol.Serializer
  alias Klife.Protocol.Header

  def get_api_key(), do: 16

  def request_schema(0), do: []
  def request_schema(1), do: []
  def request_schema(2), do: []
  def request_schema(3), do: [tag_buffer: %{}]
  def request_schema(4), do: [states_filter: {:array, :string}, tag_buffer: %{}]

  def response_schema(0),
    do: [error_code: :int16, groups: {:array, [group_id: :string, protocol_type: :string]}]

  def response_schema(1),
    do: [
      throttle_time_ms: :int32,
      error_code: :int16,
      groups: {:array, [group_id: :string, protocol_type: :string]}
    ]

  def response_schema(2),
    do: [
      throttle_time_ms: :int32,
      error_code: :int16,
      groups: {:array, [group_id: :string, protocol_type: :string]}
    ]

  def response_schema(3),
    do: [
      throttle_time_ms: :int32,
      error_code: :int16,
      groups: {:array, [group_id: :string, protocol_type: :string, tag_buffer: %{}]},
      tag_buffer: %{}
    ]

  def response_schema(4),
    do: [
      throttle_time_ms: :int32,
      error_code: :int16,
      groups:
        {:array,
         [group_id: :string, protocol_type: :string, group_state: :string, tag_buffer: %{}]},
      tag_buffer: %{}
    ]
end