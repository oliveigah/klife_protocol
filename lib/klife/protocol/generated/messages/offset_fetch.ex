defmodule Klife.Protocol.Messages.OffsetFetch do
  alias Klife.Protocol.Deserializer
  alias Klife.Protocol.Serializer
  alias Klife.Protocol.Header

  @api_key 9
  @min_flexible_version_req 6
  @min_flexible_version_res 6

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
      group_id: :string,
      topics: {:array, [name: :string, partition_indexes: {:array, :int32}]}
    ]

  defp request_schema(1), do: []
  defp request_schema(2), do: []
  defp request_schema(3), do: []
  defp request_schema(4), do: []
  defp request_schema(5), do: []
  defp request_schema(6), do: [tag_buffer: {:tag_buffer, []}]

  defp request_schema(7),
    do: [
      group_id: :compact_string,
      topics:
        {:compact_array,
         [
           name: :compact_string,
           partition_indexes: {:compact_array, :int32},
           tag_buffer: {:tag_buffer, []}
         ]},
      require_stable: :boolean,
      tag_buffer: {:tag_buffer, []}
    ]

  defp request_schema(8),
    do: [
      groups:
        {:compact_array,
         [
           group_id: :compact_string,
           topics:
             {:compact_array,
              [
                name: :compact_string,
                partition_indexes: {:compact_array, :int32},
                tag_buffer: {:tag_buffer, []}
              ]},
           tag_buffer: {:tag_buffer, []}
         ]},
      require_stable: :boolean,
      tag_buffer: {:tag_buffer, []}
    ]

  defp response_schema(0),
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

  defp response_schema(1), do: []
  defp response_schema(2), do: [error_code: :int16]
  defp response_schema(3), do: [throttle_time_ms: :int32]
  defp response_schema(4), do: [throttle_time_ms: :int32]
  defp response_schema(5), do: [throttle_time_ms: :int32]
  defp response_schema(6), do: [throttle_time_ms: :int32, tag_buffer: {:tag_buffer, %{}}]

  defp response_schema(7),
    do: [
      throttle_time_ms: :int32,
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
                metadata: :compact_string,
                error_code: :int16,
                tag_buffer: {:tag_buffer, %{}}
              ]},
           tag_buffer: {:tag_buffer, %{}}
         ]},
      error_code: :int16,
      tag_buffer: {:tag_buffer, %{}}
    ]

  defp response_schema(8),
    do: [
      throttle_time_ms: :int32,
      groups:
        {:compact_array,
         [
           group_id: :compact_string,
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
                     metadata: :compact_string,
                     error_code: :int16,
                     tag_buffer: {:tag_buffer, %{}}
                   ]},
                tag_buffer: {:tag_buffer, %{}}
              ]},
           error_code: :int16,
           tag_buffer: {:tag_buffer, %{}}
         ]},
      tag_buffer: {:tag_buffer, %{}}
    ]
end