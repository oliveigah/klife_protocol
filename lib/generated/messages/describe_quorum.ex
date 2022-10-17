defmodule KlifeProtocol.Messages.DescribeQuorum do
  alias KlifeProtocol.Deserializer
  alias KlifeProtocol.Serializer
  alias KlifeProtocol.Header

  @api_key 55
  @min_flexible_version_req 0
  @min_flexible_version_res 0

  def serialize_request(input, version) do
    input
    |> Map.put(:request_api_key, @api_key)
    |> Map.put(:request_api_version, version)
    |> Header.serialize_request(req_header_version(version))
    |> then(&Serializer.execute(input, request_schema(version), &1))
  end

  def deserialize_response(data, version) do
    with {headers, rest_data} <- Header.deserialize_response(data, res_header_version(version)),
         {content, <<>>} <- Deserializer.execute(rest_data, response_schema(version)) do
      %{headers: headers, content: content}
    end
  end

  defp req_header_version(msg_version),
    do: if(msg_version >= @min_flexible_version_req, do: 2, else: 1)

  defp res_header_version(msg_version),
    do: if(msg_version >= @min_flexible_version_res, do: 1, else: 0)

  defp request_schema(0),
    do: [
      topics:
        {{:compact_array,
          [
            topic_name: {:compact_string, %{is_nullable?: false}},
            partitions:
              {{:compact_array,
                [partition_index: {:int32, %{is_nullable?: false}}, tag_buffer: {:tag_buffer, []}]},
               %{is_nullable?: false}},
            tag_buffer: {:tag_buffer, []}
          ]}, %{is_nullable?: false}},
      tag_buffer: {:tag_buffer, []}
    ]

  defp request_schema(1),
    do: [
      topics:
        {{:compact_array,
          [
            topic_name: {:compact_string, %{is_nullable?: false}},
            partitions:
              {{:compact_array,
                [partition_index: {:int32, %{is_nullable?: false}}, tag_buffer: {:tag_buffer, []}]},
               %{is_nullable?: false}},
            tag_buffer: {:tag_buffer, []}
          ]}, %{is_nullable?: false}},
      tag_buffer: {:tag_buffer, []}
    ]

  defp response_schema(0),
    do: [
      error_code: {:int16, %{is_nullable?: false}},
      topics:
        {{:compact_array,
          [
            topic_name: {:compact_string, %{is_nullable?: false}},
            partitions:
              {{:compact_array,
                [
                  partition_index: {:int32, %{is_nullable?: false}},
                  error_code: {:int16, %{is_nullable?: false}},
                  leader_id: {:int32, %{is_nullable?: false}},
                  leader_epoch: {:int32, %{is_nullable?: false}},
                  high_watermark: {:int64, %{is_nullable?: false}},
                  current_voters:
                    {{:compact_array,
                      [
                        replica_id: {:int32, %{is_nullable?: false}},
                        log_end_offset: {:int64, %{is_nullable?: false}},
                        tag_buffer: {:tag_buffer, %{}}
                      ]}, %{is_nullable?: false}},
                  observers:
                    {{:compact_array,
                      [
                        replica_id: {:int32, %{is_nullable?: false}},
                        log_end_offset: {:int64, %{is_nullable?: false}},
                        tag_buffer: {:tag_buffer, %{}}
                      ]}, %{is_nullable?: false}},
                  tag_buffer: {:tag_buffer, %{}}
                ]}, %{is_nullable?: false}},
            tag_buffer: {:tag_buffer, %{}}
          ]}, %{is_nullable?: false}},
      tag_buffer: {:tag_buffer, %{}}
    ]

  defp response_schema(1),
    do: [
      error_code: {:int16, %{is_nullable?: false}},
      topics:
        {{:compact_array,
          [
            topic_name: {:compact_string, %{is_nullable?: false}},
            partitions:
              {{:compact_array,
                [
                  partition_index: {:int32, %{is_nullable?: false}},
                  error_code: {:int16, %{is_nullable?: false}},
                  leader_id: {:int32, %{is_nullable?: false}},
                  leader_epoch: {:int32, %{is_nullable?: false}},
                  high_watermark: {:int64, %{is_nullable?: false}},
                  current_voters:
                    {{:compact_array,
                      [
                        replica_id: {:int32, %{is_nullable?: false}},
                        log_end_offset: {:int64, %{is_nullable?: false}},
                        last_fetch_timestamp: {:int64, %{is_nullable?: false}},
                        last_caught_up_timestamp: {:int64, %{is_nullable?: false}},
                        tag_buffer: {:tag_buffer, %{}}
                      ]}, %{is_nullable?: false}},
                  observers:
                    {{:compact_array,
                      [
                        replica_id: {:int32, %{is_nullable?: false}},
                        log_end_offset: {:int64, %{is_nullable?: false}},
                        last_fetch_timestamp: {:int64, %{is_nullable?: false}},
                        last_caught_up_timestamp: {:int64, %{is_nullable?: false}},
                        tag_buffer: {:tag_buffer, %{}}
                      ]}, %{is_nullable?: false}},
                  tag_buffer: {:tag_buffer, %{}}
                ]}, %{is_nullable?: false}},
            tag_buffer: {:tag_buffer, %{}}
          ]}, %{is_nullable?: false}},
      tag_buffer: {:tag_buffer, %{}}
    ]
end