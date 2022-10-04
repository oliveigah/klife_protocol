defmodule Klife.Protocol.Messages.OffsetCommit do
  alias Klife.Protocol.Deserializer
  alias Klife.Protocol.Serializer
  alias Klife.Protocol.Header

  @api_key 8
  @min_flexible_version_req 8
  @min_flexible_version_res 8

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
      group_id: :string,
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
      group_id: :string,
      generation_id: :int32,
      member_id: :string,
      topics:
        {:array,
         [
           name: :string,
           partitions:
             {:array,
              [
                partition_index: :int32,
                committed_offset: :int64,
                commit_timestamp: :int64,
                committed_metadata: :string
              ]}
         ]}
    ]

  defp request_schema(2),
    do: [
      group_id: :string,
      generation_id: :int32,
      member_id: :string,
      retention_time_ms: :int64,
      topics:
        {:array,
         [
           name: :string,
           partitions:
             {:array,
              [partition_index: :int32, committed_offset: :int64, committed_metadata: :string]}
         ]}
    ]

  defp request_schema(3),
    do: [
      group_id: :string,
      generation_id: :int32,
      member_id: :string,
      topics:
        {:array,
         [
           name: :string,
           partitions:
             {:array,
              [partition_index: :int32, committed_offset: :int64, committed_metadata: :string]}
         ]}
    ]

  defp request_schema(4),
    do: [
      group_id: :string,
      generation_id: :int32,
      member_id: :string,
      retention_time_ms: :int64,
      topics:
        {:array,
         [
           name: :string,
           partitions:
             {:array,
              [partition_index: :int32, committed_offset: :int64, committed_metadata: :string]}
         ]}
    ]

  defp request_schema(5),
    do: [
      group_id: :string,
      generation_id: :int32,
      member_id: :string,
      topics:
        {:array,
         [
           name: :string,
           partitions:
             {:array,
              [partition_index: :int32, committed_offset: :int64, committed_metadata: :string]}
         ]}
    ]

  defp request_schema(6),
    do: [
      group_id: :string,
      generation_id: :int32,
      member_id: :string,
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

  defp request_schema(7),
    do: [
      group_id: :string,
      generation_id: :int32,
      member_id: :string,
      group_instance_id: :string,
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

  defp request_schema(8),
    do: [
      group_id: :string,
      generation_id: :int32,
      member_id: :string,
      group_instance_id: :string,
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
                committed_metadata: :string,
                tag_buffer: %{}
              ]},
           tag_buffer: %{}
         ]},
      tag_buffer: %{}
    ]

  defp response_schema(0),
    do: [
      topics:
        {:array,
         [name: :string, partitions: {:array, [partition_index: :int32, error_code: :int16]}]}
    ]

  defp response_schema(1),
    do: [
      topics:
        {:array,
         [name: :string, partitions: {:array, [partition_index: :int32, error_code: :int16]}]}
    ]

  defp response_schema(2),
    do: [
      topics:
        {:array,
         [name: :string, partitions: {:array, [partition_index: :int32, error_code: :int16]}]}
    ]

  defp response_schema(3),
    do: [
      throttle_time_ms: :int32,
      topics:
        {:array,
         [name: :string, partitions: {:array, [partition_index: :int32, error_code: :int16]}]}
    ]

  defp response_schema(4),
    do: [
      throttle_time_ms: :int32,
      topics:
        {:array,
         [name: :string, partitions: {:array, [partition_index: :int32, error_code: :int16]}]}
    ]

  defp response_schema(5),
    do: [
      throttle_time_ms: :int32,
      topics:
        {:array,
         [name: :string, partitions: {:array, [partition_index: :int32, error_code: :int16]}]}
    ]

  defp response_schema(6),
    do: [
      throttle_time_ms: :int32,
      topics:
        {:array,
         [name: :string, partitions: {:array, [partition_index: :int32, error_code: :int16]}]}
    ]

  defp response_schema(7),
    do: [
      throttle_time_ms: :int32,
      topics:
        {:array,
         [name: :string, partitions: {:array, [partition_index: :int32, error_code: :int16]}]}
    ]

  defp response_schema(8),
    do: [
      throttle_time_ms: :int32,
      topics:
        {:array,
         [
           name: :string,
           partitions: {:array, [partition_index: :int32, error_code: :int16, tag_buffer: %{}]},
           tag_buffer: %{}
         ]},
      tag_buffer: %{}
    ]
end