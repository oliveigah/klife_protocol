defmodule KlifeProtocol.Messages.CreateTopics do
  alias KlifeProtocol.Deserializer
  alias KlifeProtocol.Serializer
  alias KlifeProtocol.Header

  @api_key 19
  @min_flexible_version_req 5
  @min_flexible_version_res 5

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
         [
           name: :string,
           num_partitions: :int32,
           replication_factor: :int16,
           assignments: {:array, [partition_index: :int32, broker_ids: {:array, :int32}]},
           configs: {:array, [name: :string, value: :string]}
         ]},
      timeout_ms: :int32
    ]

  defp request_schema(1),
    do: [
      topics:
        {:array,
         [
           name: :string,
           num_partitions: :int32,
           replication_factor: :int16,
           assignments: {:array, [partition_index: :int32, broker_ids: {:array, :int32}]},
           configs: {:array, [name: :string, value: :string]}
         ]},
      timeout_ms: :int32,
      validate_only: :boolean
    ]

  defp request_schema(2),
    do: [
      topics:
        {:array,
         [
           name: :string,
           num_partitions: :int32,
           replication_factor: :int16,
           assignments: {:array, [partition_index: :int32, broker_ids: {:array, :int32}]},
           configs: {:array, [name: :string, value: :string]}
         ]},
      timeout_ms: :int32,
      validate_only: :boolean
    ]

  defp request_schema(3),
    do: [
      topics:
        {:array,
         [
           name: :string,
           num_partitions: :int32,
           replication_factor: :int16,
           assignments: {:array, [partition_index: :int32, broker_ids: {:array, :int32}]},
           configs: {:array, [name: :string, value: :string]}
         ]},
      timeout_ms: :int32,
      validate_only: :boolean
    ]

  defp request_schema(4),
    do: [
      topics:
        {:array,
         [
           name: :string,
           num_partitions: :int32,
           replication_factor: :int16,
           assignments: {:array, [partition_index: :int32, broker_ids: {:array, :int32}]},
           configs: {:array, [name: :string, value: :string]}
         ]},
      timeout_ms: :int32,
      validate_only: :boolean
    ]

  defp request_schema(5),
    do: [
      topics:
        {:compact_array,
         [
           name: :compact_string,
           num_partitions: :int32,
           replication_factor: :int16,
           assignments:
             {:compact_array,
              [
                partition_index: :int32,
                broker_ids: {:compact_array, :int32},
                tag_buffer: {:tag_buffer, []}
              ]},
           configs:
             {:compact_array,
              [name: :compact_string, value: :compact_string, tag_buffer: {:tag_buffer, []}]},
           tag_buffer: {:tag_buffer, []}
         ]},
      timeout_ms: :int32,
      validate_only: :boolean,
      tag_buffer: {:tag_buffer, []}
    ]

  defp request_schema(6),
    do: [
      topics:
        {:compact_array,
         [
           name: :compact_string,
           num_partitions: :int32,
           replication_factor: :int16,
           assignments:
             {:compact_array,
              [
                partition_index: :int32,
                broker_ids: {:compact_array, :int32},
                tag_buffer: {:tag_buffer, []}
              ]},
           configs:
             {:compact_array,
              [name: :compact_string, value: :compact_string, tag_buffer: {:tag_buffer, []}]},
           tag_buffer: {:tag_buffer, []}
         ]},
      timeout_ms: :int32,
      validate_only: :boolean,
      tag_buffer: {:tag_buffer, []}
    ]

  defp request_schema(7),
    do: [
      topics:
        {:compact_array,
         [
           name: :compact_string,
           num_partitions: :int32,
           replication_factor: :int16,
           assignments:
             {:compact_array,
              [
                partition_index: :int32,
                broker_ids: {:compact_array, :int32},
                tag_buffer: {:tag_buffer, []}
              ]},
           configs:
             {:compact_array,
              [name: :compact_string, value: :compact_string, tag_buffer: {:tag_buffer, []}]},
           tag_buffer: {:tag_buffer, []}
         ]},
      timeout_ms: :int32,
      validate_only: :boolean,
      tag_buffer: {:tag_buffer, []}
    ]

  defp response_schema(0), do: [topics: {:array, [name: :string, error_code: :int16]}]

  defp response_schema(1),
    do: [topics: {:array, [name: :string, error_code: :int16, error_message: :string]}]

  defp response_schema(2),
    do: [
      throttle_time_ms: :int32,
      topics: {:array, [name: :string, error_code: :int16, error_message: :string]}
    ]

  defp response_schema(3),
    do: [
      throttle_time_ms: :int32,
      topics: {:array, [name: :string, error_code: :int16, error_message: :string]}
    ]

  defp response_schema(4),
    do: [
      throttle_time_ms: :int32,
      topics: {:array, [name: :string, error_code: :int16, error_message: :string]}
    ]

  defp response_schema(5),
    do: [
      throttle_time_ms: :int32,
      topics:
        {:compact_array,
         [
           name: :compact_string,
           error_code: :int16,
           error_message: :compact_string,
           num_partitions: :int32,
           replication_factor: :int16,
           configs:
             {:compact_array,
              [
                name: :compact_string,
                value: :compact_string,
                read_only: :boolean,
                config_source: :int8,
                is_sensitive: :boolean,
                tag_buffer: {:tag_buffer, %{}}
              ]},
           tag_buffer: {:tag_buffer, %{0 => {:topic_config_error_code, :int16}}}
         ]},
      tag_buffer: {:tag_buffer, %{}}
    ]

  defp response_schema(6),
    do: [
      throttle_time_ms: :int32,
      topics:
        {:compact_array,
         [
           name: :compact_string,
           error_code: :int16,
           error_message: :compact_string,
           num_partitions: :int32,
           replication_factor: :int16,
           configs:
             {:compact_array,
              [
                name: :compact_string,
                value: :compact_string,
                read_only: :boolean,
                config_source: :int8,
                is_sensitive: :boolean,
                tag_buffer: {:tag_buffer, %{}}
              ]},
           tag_buffer: {:tag_buffer, %{0 => {:topic_config_error_code, :int16}}}
         ]},
      tag_buffer: {:tag_buffer, %{}}
    ]

  defp response_schema(7),
    do: [
      throttle_time_ms: :int32,
      topics:
        {:compact_array,
         [
           name: :compact_string,
           topic_id: :uuid,
           error_code: :int16,
           error_message: :compact_string,
           num_partitions: :int32,
           replication_factor: :int16,
           configs:
             {:compact_array,
              [
                name: :compact_string,
                value: :compact_string,
                read_only: :boolean,
                config_source: :int8,
                is_sensitive: :boolean,
                tag_buffer: {:tag_buffer, %{}}
              ]},
           tag_buffer: {:tag_buffer, %{0 => {:topic_config_error_code, :int16}}}
         ]},
      tag_buffer: {:tag_buffer, %{}}
    ]
end