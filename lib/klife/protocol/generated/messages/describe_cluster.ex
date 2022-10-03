defmodule Klife.Protocol.Messages.DescribeCluster do
  alias Klife.Protocol.Deserializer
  alias Klife.Protocol.Serializer
  alias Klife.Protocol.Header

  def get_api_key(), do: 60

  def request_schema(0), do: [include_cluster_authorized_operations: :boolean, tag_buffer: %{}]

  def response_schema(0),
    do: [
      throttle_time_ms: :int32,
      error_code: :int16,
      error_message: :string,
      cluster_id: :string,
      controller_id: :int32,
      brokers:
        {:array, [broker_id: :int32, host: :string, port: :int32, rack: :string, tag_buffer: %{}]},
      cluster_authorized_operations: :int32,
      tag_buffer: %{}
    ]
end