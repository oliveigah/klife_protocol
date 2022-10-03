defmodule Klife.Protocol.Messages.DeleteTopics do
  alias Klife.Protocol.Deserializer
  alias Klife.Protocol.Serializer
  alias Klife.Protocol.Header

  def get_api_key(), do: 20

  def request_schema(0), do: [topic_names: {:array, :string}, timeout_ms: :int32]
  def request_schema(1), do: [timeout_ms: :int32]
  def request_schema(2), do: [timeout_ms: :int32]
  def request_schema(3), do: [timeout_ms: :int32]
  def request_schema(4), do: [timeout_ms: :int32, tag_buffer: %{}]
  def request_schema(5), do: [topic_names: {:array, :string}, timeout_ms: :int32, tag_buffer: %{}]

  def request_schema(6),
    do: [
      topics: {:array, [name: :string, topic_id: :uuid, tag_buffer: %{}]},
      timeout_ms: :int32,
      tag_buffer: %{}
    ]

  def response_schema(0), do: [responses: {:array, [name: :string, error_code: :int16]}]

  def response_schema(1),
    do: [throttle_time_ms: :int32, responses: {:array, [name: :string, error_code: :int16]}]

  def response_schema(2),
    do: [throttle_time_ms: :int32, responses: {:array, [name: :string, error_code: :int16]}]

  def response_schema(3),
    do: [throttle_time_ms: :int32, responses: {:array, [name: :string, error_code: :int16]}]

  def response_schema(4),
    do: [
      throttle_time_ms: :int32,
      responses: {:array, [name: :string, error_code: :int16, tag_buffer: %{}]},
      tag_buffer: %{}
    ]

  def response_schema(5),
    do: [
      throttle_time_ms: :int32,
      responses:
        {:array, [name: :string, error_code: :int16, error_message: :string, tag_buffer: %{}]},
      tag_buffer: %{}
    ]

  def response_schema(6),
    do: [
      throttle_time_ms: :int32,
      responses:
        {:array,
         [
           name: :string,
           topic_id: :uuid,
           error_code: :int16,
           error_message: :string,
           tag_buffer: %{}
         ]},
      tag_buffer: %{}
    ]
end