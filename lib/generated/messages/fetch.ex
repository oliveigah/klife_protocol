defmodule KlifeProtocol.Messages.Fetch do
  alias KlifeProtocol.Deserializer
  alias KlifeProtocol.Serializer
  alias KlifeProtocol.Header

  @api_key 1
  @min_flexible_version_req 12
  @min_flexible_version_res 12

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
      replica_id: {:int32, %{is_nullable?: false}},
      max_wait_ms: {:int32, %{is_nullable?: false}},
      min_bytes: {:int32, %{is_nullable?: false}},
      topics:
        {{:array,
          [
            topic: {:string, %{is_nullable?: false}},
            partitions:
              {{:array,
                [
                  partition: {:int32, %{is_nullable?: false}},
                  fetch_offset: {:int64, %{is_nullable?: false}},
                  partition_max_bytes: {:int32, %{is_nullable?: false}}
                ]}, %{is_nullable?: false}}
          ]}, %{is_nullable?: false}}
    ]

  defp request_schema(1),
    do: [
      replica_id: {:int32, %{is_nullable?: false}},
      max_wait_ms: {:int32, %{is_nullable?: false}},
      min_bytes: {:int32, %{is_nullable?: false}},
      topics:
        {{:array,
          [
            topic: {:string, %{is_nullable?: false}},
            partitions:
              {{:array,
                [
                  partition: {:int32, %{is_nullable?: false}},
                  fetch_offset: {:int64, %{is_nullable?: false}},
                  partition_max_bytes: {:int32, %{is_nullable?: false}}
                ]}, %{is_nullable?: false}}
          ]}, %{is_nullable?: false}}
    ]

  defp request_schema(2),
    do: [
      replica_id: {:int32, %{is_nullable?: false}},
      max_wait_ms: {:int32, %{is_nullable?: false}},
      min_bytes: {:int32, %{is_nullable?: false}},
      topics:
        {{:array,
          [
            topic: {:string, %{is_nullable?: false}},
            partitions:
              {{:array,
                [
                  partition: {:int32, %{is_nullable?: false}},
                  fetch_offset: {:int64, %{is_nullable?: false}},
                  partition_max_bytes: {:int32, %{is_nullable?: false}}
                ]}, %{is_nullable?: false}}
          ]}, %{is_nullable?: false}}
    ]

  defp request_schema(3),
    do: [
      replica_id: {:int32, %{is_nullable?: false}},
      max_wait_ms: {:int32, %{is_nullable?: false}},
      min_bytes: {:int32, %{is_nullable?: false}},
      max_bytes: {:int32, %{is_nullable?: false}},
      topics:
        {{:array,
          [
            topic: {:string, %{is_nullable?: false}},
            partitions:
              {{:array,
                [
                  partition: {:int32, %{is_nullable?: false}},
                  fetch_offset: {:int64, %{is_nullable?: false}},
                  partition_max_bytes: {:int32, %{is_nullable?: false}}
                ]}, %{is_nullable?: false}}
          ]}, %{is_nullable?: false}}
    ]

  defp request_schema(4),
    do: [
      replica_id: {:int32, %{is_nullable?: false}},
      max_wait_ms: {:int32, %{is_nullable?: false}},
      min_bytes: {:int32, %{is_nullable?: false}},
      max_bytes: {:int32, %{is_nullable?: false}},
      isolation_level: {:int8, %{is_nullable?: false}},
      topics:
        {{:array,
          [
            topic: {:string, %{is_nullable?: false}},
            partitions:
              {{:array,
                [
                  partition: {:int32, %{is_nullable?: false}},
                  fetch_offset: {:int64, %{is_nullable?: false}},
                  partition_max_bytes: {:int32, %{is_nullable?: false}}
                ]}, %{is_nullable?: false}}
          ]}, %{is_nullable?: false}}
    ]

  defp request_schema(5),
    do: [
      replica_id: {:int32, %{is_nullable?: false}},
      max_wait_ms: {:int32, %{is_nullable?: false}},
      min_bytes: {:int32, %{is_nullable?: false}},
      max_bytes: {:int32, %{is_nullable?: false}},
      isolation_level: {:int8, %{is_nullable?: false}},
      topics:
        {{:array,
          [
            topic: {:string, %{is_nullable?: false}},
            partitions:
              {{:array,
                [
                  partition: {:int32, %{is_nullable?: false}},
                  fetch_offset: {:int64, %{is_nullable?: false}},
                  log_start_offset: {:int64, %{is_nullable?: false}},
                  partition_max_bytes: {:int32, %{is_nullable?: false}}
                ]}, %{is_nullable?: false}}
          ]}, %{is_nullable?: false}}
    ]

  defp request_schema(6),
    do: [
      replica_id: {:int32, %{is_nullable?: false}},
      max_wait_ms: {:int32, %{is_nullable?: false}},
      min_bytes: {:int32, %{is_nullable?: false}},
      max_bytes: {:int32, %{is_nullable?: false}},
      isolation_level: {:int8, %{is_nullable?: false}},
      topics:
        {{:array,
          [
            topic: {:string, %{is_nullable?: false}},
            partitions:
              {{:array,
                [
                  partition: {:int32, %{is_nullable?: false}},
                  fetch_offset: {:int64, %{is_nullable?: false}},
                  log_start_offset: {:int64, %{is_nullable?: false}},
                  partition_max_bytes: {:int32, %{is_nullable?: false}}
                ]}, %{is_nullable?: false}}
          ]}, %{is_nullable?: false}}
    ]

  defp request_schema(7),
    do: [
      replica_id: {:int32, %{is_nullable?: false}},
      max_wait_ms: {:int32, %{is_nullable?: false}},
      min_bytes: {:int32, %{is_nullable?: false}},
      max_bytes: {:int32, %{is_nullable?: false}},
      isolation_level: {:int8, %{is_nullable?: false}},
      session_id: {:int32, %{is_nullable?: false}},
      session_epoch: {:int32, %{is_nullable?: false}},
      topics:
        {{:array,
          [
            topic: {:string, %{is_nullable?: false}},
            partitions:
              {{:array,
                [
                  partition: {:int32, %{is_nullable?: false}},
                  fetch_offset: {:int64, %{is_nullable?: false}},
                  log_start_offset: {:int64, %{is_nullable?: false}},
                  partition_max_bytes: {:int32, %{is_nullable?: false}}
                ]}, %{is_nullable?: false}}
          ]}, %{is_nullable?: false}},
      forgotten_topics_data:
        {{:array,
          [
            topic: {:string, %{is_nullable?: false}},
            partitions: {{:array, :int32}, %{is_nullable?: false}}
          ]}, %{is_nullable?: false}}
    ]

  defp request_schema(8),
    do: [
      replica_id: {:int32, %{is_nullable?: false}},
      max_wait_ms: {:int32, %{is_nullable?: false}},
      min_bytes: {:int32, %{is_nullable?: false}},
      max_bytes: {:int32, %{is_nullable?: false}},
      isolation_level: {:int8, %{is_nullable?: false}},
      session_id: {:int32, %{is_nullable?: false}},
      session_epoch: {:int32, %{is_nullable?: false}},
      topics:
        {{:array,
          [
            topic: {:string, %{is_nullable?: false}},
            partitions:
              {{:array,
                [
                  partition: {:int32, %{is_nullable?: false}},
                  fetch_offset: {:int64, %{is_nullable?: false}},
                  log_start_offset: {:int64, %{is_nullable?: false}},
                  partition_max_bytes: {:int32, %{is_nullable?: false}}
                ]}, %{is_nullable?: false}}
          ]}, %{is_nullable?: false}},
      forgotten_topics_data:
        {{:array,
          [
            topic: {:string, %{is_nullable?: false}},
            partitions: {{:array, :int32}, %{is_nullable?: false}}
          ]}, %{is_nullable?: false}}
    ]

  defp request_schema(9),
    do: [
      replica_id: {:int32, %{is_nullable?: false}},
      max_wait_ms: {:int32, %{is_nullable?: false}},
      min_bytes: {:int32, %{is_nullable?: false}},
      max_bytes: {:int32, %{is_nullable?: false}},
      isolation_level: {:int8, %{is_nullable?: false}},
      session_id: {:int32, %{is_nullable?: false}},
      session_epoch: {:int32, %{is_nullable?: false}},
      topics:
        {{:array,
          [
            topic: {:string, %{is_nullable?: false}},
            partitions:
              {{:array,
                [
                  partition: {:int32, %{is_nullable?: false}},
                  current_leader_epoch: {:int32, %{is_nullable?: false}},
                  fetch_offset: {:int64, %{is_nullable?: false}},
                  log_start_offset: {:int64, %{is_nullable?: false}},
                  partition_max_bytes: {:int32, %{is_nullable?: false}}
                ]}, %{is_nullable?: false}}
          ]}, %{is_nullable?: false}},
      forgotten_topics_data:
        {{:array,
          [
            topic: {:string, %{is_nullable?: false}},
            partitions: {{:array, :int32}, %{is_nullable?: false}}
          ]}, %{is_nullable?: false}}
    ]

  defp request_schema(10),
    do: [
      replica_id: {:int32, %{is_nullable?: false}},
      max_wait_ms: {:int32, %{is_nullable?: false}},
      min_bytes: {:int32, %{is_nullable?: false}},
      max_bytes: {:int32, %{is_nullable?: false}},
      isolation_level: {:int8, %{is_nullable?: false}},
      session_id: {:int32, %{is_nullable?: false}},
      session_epoch: {:int32, %{is_nullable?: false}},
      topics:
        {{:array,
          [
            topic: {:string, %{is_nullable?: false}},
            partitions:
              {{:array,
                [
                  partition: {:int32, %{is_nullable?: false}},
                  current_leader_epoch: {:int32, %{is_nullable?: false}},
                  fetch_offset: {:int64, %{is_nullable?: false}},
                  log_start_offset: {:int64, %{is_nullable?: false}},
                  partition_max_bytes: {:int32, %{is_nullable?: false}}
                ]}, %{is_nullable?: false}}
          ]}, %{is_nullable?: false}},
      forgotten_topics_data:
        {{:array,
          [
            topic: {:string, %{is_nullable?: false}},
            partitions: {{:array, :int32}, %{is_nullable?: false}}
          ]}, %{is_nullable?: false}}
    ]

  defp request_schema(11),
    do: [
      replica_id: {:int32, %{is_nullable?: false}},
      max_wait_ms: {:int32, %{is_nullable?: false}},
      min_bytes: {:int32, %{is_nullable?: false}},
      max_bytes: {:int32, %{is_nullable?: false}},
      isolation_level: {:int8, %{is_nullable?: false}},
      session_id: {:int32, %{is_nullable?: false}},
      session_epoch: {:int32, %{is_nullable?: false}},
      topics:
        {{:array,
          [
            topic: {:string, %{is_nullable?: false}},
            partitions:
              {{:array,
                [
                  partition: {:int32, %{is_nullable?: false}},
                  current_leader_epoch: {:int32, %{is_nullable?: false}},
                  fetch_offset: {:int64, %{is_nullable?: false}},
                  log_start_offset: {:int64, %{is_nullable?: false}},
                  partition_max_bytes: {:int32, %{is_nullable?: false}}
                ]}, %{is_nullable?: false}}
          ]}, %{is_nullable?: false}},
      forgotten_topics_data:
        {{:array,
          [
            topic: {:string, %{is_nullable?: false}},
            partitions: {{:array, :int32}, %{is_nullable?: false}}
          ]}, %{is_nullable?: false}},
      rack_id: {:string, %{is_nullable?: false}}
    ]

  defp request_schema(12),
    do: [
      replica_id: {:int32, %{is_nullable?: false}},
      max_wait_ms: {:int32, %{is_nullable?: false}},
      min_bytes: {:int32, %{is_nullable?: false}},
      max_bytes: {:int32, %{is_nullable?: false}},
      isolation_level: {:int8, %{is_nullable?: false}},
      session_id: {:int32, %{is_nullable?: false}},
      session_epoch: {:int32, %{is_nullable?: false}},
      topics:
        {{:compact_array,
          [
            topic: {:compact_string, %{is_nullable?: false}},
            partitions:
              {{:compact_array,
                [
                  partition: {:int32, %{is_nullable?: false}},
                  current_leader_epoch: {:int32, %{is_nullable?: false}},
                  fetch_offset: {:int64, %{is_nullable?: false}},
                  last_fetched_epoch: {:int32, %{is_nullable?: false}},
                  log_start_offset: {:int64, %{is_nullable?: false}},
                  partition_max_bytes: {:int32, %{is_nullable?: false}},
                  tag_buffer: {:tag_buffer, []}
                ]}, %{is_nullable?: false}},
            tag_buffer: {:tag_buffer, []}
          ]}, %{is_nullable?: false}},
      forgotten_topics_data:
        {{:compact_array,
          [
            topic: {:compact_string, %{is_nullable?: false}},
            partitions: {{:compact_array, :int32}, %{is_nullable?: false}},
            tag_buffer: {:tag_buffer, []}
          ]}, %{is_nullable?: false}},
      rack_id: {:compact_string, %{is_nullable?: false}},
      tag_buffer: {:tag_buffer, [cluster_id: {{0, :compact_string}, %{is_nullable?: true}}]}
    ]

  defp request_schema(13),
    do: [
      replica_id: {:int32, %{is_nullable?: false}},
      max_wait_ms: {:int32, %{is_nullable?: false}},
      min_bytes: {:int32, %{is_nullable?: false}},
      max_bytes: {:int32, %{is_nullable?: false}},
      isolation_level: {:int8, %{is_nullable?: false}},
      session_id: {:int32, %{is_nullable?: false}},
      session_epoch: {:int32, %{is_nullable?: false}},
      topics:
        {{:compact_array,
          [
            topic_id: {:uuid, %{is_nullable?: false}},
            partitions:
              {{:compact_array,
                [
                  partition: {:int32, %{is_nullable?: false}},
                  current_leader_epoch: {:int32, %{is_nullable?: false}},
                  fetch_offset: {:int64, %{is_nullable?: false}},
                  last_fetched_epoch: {:int32, %{is_nullable?: false}},
                  log_start_offset: {:int64, %{is_nullable?: false}},
                  partition_max_bytes: {:int32, %{is_nullable?: false}},
                  tag_buffer: {:tag_buffer, []}
                ]}, %{is_nullable?: false}},
            tag_buffer: {:tag_buffer, []}
          ]}, %{is_nullable?: false}},
      forgotten_topics_data:
        {{:compact_array,
          [
            topic_id: {:uuid, %{is_nullable?: false}},
            partitions: {{:compact_array, :int32}, %{is_nullable?: false}},
            tag_buffer: {:tag_buffer, []}
          ]}, %{is_nullable?: false}},
      rack_id: {:compact_string, %{is_nullable?: false}},
      tag_buffer: {:tag_buffer, [cluster_id: {{0, :compact_string}, %{is_nullable?: true}}]}
    ]

  defp response_schema(0),
    do: [
      responses:
        {{:array,
          [
            topic: {:string, %{is_nullable?: false}},
            partitions:
              {{:array,
                [
                  partition_index: {:int32, %{is_nullable?: false}},
                  error_code: {:int16, %{is_nullable?: false}},
                  high_watermark: {:int64, %{is_nullable?: false}},
                  records: {:records, %{is_nullable?: true}}
                ]}, %{is_nullable?: false}}
          ]}, %{is_nullable?: false}}
    ]

  defp response_schema(1),
    do: [
      throttle_time_ms: {:int32, %{is_nullable?: false}},
      responses:
        {{:array,
          [
            topic: {:string, %{is_nullable?: false}},
            partitions:
              {{:array,
                [
                  partition_index: {:int32, %{is_nullable?: false}},
                  error_code: {:int16, %{is_nullable?: false}},
                  high_watermark: {:int64, %{is_nullable?: false}},
                  records: {:records, %{is_nullable?: true}}
                ]}, %{is_nullable?: false}}
          ]}, %{is_nullable?: false}}
    ]

  defp response_schema(2),
    do: [
      throttle_time_ms: {:int32, %{is_nullable?: false}},
      responses:
        {{:array,
          [
            topic: {:string, %{is_nullable?: false}},
            partitions:
              {{:array,
                [
                  partition_index: {:int32, %{is_nullable?: false}},
                  error_code: {:int16, %{is_nullable?: false}},
                  high_watermark: {:int64, %{is_nullable?: false}},
                  records: {:records, %{is_nullable?: true}}
                ]}, %{is_nullable?: false}}
          ]}, %{is_nullable?: false}}
    ]

  defp response_schema(3),
    do: [
      throttle_time_ms: {:int32, %{is_nullable?: false}},
      responses:
        {{:array,
          [
            topic: {:string, %{is_nullable?: false}},
            partitions:
              {{:array,
                [
                  partition_index: {:int32, %{is_nullable?: false}},
                  error_code: {:int16, %{is_nullable?: false}},
                  high_watermark: {:int64, %{is_nullable?: false}},
                  records: {:records, %{is_nullable?: true}}
                ]}, %{is_nullable?: false}}
          ]}, %{is_nullable?: false}}
    ]

  defp response_schema(4),
    do: [
      throttle_time_ms: {:int32, %{is_nullable?: false}},
      responses:
        {{:array,
          [
            topic: {:string, %{is_nullable?: false}},
            partitions:
              {{:array,
                [
                  partition_index: {:int32, %{is_nullable?: false}},
                  error_code: {:int16, %{is_nullable?: false}},
                  high_watermark: {:int64, %{is_nullable?: false}},
                  last_stable_offset: {:int64, %{is_nullable?: false}},
                  aborted_transactions:
                    {{:array,
                      [
                        producer_id: {:int64, %{is_nullable?: false}},
                        first_offset: {:int64, %{is_nullable?: false}}
                      ]}, %{is_nullable?: true}},
                  records: {:records, %{is_nullable?: true}}
                ]}, %{is_nullable?: false}}
          ]}, %{is_nullable?: false}}
    ]

  defp response_schema(5),
    do: [
      throttle_time_ms: {:int32, %{is_nullable?: false}},
      responses:
        {{:array,
          [
            topic: {:string, %{is_nullable?: false}},
            partitions:
              {{:array,
                [
                  partition_index: {:int32, %{is_nullable?: false}},
                  error_code: {:int16, %{is_nullable?: false}},
                  high_watermark: {:int64, %{is_nullable?: false}},
                  last_stable_offset: {:int64, %{is_nullable?: false}},
                  log_start_offset: {:int64, %{is_nullable?: false}},
                  aborted_transactions:
                    {{:array,
                      [
                        producer_id: {:int64, %{is_nullable?: false}},
                        first_offset: {:int64, %{is_nullable?: false}}
                      ]}, %{is_nullable?: true}},
                  records: {:records, %{is_nullable?: true}}
                ]}, %{is_nullable?: false}}
          ]}, %{is_nullable?: false}}
    ]

  defp response_schema(6),
    do: [
      throttle_time_ms: {:int32, %{is_nullable?: false}},
      responses:
        {{:array,
          [
            topic: {:string, %{is_nullable?: false}},
            partitions:
              {{:array,
                [
                  partition_index: {:int32, %{is_nullable?: false}},
                  error_code: {:int16, %{is_nullable?: false}},
                  high_watermark: {:int64, %{is_nullable?: false}},
                  last_stable_offset: {:int64, %{is_nullable?: false}},
                  log_start_offset: {:int64, %{is_nullable?: false}},
                  aborted_transactions:
                    {{:array,
                      [
                        producer_id: {:int64, %{is_nullable?: false}},
                        first_offset: {:int64, %{is_nullable?: false}}
                      ]}, %{is_nullable?: true}},
                  records: {:records, %{is_nullable?: true}}
                ]}, %{is_nullable?: false}}
          ]}, %{is_nullable?: false}}
    ]

  defp response_schema(7),
    do: [
      throttle_time_ms: {:int32, %{is_nullable?: false}},
      error_code: {:int16, %{is_nullable?: false}},
      session_id: {:int32, %{is_nullable?: false}},
      responses:
        {{:array,
          [
            topic: {:string, %{is_nullable?: false}},
            partitions:
              {{:array,
                [
                  partition_index: {:int32, %{is_nullable?: false}},
                  error_code: {:int16, %{is_nullable?: false}},
                  high_watermark: {:int64, %{is_nullable?: false}},
                  last_stable_offset: {:int64, %{is_nullable?: false}},
                  log_start_offset: {:int64, %{is_nullable?: false}},
                  aborted_transactions:
                    {{:array,
                      [
                        producer_id: {:int64, %{is_nullable?: false}},
                        first_offset: {:int64, %{is_nullable?: false}}
                      ]}, %{is_nullable?: true}},
                  records: {:records, %{is_nullable?: true}}
                ]}, %{is_nullable?: false}}
          ]}, %{is_nullable?: false}}
    ]

  defp response_schema(8),
    do: [
      throttle_time_ms: {:int32, %{is_nullable?: false}},
      error_code: {:int16, %{is_nullable?: false}},
      session_id: {:int32, %{is_nullable?: false}},
      responses:
        {{:array,
          [
            topic: {:string, %{is_nullable?: false}},
            partitions:
              {{:array,
                [
                  partition_index: {:int32, %{is_nullable?: false}},
                  error_code: {:int16, %{is_nullable?: false}},
                  high_watermark: {:int64, %{is_nullable?: false}},
                  last_stable_offset: {:int64, %{is_nullable?: false}},
                  log_start_offset: {:int64, %{is_nullable?: false}},
                  aborted_transactions:
                    {{:array,
                      [
                        producer_id: {:int64, %{is_nullable?: false}},
                        first_offset: {:int64, %{is_nullable?: false}}
                      ]}, %{is_nullable?: true}},
                  records: {:records, %{is_nullable?: true}}
                ]}, %{is_nullable?: false}}
          ]}, %{is_nullable?: false}}
    ]

  defp response_schema(9),
    do: [
      throttle_time_ms: {:int32, %{is_nullable?: false}},
      error_code: {:int16, %{is_nullable?: false}},
      session_id: {:int32, %{is_nullable?: false}},
      responses:
        {{:array,
          [
            topic: {:string, %{is_nullable?: false}},
            partitions:
              {{:array,
                [
                  partition_index: {:int32, %{is_nullable?: false}},
                  error_code: {:int16, %{is_nullable?: false}},
                  high_watermark: {:int64, %{is_nullable?: false}},
                  last_stable_offset: {:int64, %{is_nullable?: false}},
                  log_start_offset: {:int64, %{is_nullable?: false}},
                  aborted_transactions:
                    {{:array,
                      [
                        producer_id: {:int64, %{is_nullable?: false}},
                        first_offset: {:int64, %{is_nullable?: false}}
                      ]}, %{is_nullable?: true}},
                  records: {:records, %{is_nullable?: true}}
                ]}, %{is_nullable?: false}}
          ]}, %{is_nullable?: false}}
    ]

  defp response_schema(10),
    do: [
      throttle_time_ms: {:int32, %{is_nullable?: false}},
      error_code: {:int16, %{is_nullable?: false}},
      session_id: {:int32, %{is_nullable?: false}},
      responses:
        {{:array,
          [
            topic: {:string, %{is_nullable?: false}},
            partitions:
              {{:array,
                [
                  partition_index: {:int32, %{is_nullable?: false}},
                  error_code: {:int16, %{is_nullable?: false}},
                  high_watermark: {:int64, %{is_nullable?: false}},
                  last_stable_offset: {:int64, %{is_nullable?: false}},
                  log_start_offset: {:int64, %{is_nullable?: false}},
                  aborted_transactions:
                    {{:array,
                      [
                        producer_id: {:int64, %{is_nullable?: false}},
                        first_offset: {:int64, %{is_nullable?: false}}
                      ]}, %{is_nullable?: true}},
                  records: {:records, %{is_nullable?: true}}
                ]}, %{is_nullable?: false}}
          ]}, %{is_nullable?: false}}
    ]

  defp response_schema(11),
    do: [
      throttle_time_ms: {:int32, %{is_nullable?: false}},
      error_code: {:int16, %{is_nullable?: false}},
      session_id: {:int32, %{is_nullable?: false}},
      responses:
        {{:array,
          [
            topic: {:string, %{is_nullable?: false}},
            partitions:
              {{:array,
                [
                  partition_index: {:int32, %{is_nullable?: false}},
                  error_code: {:int16, %{is_nullable?: false}},
                  high_watermark: {:int64, %{is_nullable?: false}},
                  last_stable_offset: {:int64, %{is_nullable?: false}},
                  log_start_offset: {:int64, %{is_nullable?: false}},
                  aborted_transactions:
                    {{:array,
                      [
                        producer_id: {:int64, %{is_nullable?: false}},
                        first_offset: {:int64, %{is_nullable?: false}}
                      ]}, %{is_nullable?: true}},
                  preferred_read_replica: {:int32, %{is_nullable?: false}},
                  records: {:records, %{is_nullable?: true}}
                ]}, %{is_nullable?: false}}
          ]}, %{is_nullable?: false}}
    ]

  defp response_schema(12),
    do: [
      throttle_time_ms: {:int32, %{is_nullable?: false}},
      error_code: {:int16, %{is_nullable?: false}},
      session_id: {:int32, %{is_nullable?: false}},
      responses:
        {{:compact_array,
          [
            topic: {:compact_string, %{is_nullable?: false}},
            partitions:
              {{:compact_array,
                [
                  partition_index: {:int32, %{is_nullable?: false}},
                  error_code: {:int16, %{is_nullable?: false}},
                  high_watermark: {:int64, %{is_nullable?: false}},
                  last_stable_offset: {:int64, %{is_nullable?: false}},
                  log_start_offset: {:int64, %{is_nullable?: false}},
                  aborted_transactions:
                    {{:compact_array,
                      [
                        producer_id: {:int64, %{is_nullable?: false}},
                        first_offset: {:int64, %{is_nullable?: false}},
                        tag_buffer: {:tag_buffer, %{}}
                      ]}, %{is_nullable?: true}},
                  preferred_read_replica: {:int32, %{is_nullable?: false}},
                  records: {:records, %{is_nullable?: true}},
                  tag_buffer:
                    {:tag_buffer,
                     %{
                       0 =>
                         {{:diverging_epoch,
                           {:object,
                            [
                              epoch: {:int32, %{is_nullable?: false}},
                              end_offset: {:int64, %{is_nullable?: false}},
                              tag_buffer: {:tag_buffer, %{}}
                            ]}}, %{is_nullable?: false}},
                       1 =>
                         {{:current_leader,
                           {:object,
                            [
                              leader_id: {:int32, %{is_nullable?: false}},
                              leader_epoch: {:int32, %{is_nullable?: false}},
                              tag_buffer: {:tag_buffer, %{}}
                            ]}}, %{is_nullable?: false}},
                       2 =>
                         {{:snapshot_id,
                           {:object,
                            [
                              end_offset: {:int64, %{is_nullable?: false}},
                              epoch: {:int32, %{is_nullable?: false}},
                              tag_buffer: {:tag_buffer, %{}}
                            ]}}, %{is_nullable?: false}}
                     }}
                ]}, %{is_nullable?: false}},
            tag_buffer: {:tag_buffer, %{}}
          ]}, %{is_nullable?: false}},
      tag_buffer: {:tag_buffer, %{}}
    ]

  defp response_schema(13),
    do: [
      throttle_time_ms: {:int32, %{is_nullable?: false}},
      error_code: {:int16, %{is_nullable?: false}},
      session_id: {:int32, %{is_nullable?: false}},
      responses:
        {{:compact_array,
          [
            topic_id: {:uuid, %{is_nullable?: false}},
            partitions:
              {{:compact_array,
                [
                  partition_index: {:int32, %{is_nullable?: false}},
                  error_code: {:int16, %{is_nullable?: false}},
                  high_watermark: {:int64, %{is_nullable?: false}},
                  last_stable_offset: {:int64, %{is_nullable?: false}},
                  log_start_offset: {:int64, %{is_nullable?: false}},
                  aborted_transactions:
                    {{:compact_array,
                      [
                        producer_id: {:int64, %{is_nullable?: false}},
                        first_offset: {:int64, %{is_nullable?: false}},
                        tag_buffer: {:tag_buffer, %{}}
                      ]}, %{is_nullable?: true}},
                  preferred_read_replica: {:int32, %{is_nullable?: false}},
                  records: {:records, %{is_nullable?: true}},
                  tag_buffer:
                    {:tag_buffer,
                     %{
                       0 =>
                         {{:diverging_epoch,
                           {:object,
                            [
                              epoch: {:int32, %{is_nullable?: false}},
                              end_offset: {:int64, %{is_nullable?: false}},
                              tag_buffer: {:tag_buffer, %{}}
                            ]}}, %{is_nullable?: false}},
                       1 =>
                         {{:current_leader,
                           {:object,
                            [
                              leader_id: {:int32, %{is_nullable?: false}},
                              leader_epoch: {:int32, %{is_nullable?: false}},
                              tag_buffer: {:tag_buffer, %{}}
                            ]}}, %{is_nullable?: false}},
                       2 =>
                         {{:snapshot_id,
                           {:object,
                            [
                              end_offset: {:int64, %{is_nullable?: false}},
                              epoch: {:int32, %{is_nullable?: false}},
                              tag_buffer: {:tag_buffer, %{}}
                            ]}}, %{is_nullable?: false}}
                     }}
                ]}, %{is_nullable?: false}},
            tag_buffer: {:tag_buffer, %{}}
          ]}, %{is_nullable?: false}},
      tag_buffer: {:tag_buffer, %{}}
    ]
end