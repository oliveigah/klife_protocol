defmodule Klife.Protocol.Messages.AllocateProducerIds do
  alias Klife.Protocol.Deserializer
  alias Klife.Protocol.Serializer
  alias Klife.Protocol.Header

  def get_api_key(), do: 67

  def request_schema(0), do: [broker_id: :int32, broker_epoch: :int64, tag_buffer: %{}]

  def response_schema(0),
    do: [
      throttle_time_ms: :int32,
      error_code: :int16,
      producer_id_start: :int64,
      producer_id_len: :int32,
      tag_buffer: %{}
    ]
end