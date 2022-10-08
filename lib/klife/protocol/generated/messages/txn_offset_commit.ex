defmodule Klife.Protocol.Messages.TxnOffsetCommit do
  alias Klife.Protocol.Deserializer
  alias Klife.Protocol.Serializer
  alias Klife.Protocol.Header

  @api_key 28
  @min_flexible_version_req 3
  @min_flexible_version_res 3

  def deserialize_response(data, version) do
    with {headers, rest_data} <- Header.deserialize_response(data, res_header_version(version)),
         {content, _} <- Deserializer.execute(rest_data, response_schema(version)) do
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
      transactional_id: :string,
      group_id: :string,
      producer_id: :int64,
      producer_epoch: :int16,
      topics:
        {:array,
         [
           name: :string,
           partitions:
             {:array,
              [partition_index: :int32, committed_offset: :int64, committed_metadata: :string]}
         ]}
    ]

  defp request_schema(1),
    do: [
      transactional_id: :string,
      group_id: :string,
      producer_id: :int64,
      producer_epoch: :int16,
      topics:
        {:array,
         [
           name: :string,
           partitions:
             {:array,
              [partition_index: :int32, committed_offset: :int64, committed_metadata: :string]}
         ]}
    ]

  defp request_schema(2),
    do: [
      transactional_id: :string,
      group_id: :string,
      producer_id: :int64,
      producer_epoch: :int16,
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
                committed_metadata: :string
              ]}
         ]}
    ]

  defp request_schema(3),
    do: [
      transactional_id: :compact_string,
      group_id: :compact_string,
      producer_id: :int64,
      producer_epoch: :int16,
      generation_id: :int32,
      member_id: :compact_string,
      group_instance_id: :compact_string,
      topics:
        {:compact_array,
         [
           name: :compact_string,
           partitions:
             {:compact_array,
              [
                partition_index: :int32,
                committed_offset: :int64,
                committed_leader_epoch: :int32,
                committed_metadata: :compact_string,
                tag_buffer: {:tag_buffer, %{}}
              ]},
           tag_buffer: {:tag_buffer, %{}}
         ]},
      tag_buffer: {:tag_buffer, %{}}
    ]

  defp response_schema(0),
    do: [
      throttle_time_ms: :int32,
      topics:
        {:array,
         [name: :string, partitions: {:array, [partition_index: :int32, error_code: :int16]}]}
    ]

  defp response_schema(1),
    do: [
      throttle_time_ms: :int32,
      topics:
        {:array,
         [name: :string, partitions: {:array, [partition_index: :int32, error_code: :int16]}]}
    ]

  defp response_schema(2),
    do: [
      throttle_time_ms: :int32,
      topics:
        {:array,
         [name: :string, partitions: {:array, [partition_index: :int32, error_code: :int16]}]}
    ]

  defp response_schema(3),
    do: [
      throttle_time_ms: :int32,
      topics:
        {:compact_array,
         [
           name: :compact_string,
           partitions:
             {:compact_array,
              [partition_index: :int32, error_code: :int16, tag_buffer: {:tag_buffer, %{}}]},
           tag_buffer: {:tag_buffer, %{}}
         ]},
      tag_buffer: {:tag_buffer, %{}}
    ]
end