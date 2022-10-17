defmodule KlifeProtocol.Messages.Produce do
  alias KlifeProtocol.Deserializer
  alias KlifeProtocol.Serializer
  alias KlifeProtocol.Header

  @api_key 0
  @min_flexible_version_req 9
  @min_flexible_version_res 9

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
      acks: {:int16, %{is_nullable?: false}},
      timeout_ms: {:int32, %{is_nullable?: false}},
      topic_data:
        {{:array,
          [
            name: {:string, %{is_nullable?: false}},
            partition_data:
              {{:array,
                [
                  index: {:int32, %{is_nullable?: false}},
                  records: {:records, %{is_nullable?: true}}
                ]}, %{is_nullable?: false}}
          ]}, %{is_nullable?: false}}
    ]

  defp request_schema(1),
    do: [
      acks: {:int16, %{is_nullable?: false}},
      timeout_ms: {:int32, %{is_nullable?: false}},
      topic_data:
        {{:array,
          [
            name: {:string, %{is_nullable?: false}},
            partition_data:
              {{:array,
                [
                  index: {:int32, %{is_nullable?: false}},
                  records: {:records, %{is_nullable?: true}}
                ]}, %{is_nullable?: false}}
          ]}, %{is_nullable?: false}}
    ]

  defp request_schema(2),
    do: [
      acks: {:int16, %{is_nullable?: false}},
      timeout_ms: {:int32, %{is_nullable?: false}},
      topic_data:
        {{:array,
          [
            name: {:string, %{is_nullable?: false}},
            partition_data:
              {{:array,
                [
                  index: {:int32, %{is_nullable?: false}},
                  records: {:records, %{is_nullable?: true}}
                ]}, %{is_nullable?: false}}
          ]}, %{is_nullable?: false}}
    ]

  defp request_schema(3),
    do: [
      transactional_id: {:string, %{is_nullable?: true}},
      acks: {:int16, %{is_nullable?: false}},
      timeout_ms: {:int32, %{is_nullable?: false}},
      topic_data:
        {{:array,
          [
            name: {:string, %{is_nullable?: false}},
            partition_data:
              {{:array,
                [
                  index: {:int32, %{is_nullable?: false}},
                  records: {:records, %{is_nullable?: true}}
                ]}, %{is_nullable?: false}}
          ]}, %{is_nullable?: false}}
    ]

  defp request_schema(4),
    do: [
      transactional_id: {:string, %{is_nullable?: true}},
      acks: {:int16, %{is_nullable?: false}},
      timeout_ms: {:int32, %{is_nullable?: false}},
      topic_data:
        {{:array,
          [
            name: {:string, %{is_nullable?: false}},
            partition_data:
              {{:array,
                [
                  index: {:int32, %{is_nullable?: false}},
                  records: {:records, %{is_nullable?: true}}
                ]}, %{is_nullable?: false}}
          ]}, %{is_nullable?: false}}
    ]

  defp request_schema(5),
    do: [
      transactional_id: {:string, %{is_nullable?: true}},
      acks: {:int16, %{is_nullable?: false}},
      timeout_ms: {:int32, %{is_nullable?: false}},
      topic_data:
        {{:array,
          [
            name: {:string, %{is_nullable?: false}},
            partition_data:
              {{:array,
                [
                  index: {:int32, %{is_nullable?: false}},
                  records: {:records, %{is_nullable?: true}}
                ]}, %{is_nullable?: false}}
          ]}, %{is_nullable?: false}}
    ]

  defp request_schema(6),
    do: [
      transactional_id: {:string, %{is_nullable?: true}},
      acks: {:int16, %{is_nullable?: false}},
      timeout_ms: {:int32, %{is_nullable?: false}},
      topic_data:
        {{:array,
          [
            name: {:string, %{is_nullable?: false}},
            partition_data:
              {{:array,
                [
                  index: {:int32, %{is_nullable?: false}},
                  records: {:records, %{is_nullable?: true}}
                ]}, %{is_nullable?: false}}
          ]}, %{is_nullable?: false}}
    ]

  defp request_schema(7),
    do: [
      transactional_id: {:string, %{is_nullable?: true}},
      acks: {:int16, %{is_nullable?: false}},
      timeout_ms: {:int32, %{is_nullable?: false}},
      topic_data:
        {{:array,
          [
            name: {:string, %{is_nullable?: false}},
            partition_data:
              {{:array,
                [
                  index: {:int32, %{is_nullable?: false}},
                  records: {:records, %{is_nullable?: true}}
                ]}, %{is_nullable?: false}}
          ]}, %{is_nullable?: false}}
    ]

  defp request_schema(8),
    do: [
      transactional_id: {:string, %{is_nullable?: true}},
      acks: {:int16, %{is_nullable?: false}},
      timeout_ms: {:int32, %{is_nullable?: false}},
      topic_data:
        {{:array,
          [
            name: {:string, %{is_nullable?: false}},
            partition_data:
              {{:array,
                [
                  index: {:int32, %{is_nullable?: false}},
                  records: {:records, %{is_nullable?: true}}
                ]}, %{is_nullable?: false}}
          ]}, %{is_nullable?: false}}
    ]

  defp request_schema(9),
    do: [
      transactional_id: {:compact_string, %{is_nullable?: true}},
      acks: {:int16, %{is_nullable?: false}},
      timeout_ms: {:int32, %{is_nullable?: false}},
      topic_data:
        {{:compact_array,
          [
            name: {:compact_string, %{is_nullable?: false}},
            partition_data:
              {{:compact_array,
                [
                  index: {:int32, %{is_nullable?: false}},
                  records: {:records, %{is_nullable?: true}},
                  tag_buffer: {:tag_buffer, []}
                ]}, %{is_nullable?: false}},
            tag_buffer: {:tag_buffer, []}
          ]}, %{is_nullable?: false}},
      tag_buffer: {:tag_buffer, []}
    ]

  defp response_schema(0),
    do: [
      responses:
        {{:array,
          [
            name: {:string, %{is_nullable?: false}},
            partition_responses:
              {{:array,
                [
                  index: {:int32, %{is_nullable?: false}},
                  error_code: {:int16, %{is_nullable?: false}},
                  base_offset: {:int64, %{is_nullable?: false}}
                ]}, %{is_nullable?: false}}
          ]}, %{is_nullable?: false}}
    ]

  defp response_schema(1),
    do: [
      responses:
        {{:array,
          [
            name: {:string, %{is_nullable?: false}},
            partition_responses:
              {{:array,
                [
                  index: {:int32, %{is_nullable?: false}},
                  error_code: {:int16, %{is_nullable?: false}},
                  base_offset: {:int64, %{is_nullable?: false}}
                ]}, %{is_nullable?: false}}
          ]}, %{is_nullable?: false}},
      throttle_time_ms: {:int32, %{is_nullable?: false}}
    ]

  defp response_schema(2),
    do: [
      responses:
        {{:array,
          [
            name: {:string, %{is_nullable?: false}},
            partition_responses:
              {{:array,
                [
                  index: {:int32, %{is_nullable?: false}},
                  error_code: {:int16, %{is_nullable?: false}},
                  base_offset: {:int64, %{is_nullable?: false}},
                  log_append_time_ms: {:int64, %{is_nullable?: false}}
                ]}, %{is_nullable?: false}}
          ]}, %{is_nullable?: false}},
      throttle_time_ms: {:int32, %{is_nullable?: false}}
    ]

  defp response_schema(3),
    do: [
      responses:
        {{:array,
          [
            name: {:string, %{is_nullable?: false}},
            partition_responses:
              {{:array,
                [
                  index: {:int32, %{is_nullable?: false}},
                  error_code: {:int16, %{is_nullable?: false}},
                  base_offset: {:int64, %{is_nullable?: false}},
                  log_append_time_ms: {:int64, %{is_nullable?: false}}
                ]}, %{is_nullable?: false}}
          ]}, %{is_nullable?: false}},
      throttle_time_ms: {:int32, %{is_nullable?: false}}
    ]

  defp response_schema(4),
    do: [
      responses:
        {{:array,
          [
            name: {:string, %{is_nullable?: false}},
            partition_responses:
              {{:array,
                [
                  index: {:int32, %{is_nullable?: false}},
                  error_code: {:int16, %{is_nullable?: false}},
                  base_offset: {:int64, %{is_nullable?: false}},
                  log_append_time_ms: {:int64, %{is_nullable?: false}}
                ]}, %{is_nullable?: false}}
          ]}, %{is_nullable?: false}},
      throttle_time_ms: {:int32, %{is_nullable?: false}}
    ]

  defp response_schema(5),
    do: [
      responses:
        {{:array,
          [
            name: {:string, %{is_nullable?: false}},
            partition_responses:
              {{:array,
                [
                  index: {:int32, %{is_nullable?: false}},
                  error_code: {:int16, %{is_nullable?: false}},
                  base_offset: {:int64, %{is_nullable?: false}},
                  log_append_time_ms: {:int64, %{is_nullable?: false}},
                  log_start_offset: {:int64, %{is_nullable?: false}}
                ]}, %{is_nullable?: false}}
          ]}, %{is_nullable?: false}},
      throttle_time_ms: {:int32, %{is_nullable?: false}}
    ]

  defp response_schema(6),
    do: [
      responses:
        {{:array,
          [
            name: {:string, %{is_nullable?: false}},
            partition_responses:
              {{:array,
                [
                  index: {:int32, %{is_nullable?: false}},
                  error_code: {:int16, %{is_nullable?: false}},
                  base_offset: {:int64, %{is_nullable?: false}},
                  log_append_time_ms: {:int64, %{is_nullable?: false}},
                  log_start_offset: {:int64, %{is_nullable?: false}}
                ]}, %{is_nullable?: false}}
          ]}, %{is_nullable?: false}},
      throttle_time_ms: {:int32, %{is_nullable?: false}}
    ]

  defp response_schema(7),
    do: [
      responses:
        {{:array,
          [
            name: {:string, %{is_nullable?: false}},
            partition_responses:
              {{:array,
                [
                  index: {:int32, %{is_nullable?: false}},
                  error_code: {:int16, %{is_nullable?: false}},
                  base_offset: {:int64, %{is_nullable?: false}},
                  log_append_time_ms: {:int64, %{is_nullable?: false}},
                  log_start_offset: {:int64, %{is_nullable?: false}}
                ]}, %{is_nullable?: false}}
          ]}, %{is_nullable?: false}},
      throttle_time_ms: {:int32, %{is_nullable?: false}}
    ]

  defp response_schema(8),
    do: [
      responses:
        {{:array,
          [
            name: {:string, %{is_nullable?: false}},
            partition_responses:
              {{:array,
                [
                  index: {:int32, %{is_nullable?: false}},
                  error_code: {:int16, %{is_nullable?: false}},
                  base_offset: {:int64, %{is_nullable?: false}},
                  log_append_time_ms: {:int64, %{is_nullable?: false}},
                  log_start_offset: {:int64, %{is_nullable?: false}},
                  record_errors:
                    {{:array,
                      [
                        batch_index: {:int32, %{is_nullable?: false}},
                        batch_index_error_message: {:string, %{is_nullable?: true}}
                      ]}, %{is_nullable?: false}},
                  error_message: {:string, %{is_nullable?: true}}
                ]}, %{is_nullable?: false}}
          ]}, %{is_nullable?: false}},
      throttle_time_ms: {:int32, %{is_nullable?: false}}
    ]

  defp response_schema(9),
    do: [
      responses:
        {{:compact_array,
          [
            name: {:compact_string, %{is_nullable?: false}},
            partition_responses:
              {{:compact_array,
                [
                  index: {:int32, %{is_nullable?: false}},
                  error_code: {:int16, %{is_nullable?: false}},
                  base_offset: {:int64, %{is_nullable?: false}},
                  log_append_time_ms: {:int64, %{is_nullable?: false}},
                  log_start_offset: {:int64, %{is_nullable?: false}},
                  record_errors:
                    {{:compact_array,
                      [
                        batch_index: {:int32, %{is_nullable?: false}},
                        batch_index_error_message: {:compact_string, %{is_nullable?: true}},
                        tag_buffer: {:tag_buffer, %{}}
                      ]}, %{is_nullable?: false}},
                  error_message: {:compact_string, %{is_nullable?: true}},
                  tag_buffer: {:tag_buffer, %{}}
                ]}, %{is_nullable?: false}},
            tag_buffer: {:tag_buffer, %{}}
          ]}, %{is_nullable?: false}},
      throttle_time_ms: {:int32, %{is_nullable?: false}},
      tag_buffer: {:tag_buffer, %{}}
    ]
end