defmodule Klife.Protocol.Messages.OffsetFetch do
  alias Klife.Protocol.Deserializer
  alias Klife.Protocol.Serializer
  alias Klife.Protocol.Header

  def get_api_key(), do: 9

  def request_schema(0),
    do: [
      group_id: :string,
      topics: {:array, [name: :string, partition_indexes: {:array, :int32}]}
    ]

  def request_schema(1), do: []
  def request_schema(2), do: []
  def request_schema(3), do: []
  def request_schema(4), do: []
  def request_schema(5), do: []
  def request_schema(6), do: [tag_buffer: %{}]

  def request_schema(7),
    do: [
      group_id: :string,
      topics: {:array, [name: :string, partition_indexes: {:array, :int32}, tag_buffer: %{}]},
      require_stable: :boolean,
      tag_buffer: %{}
    ]

  def request_schema(8),
    do: [
      groups:
        {:array,
         [
           group_id: :string,
           topics:
             {:array, [name: :string, partition_indexes: {:array, :int32}, tag_buffer: %{}]},
           tag_buffer: %{}
         ]},
      require_stable: :boolean,
      tag_buffer: %{}
    ]

  def response_schema(0),
    do: [
      topics:
        {:array,
         [
           name: :string,
           partitions:
             {:array,
              [
                partition_index: :int32,
                committed_offset: :int64,
                metadata: :string,
                error_code: :int16
              ]}
         ]}
    ]

  def response_schema(1), do: []
  def response_schema(2), do: [error_code: :int16]
  def response_schema(3), do: [throttle_time_ms: :int32]
  def response_schema(4), do: [throttle_time_ms: :int32]
  def response_schema(5), do: [throttle_time_ms: :int32]
  def response_schema(6), do: [throttle_time_ms: :int32, tag_buffer: %{}]

  def response_schema(7),
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
                committed_offset: :int64,
                committed_leader_epoch: :int32,
                metadata: :string,
                error_code: :int16,
                tag_buffer: %{}
              ]},
           tag_buffer: %{}
         ]},
      error_code: :int16,
      tag_buffer: %{}
    ]

  def response_schema(8),
    do: [
      throttle_time_ms: :int32,
      groups:
        {:array,
         [
           group_id: :string,
           topics:
             {:array,
              [
                name: :string,
                partitions:
                  {:array,
                   [
                     partition_index: :int32,
                     committed_offset: :int64,
                     committed_leader_epoch: :int32,
                     metadata: :string,
                     error_code: :int16,
                     tag_buffer: %{}
                   ]},
                tag_buffer: %{}
              ]},
           error_code: :int16,
           tag_buffer: %{}
         ]},
      tag_buffer: %{}
    ]
end