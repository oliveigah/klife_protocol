defmodule KlifeProtocol.Messages.OffsetForLeaderEpoch do
  alias KlifeProtocol.Deserializer
  alias KlifeProtocol.Serializer
  alias KlifeProtocol.Header

  @api_key 23
  @min_flexible_version_req 4
  @min_flexible_version_res 4

  def serialize_request(%{headers: headers, content: content}, version) do
    headers
    |> Map.put(:request_api_key, @api_key)
    |> Map.put(:request_api_version, version)
    |> Header.serialize_request(req_header_version(version))
    |> then(&Serializer.execute(content, request_schema(version), &1))
  end

  def deserialize_response(data, version) do
    {headers, rest_data} = Header.deserialize_response(data, res_header_version(version))
    {content, <<>>} = Deserializer.execute(rest_data, response_schema(version))

    %{headers: headers, content: content}
  end

  defp req_header_version(msg_version),
    do: if(msg_version >= @min_flexible_version_req, do: 2, else: 1)

  defp res_header_version(msg_version),
    do: if(msg_version >= @min_flexible_version_res, do: 1, else: 0)

  defp request_schema(0),
    do: [
      topics:
        {{:array,
          [
            topic: {:string, %{is_nullable?: false}},
            partitions:
              {{:array,
                [
                  partition: {:int32, %{is_nullable?: false}},
                  leader_epoch: {:int32, %{is_nullable?: false}}
                ]}, %{is_nullable?: false}}
          ]}, %{is_nullable?: false}}
    ]

  defp request_schema(1),
    do: [
      topics:
        {{:array,
          [
            topic: {:string, %{is_nullable?: false}},
            partitions:
              {{:array,
                [
                  partition: {:int32, %{is_nullable?: false}},
                  leader_epoch: {:int32, %{is_nullable?: false}}
                ]}, %{is_nullable?: false}}
          ]}, %{is_nullable?: false}}
    ]

  defp request_schema(2),
    do: [
      topics:
        {{:array,
          [
            topic: {:string, %{is_nullable?: false}},
            partitions:
              {{:array,
                [
                  partition: {:int32, %{is_nullable?: false}},
                  current_leader_epoch: {:int32, %{is_nullable?: false}},
                  leader_epoch: {:int32, %{is_nullable?: false}}
                ]}, %{is_nullable?: false}}
          ]}, %{is_nullable?: false}}
    ]

  defp request_schema(3),
    do: [
      replica_id: {:int32, %{is_nullable?: false}},
      topics:
        {{:array,
          [
            topic: {:string, %{is_nullable?: false}},
            partitions:
              {{:array,
                [
                  partition: {:int32, %{is_nullable?: false}},
                  current_leader_epoch: {:int32, %{is_nullable?: false}},
                  leader_epoch: {:int32, %{is_nullable?: false}}
                ]}, %{is_nullable?: false}}
          ]}, %{is_nullable?: false}}
    ]

  defp request_schema(4),
    do: [
      replica_id: {:int32, %{is_nullable?: false}},
      topics:
        {{:compact_array,
          [
            topic: {:compact_string, %{is_nullable?: false}},
            partitions:
              {{:compact_array,
                [
                  partition: {:int32, %{is_nullable?: false}},
                  current_leader_epoch: {:int32, %{is_nullable?: false}},
                  leader_epoch: {:int32, %{is_nullable?: false}},
                  tag_buffer: {:tag_buffer, []}
                ]}, %{is_nullable?: false}},
            tag_buffer: {:tag_buffer, []}
          ]}, %{is_nullable?: false}},
      tag_buffer: {:tag_buffer, []}
    ]

  defp response_schema(0),
    do: [
      topics:
        {{:array,
          [
            topic: {:string, %{is_nullable?: false}},
            partitions:
              {{:array,
                [
                  error_code: {:int16, %{is_nullable?: false}},
                  partition: {:int32, %{is_nullable?: false}},
                  end_offset: {:int64, %{is_nullable?: false}}
                ]}, %{is_nullable?: false}}
          ]}, %{is_nullable?: false}}
    ]

  defp response_schema(1),
    do: [
      topics:
        {{:array,
          [
            topic: {:string, %{is_nullable?: false}},
            partitions:
              {{:array,
                [
                  error_code: {:int16, %{is_nullable?: false}},
                  partition: {:int32, %{is_nullable?: false}},
                  leader_epoch: {:int32, %{is_nullable?: false}},
                  end_offset: {:int64, %{is_nullable?: false}}
                ]}, %{is_nullable?: false}}
          ]}, %{is_nullable?: false}}
    ]

  defp response_schema(2),
    do: [
      throttle_time_ms: {:int32, %{is_nullable?: false}},
      topics:
        {{:array,
          [
            topic: {:string, %{is_nullable?: false}},
            partitions:
              {{:array,
                [
                  error_code: {:int16, %{is_nullable?: false}},
                  partition: {:int32, %{is_nullable?: false}},
                  leader_epoch: {:int32, %{is_nullable?: false}},
                  end_offset: {:int64, %{is_nullable?: false}}
                ]}, %{is_nullable?: false}}
          ]}, %{is_nullable?: false}}
    ]

  defp response_schema(3),
    do: [
      throttle_time_ms: {:int32, %{is_nullable?: false}},
      topics:
        {{:array,
          [
            topic: {:string, %{is_nullable?: false}},
            partitions:
              {{:array,
                [
                  error_code: {:int16, %{is_nullable?: false}},
                  partition: {:int32, %{is_nullable?: false}},
                  leader_epoch: {:int32, %{is_nullable?: false}},
                  end_offset: {:int64, %{is_nullable?: false}}
                ]}, %{is_nullable?: false}}
          ]}, %{is_nullable?: false}}
    ]

  defp response_schema(4),
    do: [
      throttle_time_ms: {:int32, %{is_nullable?: false}},
      topics:
        {{:compact_array,
          [
            topic: {:compact_string, %{is_nullable?: false}},
            partitions:
              {{:compact_array,
                [
                  error_code: {:int16, %{is_nullable?: false}},
                  partition: {:int32, %{is_nullable?: false}},
                  leader_epoch: {:int32, %{is_nullable?: false}},
                  end_offset: {:int64, %{is_nullable?: false}},
                  tag_buffer: {:tag_buffer, %{}}
                ]}, %{is_nullable?: false}},
            tag_buffer: {:tag_buffer, %{}}
          ]}, %{is_nullable?: false}},
      tag_buffer: {:tag_buffer, %{}}
    ]
end