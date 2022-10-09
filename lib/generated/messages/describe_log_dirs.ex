defmodule KlifeProtocol.Messages.DescribeLogDirs do
  alias KlifeProtocol.Deserializer
  alias KlifeProtocol.Serializer
  alias KlifeProtocol.Header

  @api_key 35
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
      topics:
        {{:array,
          [
            topic: {:string, %{is_nullable?: false}},
            partitions: {{:array, :int32}, %{is_nullable?: false}}
          ]}, %{is_nullable?: true}}
    ]

  defp request_schema(1),
    do: [
      topics:
        {{:array,
          [
            topic: {:string, %{is_nullable?: false}},
            partitions: {{:array, :int32}, %{is_nullable?: false}}
          ]}, %{is_nullable?: true}}
    ]

  defp request_schema(2),
    do: [
      topics:
        {{:compact_array,
          [
            topic: {:compact_string, %{is_nullable?: false}},
            partitions: {{:compact_array, :int32}, %{is_nullable?: false}},
            tag_buffer: {:tag_buffer, []}
          ]}, %{is_nullable?: true}},
      tag_buffer: {:tag_buffer, []}
    ]

  defp request_schema(3),
    do: [
      topics:
        {{:compact_array,
          [
            topic: {:compact_string, %{is_nullable?: false}},
            partitions: {{:compact_array, :int32}, %{is_nullable?: false}},
            tag_buffer: {:tag_buffer, []}
          ]}, %{is_nullable?: true}},
      tag_buffer: {:tag_buffer, []}
    ]

  defp request_schema(4),
    do: [
      topics:
        {{:compact_array,
          [
            topic: {:compact_string, %{is_nullable?: false}},
            partitions: {{:compact_array, :int32}, %{is_nullable?: false}},
            tag_buffer: {:tag_buffer, []}
          ]}, %{is_nullable?: true}},
      tag_buffer: {:tag_buffer, []}
    ]

  defp response_schema(0),
    do: [
      throttle_time_ms: {:int32, %{is_nullable?: false}},
      results:
        {{:array,
          [
            error_code: {:int16, %{is_nullable?: false}},
            log_dir: {:string, %{is_nullable?: false}},
            topics:
              {{:array,
                [
                  name: {:string, %{is_nullable?: false}},
                  partitions:
                    {{:array,
                      [
                        partition_index: {:int32, %{is_nullable?: false}},
                        partition_size: {:int64, %{is_nullable?: false}},
                        offset_lag: {:int64, %{is_nullable?: false}},
                        is_future_key: {:boolean, %{is_nullable?: false}}
                      ]}, %{is_nullable?: false}}
                ]}, %{is_nullable?: false}}
          ]}, %{is_nullable?: false}}
    ]

  defp response_schema(1),
    do: [
      throttle_time_ms: {:int32, %{is_nullable?: false}},
      results:
        {{:array,
          [
            error_code: {:int16, %{is_nullable?: false}},
            log_dir: {:string, %{is_nullable?: false}},
            topics:
              {{:array,
                [
                  name: {:string, %{is_nullable?: false}},
                  partitions:
                    {{:array,
                      [
                        partition_index: {:int32, %{is_nullable?: false}},
                        partition_size: {:int64, %{is_nullable?: false}},
                        offset_lag: {:int64, %{is_nullable?: false}},
                        is_future_key: {:boolean, %{is_nullable?: false}}
                      ]}, %{is_nullable?: false}}
                ]}, %{is_nullable?: false}}
          ]}, %{is_nullable?: false}}
    ]

  defp response_schema(2),
    do: [
      throttle_time_ms: {:int32, %{is_nullable?: false}},
      results:
        {{:compact_array,
          [
            error_code: {:int16, %{is_nullable?: false}},
            log_dir: {:compact_string, %{is_nullable?: false}},
            topics:
              {{:compact_array,
                [
                  name: {:compact_string, %{is_nullable?: false}},
                  partitions:
                    {{:compact_array,
                      [
                        partition_index: {:int32, %{is_nullable?: false}},
                        partition_size: {:int64, %{is_nullable?: false}},
                        offset_lag: {:int64, %{is_nullable?: false}},
                        is_future_key: {:boolean, %{is_nullable?: false}},
                        tag_buffer: {:tag_buffer, %{}}
                      ]}, %{is_nullable?: false}},
                  tag_buffer: {:tag_buffer, %{}}
                ]}, %{is_nullable?: false}},
            tag_buffer: {:tag_buffer, %{}}
          ]}, %{is_nullable?: false}},
      tag_buffer: {:tag_buffer, %{}}
    ]

  defp response_schema(3),
    do: [
      throttle_time_ms: {:int32, %{is_nullable?: false}},
      error_code: {:int16, %{is_nullable?: false}},
      results:
        {{:compact_array,
          [
            error_code: {:int16, %{is_nullable?: false}},
            log_dir: {:compact_string, %{is_nullable?: false}},
            topics:
              {{:compact_array,
                [
                  name: {:compact_string, %{is_nullable?: false}},
                  partitions:
                    {{:compact_array,
                      [
                        partition_index: {:int32, %{is_nullable?: false}},
                        partition_size: {:int64, %{is_nullable?: false}},
                        offset_lag: {:int64, %{is_nullable?: false}},
                        is_future_key: {:boolean, %{is_nullable?: false}},
                        tag_buffer: {:tag_buffer, %{}}
                      ]}, %{is_nullable?: false}},
                  tag_buffer: {:tag_buffer, %{}}
                ]}, %{is_nullable?: false}},
            tag_buffer: {:tag_buffer, %{}}
          ]}, %{is_nullable?: false}},
      tag_buffer: {:tag_buffer, %{}}
    ]

  defp response_schema(4),
    do: [
      throttle_time_ms: {:int32, %{is_nullable?: false}},
      error_code: {:int16, %{is_nullable?: false}},
      results:
        {{:compact_array,
          [
            error_code: {:int16, %{is_nullable?: false}},
            log_dir: {:compact_string, %{is_nullable?: false}},
            topics:
              {{:compact_array,
                [
                  name: {:compact_string, %{is_nullable?: false}},
                  partitions:
                    {{:compact_array,
                      [
                        partition_index: {:int32, %{is_nullable?: false}},
                        partition_size: {:int64, %{is_nullable?: false}},
                        offset_lag: {:int64, %{is_nullable?: false}},
                        is_future_key: {:boolean, %{is_nullable?: false}},
                        tag_buffer: {:tag_buffer, %{}}
                      ]}, %{is_nullable?: false}},
                  tag_buffer: {:tag_buffer, %{}}
                ]}, %{is_nullable?: false}},
            total_bytes: {:int64, %{is_nullable?: false}},
            usable_bytes: {:int64, %{is_nullable?: false}},
            tag_buffer: {:tag_buffer, %{}}
          ]}, %{is_nullable?: false}},
      tag_buffer: {:tag_buffer, %{}}
    ]
end