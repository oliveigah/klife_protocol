defmodule Klife.Protocol.Messages.WriteTxnMarkers do
  alias Klife.Protocol.Deserializer
  alias Klife.Protocol.Serializer
  alias Klife.Protocol.Header

  def get_api_key(), do: 27

  def request_schema(0),
    do: [
      markers:
        {:array,
         [
           producer_id: :int64,
           producer_epoch: :int16,
           transaction_result: :boolean,
           topics: {:array, [name: :string, partition_indexes: {:array, :int32}]},
           coordinator_epoch: :int32
         ]}
    ]

  def request_schema(1),
    do: [
      markers:
        {:array,
         [
           producer_id: :int64,
           producer_epoch: :int16,
           transaction_result: :boolean,
           topics:
             {:array, [name: :string, partition_indexes: {:array, :int32}, tag_buffer: %{}]},
           coordinator_epoch: :int32,
           tag_buffer: %{}
         ]},
      tag_buffer: %{}
    ]

  def response_schema(0),
    do: [
      markers:
        {:array,
         [
           producer_id: :int64,
           topics:
             {:array,
              [name: :string, partitions: {:array, [partition_index: :int32, error_code: :int16]}]}
         ]}
    ]

  def response_schema(1),
    do: [
      markers:
        {:array,
         [
           producer_id: :int64,
           topics:
             {:array,
              [
                name: :string,
                partitions:
                  {:array, [partition_index: :int32, error_code: :int16, tag_buffer: %{}]},
                tag_buffer: %{}
              ]},
           tag_buffer: %{}
         ]},
      tag_buffer: %{}
    ]
end