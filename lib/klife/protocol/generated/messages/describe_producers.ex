defmodule Klife.Protocol.Messages.DescribeProducers do
  alias Klife.Protocol.Deserializer
  alias Klife.Protocol.Serializer
  alias Klife.Protocol.Header

  def get_api_key(), do: 61

  def request_schema(0),
    do: [
      topics: {:array, [name: :string, partition_indexes: {:array, :int32}, tag_buffer: %{}]},
      tag_buffer: %{}
    ]

  def response_schema(0),
    do: [
      throttle_time_ms: :int32,
      topics:
        {:array,
         [
           name: :string,
           partitions:
             {:array,
              [
                partition_index: :int32,
                error_code: :int16,
                error_message: :string,
                active_producers:
                  {:array,
                   [
                     producer_id: :int64,
                     producer_epoch: :int32,
                     last_sequence: :int32,
                     last_timestamp: :int64,
                     coordinator_epoch: :int32,
                     current_txn_start_offset: :int64,
                     tag_buffer: %{}
                   ]},
                tag_buffer: %{}
              ]},
           tag_buffer: %{}
         ]},
      tag_buffer: %{}
    ]
end