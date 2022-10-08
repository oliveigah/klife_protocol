defmodule KlifeProtocol.Messages.ElectLeaders do
  alias KlifeProtocol.Deserializer
  alias KlifeProtocol.Serializer
  alias KlifeProtocol.Header

  @api_key 43
  @min_flexible_version_req 2
  @min_flexible_version_res 2

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
      topic_partitions: {:array, [topic: :string, partitions: {:array, :int32}]},
      timeout_ms: :int32
    ]

  defp request_schema(1),
    do: [
      election_type: :int8,
      topic_partitions: {:array, [topic: :string, partitions: {:array, :int32}]},
      timeout_ms: :int32
    ]

  defp request_schema(2),
    do: [
      election_type: :int8,
      topic_partitions:
        {:compact_array,
         [
           topic: :compact_string,
           partitions: {:compact_array, :int32},
           tag_buffer: {:tag_buffer, []}
         ]},
      timeout_ms: :int32,
      tag_buffer: {:tag_buffer, []}
    ]

  defp response_schema(0),
    do: [
      throttle_time_ms: :int32,
      replica_election_results:
        {:array,
         [
           topic: :string,
           partition_result:
             {:array, [partition_id: :int32, error_code: :int16, error_message: :string]}
         ]}
    ]

  defp response_schema(1),
    do: [
      throttle_time_ms: :int32,
      error_code: :int16,
      replica_election_results:
        {:array,
         [
           topic: :string,
           partition_result:
             {:array, [partition_id: :int32, error_code: :int16, error_message: :string]}
         ]}
    ]

  defp response_schema(2),
    do: [
      throttle_time_ms: :int32,
      error_code: :int16,
      replica_election_results:
        {:compact_array,
         [
           topic: :compact_string,
           partition_result:
             {:compact_array,
              [
                partition_id: :int32,
                error_code: :int16,
                error_message: :compact_string,
                tag_buffer: {:tag_buffer, %{}}
              ]},
           tag_buffer: {:tag_buffer, %{}}
         ]},
      tag_buffer: {:tag_buffer, %{}}
    ]
end