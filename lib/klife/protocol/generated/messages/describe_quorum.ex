defmodule Klife.Protocol.Messages.DescribeQuorum do
  alias Klife.Protocol.Deserializer
  alias Klife.Protocol.Serializer
  alias Klife.Protocol.Header

  def get_api_key(), do: 55

  def request_schema(0),
    do: [
      topics:
        {:array,
         [
           topic_name: :string,
           partitions: {:array, [partition_index: :int32, tag_buffer: %{}]},
           tag_buffer: %{}
         ]},
      tag_buffer: %{}
    ]

  def request_schema(1),
    do: [
      topics:
        {:array,
         [
           topic_name: :string,
           partitions: {:array, [partition_index: :int32, tag_buffer: %{}]},
           tag_buffer: %{}
         ]},
      tag_buffer: %{}
    ]

  def response_schema(0),
    do: [
      error_code: :int16,
      topics:
        {:array,
         [
           topic_name: :string,
           partitions:
             {:array,
              [
                partition_index: :int32,
                error_code: :int16,
                leader_id: :int32,
                leader_epoch: :int32,
                high_watermark: :int64,
                current_voters:
                  {:array, [replica_id: :int32, log_end_offset: :int64, tag_buffer: %{}]},
                observers:
                  {:array, [replica_id: :int32, log_end_offset: :int64, tag_buffer: %{}]},
                tag_buffer: %{}
              ]},
           tag_buffer: %{}
         ]},
      tag_buffer: %{}
    ]

  def response_schema(1),
    do: [
      error_code: :int16,
      topics:
        {:array,
         [
           topic_name: :string,
           partitions:
             {:array,
              [
                partition_index: :int32,
                error_code: :int16,
                leader_id: :int32,
                leader_epoch: :int32,
                high_watermark: :int64,
                current_voters:
                  {:array,
                   [
                     replica_id: :int32,
                     log_end_offset: :int64,
                     last_fetch_timestamp: :int64,
                     last_caught_up_timestamp: :int64,
                     tag_buffer: %{}
                   ]},
                observers:
                  {:array,
                   [
                     replica_id: :int32,
                     log_end_offset: :int64,
                     last_fetch_timestamp: :int64,
                     last_caught_up_timestamp: :int64,
                     tag_buffer: %{}
                   ]},
                tag_buffer: %{}
              ]},
           tag_buffer: %{}
         ]},
      tag_buffer: %{}
    ]
end