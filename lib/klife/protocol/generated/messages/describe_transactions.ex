defmodule Klife.Protocol.Messages.DescribeTransactions do
  alias Klife.Protocol.Deserializer
  alias Klife.Protocol.Serializer
  alias Klife.Protocol.Header

  def get_api_key(), do: 65

  def request_schema(0), do: [transactional_ids: {:array, :string}, tag_buffer: %{}]

  def response_schema(0),
    do: [
      throttle_time_ms: :int32,
      transaction_states:
        {:array,
         [
           error_code: :int16,
           transactional_id: :string,
           transaction_state: :string,
           transaction_timeout_ms: :int32,
           transaction_start_time_ms: :int64,
           producer_id: :int64,
           producer_epoch: :int16,
           topics: {:array, [topic: :string, partitions: {:array, :int32}, tag_buffer: %{}]},
           tag_buffer: %{}
         ]},
      tag_buffer: %{}
    ]
end