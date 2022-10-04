defmodule Klife.Protocol.Messages.StopReplica do
  alias Klife.Protocol.Deserializer
  alias Klife.Protocol.Serializer
  alias Klife.Protocol.Header

  @api_key 5
  @min_flexible_version_req 2
  @min_flexible_version_res 2

  def deserialize_response(data, version) do
    with {headers, rest_data} <- Header.deserialize_response(data, res_header_version(version)),
         {content, <<>>} <- Deserializer.execute(rest_data, response_schema(version)) do
      %{headers: headers, content: content}
    end
  end

  def serialize_request(input, version) do
    input
    |> Map.put(:request_api_key, @api_key)
    |> Map.put(:request_api_version, version)
    |> Header.serialize_request(req_header_version(version))
    |> then(&Serializer.execute(input, request_schema(version), &1))
  end

  defp req_header_version(msg_version),
    do: if(msg_version >= @min_flexible_version_req, do: 2, else: 1)

  defp res_header_version(msg_version),
    do: if(msg_version >= @min_flexible_version_res, do: 1, else: 0)

  defp request_schema(0),
    do: [
      controller_id: :int32,
      controller_epoch: :int32,
      delete_partitions: :boolean,
      ungrouped_partitions: {:array, [topic_name: :string, partition_index: :int32]}
    ]

  defp request_schema(1),
    do: [
      controller_id: :int32,
      controller_epoch: :int32,
      broker_epoch: :int64,
      topics: {:array, [name: :string, partition_indexes: {:array, :int32}]}
    ]

  defp request_schema(2),
    do: [
      controller_id: :int32,
      controller_epoch: :int32,
      broker_epoch: :int64,
      delete_partitions: :boolean,
      topics: {:array, [name: :string, partition_indexes: {:array, :int32}, tag_buffer: %{}]},
      tag_buffer: %{}
    ]

  defp request_schema(3),
    do: [
      controller_id: :int32,
      controller_epoch: :int32,
      broker_epoch: :int64,
      topic_states:
        {:array,
         [
           topic_name: :string,
           partition_states:
             {:array,
              [
                partition_index: :int32,
                leader_epoch: :int32,
                delete_partition: :boolean,
                tag_buffer: %{}
              ]},
           tag_buffer: %{}
         ]},
      tag_buffer: %{}
    ]

  defp response_schema(0),
    do: [
      error_code: :int16,
      partition_errors:
        {:array, [topic_name: :string, partition_index: :int32, error_code: :int16]}
    ]

  defp response_schema(1),
    do: [
      error_code: :int16,
      partition_errors:
        {:array, [topic_name: :string, partition_index: :int32, error_code: :int16]}
    ]

  defp response_schema(2),
    do: [
      error_code: :int16,
      partition_errors:
        {:array,
         [topic_name: :string, partition_index: :int32, error_code: :int16, tag_buffer: %{}]},
      tag_buffer: %{}
    ]

  defp response_schema(3),
    do: [
      error_code: :int16,
      partition_errors:
        {:array,
         [topic_name: :string, partition_index: :int32, error_code: :int16, tag_buffer: %{}]},
      tag_buffer: %{}
    ]
end