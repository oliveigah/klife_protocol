defmodule Klife.Protocol.Messages.OffsetDelete do
  alias Klife.Protocol.Deserializer
  alias Klife.Protocol.Serializer
  alias Klife.Protocol.Header

  def get_api_key(), do: 47

  def request_schema(0),
    do: [
      group_id: :string,
      topics: {:array, [name: :string, partitions: {:array, [partition_index: :int32]}]}
    ]

  def response_schema(0),
    do: [
      error_code: :int16,
      throttle_time_ms: :int32,
      topics:
        {:array,
         [name: :string, partitions: {:array, [partition_index: :int32, error_code: :int16]}]}
    ]
end