defmodule KlifeProtocol.Messages.OffsetForLeaderEpoch do
  alias KlifeProtocol.Deserializer
  alias KlifeProtocol.Serializer
  alias KlifeProtocol.Header

  @api_key 23
  @min_flexible_version_req 4
  @min_flexible_version_res 4

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
      topics:
        {:array,
         [topic: :string, partitions: {:array, [partition: :int32, leader_epoch: :int32]}]}
    ]

  defp request_schema(1),
    do: [
      topics:
        {:array,
         [topic: :string, partitions: {:array, [partition: :int32, leader_epoch: :int32]}]}
    ]

  defp request_schema(2),
    do: [
      topics:
        {:array,
         [
           topic: :string,
           partitions:
             {:array, [partition: :int32, current_leader_epoch: :int32, leader_epoch: :int32]}
         ]}
    ]

  defp request_schema(3),
    do: [
      replica_id: :int32,
      topics:
        {:array,
         [
           topic: :string,
           partitions:
             {:array, [partition: :int32, current_leader_epoch: :int32, leader_epoch: :int32]}
         ]}
    ]

  defp request_schema(4),
    do: [
      replica_id: :int32,
      topics:
        {:compact_array,
         [
           topic: :compact_string,
           partitions:
             {:compact_array,
              [
                partition: :int32,
                current_leader_epoch: :int32,
                leader_epoch: :int32,
                tag_buffer: {:tag_buffer, []}
              ]},
           tag_buffer: {:tag_buffer, []}
         ]},
      tag_buffer: {:tag_buffer, []}
    ]

  defp response_schema(0),
    do: [
      topics:
        {:array,
         [
           topic: :string,
           partitions: {:array, [error_code: :int16, partition: :int32, end_offset: :int64]}
         ]}
    ]

  defp response_schema(1),
    do: [
      topics:
        {:array,
         [
           topic: :string,
           partitions:
             {:array,
              [error_code: :int16, partition: :int32, leader_epoch: :int32, end_offset: :int64]}
         ]}
    ]

  defp response_schema(2),
    do: [
      throttle_time_ms: :int32,
      topics:
        {:array,
         [
           topic: :string,
           partitions:
             {:array,
              [error_code: :int16, partition: :int32, leader_epoch: :int32, end_offset: :int64]}
         ]}
    ]

  defp response_schema(3),
    do: [
      throttle_time_ms: :int32,
      topics:
        {:array,
         [
           topic: :string,
           partitions:
             {:array,
              [error_code: :int16, partition: :int32, leader_epoch: :int32, end_offset: :int64]}
         ]}
    ]

  defp response_schema(4),
    do: [
      throttle_time_ms: :int32,
      topics:
        {:compact_array,
         [
           topic: :compact_string,
           partitions:
             {:compact_array,
              [
                error_code: :int16,
                partition: :int32,
                leader_epoch: :int32,
                end_offset: :int64,
                tag_buffer: {:tag_buffer, %{}}
              ]},
           tag_buffer: {:tag_buffer, %{}}
         ]},
      tag_buffer: {:tag_buffer, %{}}
    ]
end