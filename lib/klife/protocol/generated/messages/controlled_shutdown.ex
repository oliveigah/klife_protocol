defmodule Klife.Protocol.Messages.ControlledShutdown do
  alias Klife.Protocol.Deserializer
  alias Klife.Protocol.Serializer
  alias Klife.Protocol.Header

  def get_api_key(), do: 7

  def request_schema(0), do: [broker_id: :int32]
  def request_schema(1), do: [broker_id: :int32]
  def request_schema(2), do: [broker_id: :int32, broker_epoch: :int64]
  def request_schema(3), do: [broker_id: :int32, broker_epoch: :int64, tag_buffer: %{}]

  def response_schema(0),
    do: [
      error_code: :int16,
      remaining_partitions: {:array, [topic_name: :string, partition_index: :int32]}
    ]

  def response_schema(1),
    do: [
      error_code: :int16,
      remaining_partitions: {:array, [topic_name: :string, partition_index: :int32]}
    ]

  def response_schema(2),
    do: [
      error_code: :int16,
      remaining_partitions: {:array, [topic_name: :string, partition_index: :int32]}
    ]

  def response_schema(3),
    do: [
      error_code: :int16,
      remaining_partitions:
        {:array, [topic_name: :string, partition_index: :int32, tag_buffer: %{}]},
      tag_buffer: %{}
    ]
end