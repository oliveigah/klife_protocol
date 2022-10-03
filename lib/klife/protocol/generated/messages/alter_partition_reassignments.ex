defmodule Klife.Protocol.Messages.AlterPartitionReassignments do
  alias Klife.Protocol.Deserializer
  alias Klife.Protocol.Serializer
  alias Klife.Protocol.Header

  def get_api_key(), do: 45

  def request_schema(0),
    do: [
      timeout_ms: :int32,
      topics:
        {:array,
         [
           name: :string,
           partitions:
             {:array, [partition_index: :int32, replicas: {:array, :int32}, tag_buffer: %{}]},
           tag_buffer: %{}
         ]},
      tag_buffer: %{}
    ]

  def response_schema(0),
    do: [
      throttle_time_ms: :int32,
      error_code: :int16,
      error_message: :string,
      responses:
        {:array,
         [
           name: :string,
           partitions:
             {:array,
              [
                partition_index: :int32,
                error_code: :int16,
                error_message: :string,
                tag_buffer: %{}
              ]},
           tag_buffer: %{}
         ]},
      tag_buffer: %{}
    ]
end