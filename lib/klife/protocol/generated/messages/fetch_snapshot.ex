defmodule Klife.Protocol.Messages.FetchSnapshot do
  alias Klife.Protocol.Deserializer
  alias Klife.Protocol.Serializer
  alias Klife.Protocol.Header

  def get_api_key(), do: 59

  def request_schema(0),
    do: [
      replica_id: :int32,
      max_bytes: :int32,
      topics:
        {:array,
         [
           name: :string,
           partitions:
             {:array,
              [
                partition: :int32,
                current_leader_epoch: :int32,
                snapshot_id: {:object, [end_offset: :int64, epoch: :int32, tag_buffer: %{}]},
                position: :int64,
                tag_buffer: %{}
              ]},
           tag_buffer: %{}
         ]},
      tag_buffer: %{cluster_id: {0, :string}}
    ]

  def response_schema(0),
    do: [
      throttle_time_ms: :int32,
      error_code: :int16,
      topics:
        {:array,
         [
           name: :string,
           partitions:
             {:array,
              [
                index: :int32,
                error_code: :int16,
                snapshot_id: {:object, [end_offset: :int64, epoch: :int32, tag_buffer: %{}]},
                size: :int64,
                position: :int64,
                unaligned_records: :records,
                tag_buffer: %{
                  0 =>
                    {:current_leader,
                     {:object, [leader_id: :int32, leader_epoch: :int32, tag_buffer: %{}]}}
                }
              ]},
           tag_buffer: %{}
         ]},
      tag_buffer: %{}
    ]
end