defmodule Klife.Protocol.Messages.EndQuorumEpoch do
  alias Klife.Protocol.Deserializer
  alias Klife.Protocol.Serializer
  alias Klife.Protocol.Header

  def get_api_key(), do: 54

  def request_schema(0),
    do: [
      cluster_id: :string,
      topics:
        {:array,
         [
           topic_name: :string,
           partitions:
             {:array,
              [
                partition_index: :int32,
                leader_id: :int32,
                leader_epoch: :int32,
                preferred_successors: {:array, :int32}
              ]}
         ]}
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
                leader_epoch: :int32
              ]}
         ]}
    ]
end