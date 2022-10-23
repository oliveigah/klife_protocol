defmodule KlifeProtocol.Messages.CreateTopics do
  alias KlifeProtocol.Deserializer
  alias KlifeProtocol.Serializer
  alias KlifeProtocol.Header

  @api_key 19
  @min_flexible_version_req 5
  @min_flexible_version_res 5

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
            name: {:string, %{is_nullable?: false}},
            num_partitions: {:int32, %{is_nullable?: false}},
            replication_factor: {:int16, %{is_nullable?: false}},
            assignments:
              {{:array,
                [
                  partition_index: {:int32, %{is_nullable?: false}},
                  broker_ids: {{:array, :int32}, %{is_nullable?: false}}
                ]}, %{is_nullable?: false}},
            configs:
              {{:array,
                [name: {:string, %{is_nullable?: false}}, value: {:string, %{is_nullable?: true}}]},
               %{is_nullable?: false}}
          ]}, %{is_nullable?: false}},
      timeout_ms: {:int32, %{is_nullable?: false}}
    ]

  defp request_schema(1),
    do: [
      topics:
        {{:array,
          [
            name: {:string, %{is_nullable?: false}},
            num_partitions: {:int32, %{is_nullable?: false}},
            replication_factor: {:int16, %{is_nullable?: false}},
            assignments:
              {{:array,
                [
                  partition_index: {:int32, %{is_nullable?: false}},
                  broker_ids: {{:array, :int32}, %{is_nullable?: false}}
                ]}, %{is_nullable?: false}},
            configs:
              {{:array,
                [name: {:string, %{is_nullable?: false}}, value: {:string, %{is_nullable?: true}}]},
               %{is_nullable?: false}}
          ]}, %{is_nullable?: false}},
      timeout_ms: {:int32, %{is_nullable?: false}},
      validate_only: {:boolean, %{is_nullable?: false}}
    ]

  defp request_schema(2),
    do: [
      topics:
        {{:array,
          [
            name: {:string, %{is_nullable?: false}},
            num_partitions: {:int32, %{is_nullable?: false}},
            replication_factor: {:int16, %{is_nullable?: false}},
            assignments:
              {{:array,
                [
                  partition_index: {:int32, %{is_nullable?: false}},
                  broker_ids: {{:array, :int32}, %{is_nullable?: false}}
                ]}, %{is_nullable?: false}},
            configs:
              {{:array,
                [name: {:string, %{is_nullable?: false}}, value: {:string, %{is_nullable?: true}}]},
               %{is_nullable?: false}}
          ]}, %{is_nullable?: false}},
      timeout_ms: {:int32, %{is_nullable?: false}},
      validate_only: {:boolean, %{is_nullable?: false}}
    ]

  defp request_schema(3),
    do: [
      topics:
        {{:array,
          [
            name: {:string, %{is_nullable?: false}},
            num_partitions: {:int32, %{is_nullable?: false}},
            replication_factor: {:int16, %{is_nullable?: false}},
            assignments:
              {{:array,
                [
                  partition_index: {:int32, %{is_nullable?: false}},
                  broker_ids: {{:array, :int32}, %{is_nullable?: false}}
                ]}, %{is_nullable?: false}},
            configs:
              {{:array,
                [name: {:string, %{is_nullable?: false}}, value: {:string, %{is_nullable?: true}}]},
               %{is_nullable?: false}}
          ]}, %{is_nullable?: false}},
      timeout_ms: {:int32, %{is_nullable?: false}},
      validate_only: {:boolean, %{is_nullable?: false}}
    ]

  defp request_schema(4),
    do: [
      topics:
        {{:array,
          [
            name: {:string, %{is_nullable?: false}},
            num_partitions: {:int32, %{is_nullable?: false}},
            replication_factor: {:int16, %{is_nullable?: false}},
            assignments:
              {{:array,
                [
                  partition_index: {:int32, %{is_nullable?: false}},
                  broker_ids: {{:array, :int32}, %{is_nullable?: false}}
                ]}, %{is_nullable?: false}},
            configs:
              {{:array,
                [name: {:string, %{is_nullable?: false}}, value: {:string, %{is_nullable?: true}}]},
               %{is_nullable?: false}}
          ]}, %{is_nullable?: false}},
      timeout_ms: {:int32, %{is_nullable?: false}},
      validate_only: {:boolean, %{is_nullable?: false}}
    ]

  defp request_schema(5),
    do: [
      topics:
        {{:compact_array,
          [
            name: {:compact_string, %{is_nullable?: false}},
            num_partitions: {:int32, %{is_nullable?: false}},
            replication_factor: {:int16, %{is_nullable?: false}},
            assignments:
              {{:compact_array,
                [
                  partition_index: {:int32, %{is_nullable?: false}},
                  broker_ids: {{:compact_array, :int32}, %{is_nullable?: false}},
                  tag_buffer: {:tag_buffer, []}
                ]}, %{is_nullable?: false}},
            configs:
              {{:compact_array,
                [
                  name: {:compact_string, %{is_nullable?: false}},
                  value: {:compact_string, %{is_nullable?: true}},
                  tag_buffer: {:tag_buffer, []}
                ]}, %{is_nullable?: false}},
            tag_buffer: {:tag_buffer, []}
          ]}, %{is_nullable?: false}},
      timeout_ms: {:int32, %{is_nullable?: false}},
      validate_only: {:boolean, %{is_nullable?: false}},
      tag_buffer: {:tag_buffer, []}
    ]

  defp request_schema(6),
    do: [
      topics:
        {{:compact_array,
          [
            name: {:compact_string, %{is_nullable?: false}},
            num_partitions: {:int32, %{is_nullable?: false}},
            replication_factor: {:int16, %{is_nullable?: false}},
            assignments:
              {{:compact_array,
                [
                  partition_index: {:int32, %{is_nullable?: false}},
                  broker_ids: {{:compact_array, :int32}, %{is_nullable?: false}},
                  tag_buffer: {:tag_buffer, []}
                ]}, %{is_nullable?: false}},
            configs:
              {{:compact_array,
                [
                  name: {:compact_string, %{is_nullable?: false}},
                  value: {:compact_string, %{is_nullable?: true}},
                  tag_buffer: {:tag_buffer, []}
                ]}, %{is_nullable?: false}},
            tag_buffer: {:tag_buffer, []}
          ]}, %{is_nullable?: false}},
      timeout_ms: {:int32, %{is_nullable?: false}},
      validate_only: {:boolean, %{is_nullable?: false}},
      tag_buffer: {:tag_buffer, []}
    ]

  defp request_schema(7),
    do: [
      topics:
        {{:compact_array,
          [
            name: {:compact_string, %{is_nullable?: false}},
            num_partitions: {:int32, %{is_nullable?: false}},
            replication_factor: {:int16, %{is_nullable?: false}},
            assignments:
              {{:compact_array,
                [
                  partition_index: {:int32, %{is_nullable?: false}},
                  broker_ids: {{:compact_array, :int32}, %{is_nullable?: false}},
                  tag_buffer: {:tag_buffer, []}
                ]}, %{is_nullable?: false}},
            configs:
              {{:compact_array,
                [
                  name: {:compact_string, %{is_nullable?: false}},
                  value: {:compact_string, %{is_nullable?: true}},
                  tag_buffer: {:tag_buffer, []}
                ]}, %{is_nullable?: false}},
            tag_buffer: {:tag_buffer, []}
          ]}, %{is_nullable?: false}},
      timeout_ms: {:int32, %{is_nullable?: false}},
      validate_only: {:boolean, %{is_nullable?: false}},
      tag_buffer: {:tag_buffer, []}
    ]

  defp response_schema(0),
    do: [
      topics:
        {{:array,
          [name: {:string, %{is_nullable?: false}}, error_code: {:int16, %{is_nullable?: false}}]},
         %{is_nullable?: false}}
    ]

  defp response_schema(1),
    do: [
      topics:
        {{:array,
          [
            name: {:string, %{is_nullable?: false}},
            error_code: {:int16, %{is_nullable?: false}},
            error_message: {:string, %{is_nullable?: true}}
          ]}, %{is_nullable?: false}}
    ]

  defp response_schema(2),
    do: [
      throttle_time_ms: {:int32, %{is_nullable?: false}},
      topics:
        {{:array,
          [
            name: {:string, %{is_nullable?: false}},
            error_code: {:int16, %{is_nullable?: false}},
            error_message: {:string, %{is_nullable?: true}}
          ]}, %{is_nullable?: false}}
    ]

  defp response_schema(3),
    do: [
      throttle_time_ms: {:int32, %{is_nullable?: false}},
      topics:
        {{:array,
          [
            name: {:string, %{is_nullable?: false}},
            error_code: {:int16, %{is_nullable?: false}},
            error_message: {:string, %{is_nullable?: true}}
          ]}, %{is_nullable?: false}}
    ]

  defp response_schema(4),
    do: [
      throttle_time_ms: {:int32, %{is_nullable?: false}},
      topics:
        {{:array,
          [
            name: {:string, %{is_nullable?: false}},
            error_code: {:int16, %{is_nullable?: false}},
            error_message: {:string, %{is_nullable?: true}}
          ]}, %{is_nullable?: false}}
    ]

  defp response_schema(5),
    do: [
      throttle_time_ms: {:int32, %{is_nullable?: false}},
      topics:
        {{:compact_array,
          [
            name: {:compact_string, %{is_nullable?: false}},
            error_code: {:int16, %{is_nullable?: false}},
            error_message: {:compact_string, %{is_nullable?: true}},
            num_partitions: {:int32, %{is_nullable?: false}},
            replication_factor: {:int16, %{is_nullable?: false}},
            configs:
              {{:compact_array,
                [
                  name: {:compact_string, %{is_nullable?: false}},
                  value: {:compact_string, %{is_nullable?: true}},
                  read_only: {:boolean, %{is_nullable?: false}},
                  config_source: {:int8, %{is_nullable?: false}},
                  is_sensitive: {:boolean, %{is_nullable?: false}},
                  tag_buffer: {:tag_buffer, %{}}
                ]}, %{is_nullable?: true}},
            tag_buffer:
              {:tag_buffer, %{0 => {{:topic_config_error_code, :int16}, %{is_nullable?: false}}}}
          ]}, %{is_nullable?: false}},
      tag_buffer: {:tag_buffer, %{}}
    ]

  defp response_schema(6),
    do: [
      throttle_time_ms: {:int32, %{is_nullable?: false}},
      topics:
        {{:compact_array,
          [
            name: {:compact_string, %{is_nullable?: false}},
            error_code: {:int16, %{is_nullable?: false}},
            error_message: {:compact_string, %{is_nullable?: true}},
            num_partitions: {:int32, %{is_nullable?: false}},
            replication_factor: {:int16, %{is_nullable?: false}},
            configs:
              {{:compact_array,
                [
                  name: {:compact_string, %{is_nullable?: false}},
                  value: {:compact_string, %{is_nullable?: true}},
                  read_only: {:boolean, %{is_nullable?: false}},
                  config_source: {:int8, %{is_nullable?: false}},
                  is_sensitive: {:boolean, %{is_nullable?: false}},
                  tag_buffer: {:tag_buffer, %{}}
                ]}, %{is_nullable?: true}},
            tag_buffer:
              {:tag_buffer, %{0 => {{:topic_config_error_code, :int16}, %{is_nullable?: false}}}}
          ]}, %{is_nullable?: false}},
      tag_buffer: {:tag_buffer, %{}}
    ]

  defp response_schema(7),
    do: [
      throttle_time_ms: {:int32, %{is_nullable?: false}},
      topics:
        {{:compact_array,
          [
            name: {:compact_string, %{is_nullable?: false}},
            topic_id: {:uuid, %{is_nullable?: false}},
            error_code: {:int16, %{is_nullable?: false}},
            error_message: {:compact_string, %{is_nullable?: true}},
            num_partitions: {:int32, %{is_nullable?: false}},
            replication_factor: {:int16, %{is_nullable?: false}},
            configs:
              {{:compact_array,
                [
                  name: {:compact_string, %{is_nullable?: false}},
                  value: {:compact_string, %{is_nullable?: true}},
                  read_only: {:boolean, %{is_nullable?: false}},
                  config_source: {:int8, %{is_nullable?: false}},
                  is_sensitive: {:boolean, %{is_nullable?: false}},
                  tag_buffer: {:tag_buffer, %{}}
                ]}, %{is_nullable?: true}},
            tag_buffer:
              {:tag_buffer, %{0 => {{:topic_config_error_code, :int16}, %{is_nullable?: false}}}}
          ]}, %{is_nullable?: false}},
      tag_buffer: {:tag_buffer, %{}}
    ]
end