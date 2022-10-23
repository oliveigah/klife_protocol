defmodule KlifeProtocol.Messages.Metadata do
  alias KlifeProtocol.Deserializer
  alias KlifeProtocol.Serializer
  alias KlifeProtocol.Header

  @api_key 3
  @min_flexible_version_req 9
  @min_flexible_version_res 9

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
    do: [topics: {{:array, [name: {:string, %{is_nullable?: false}}]}, %{is_nullable?: false}}]

  defp request_schema(1),
    do: [topics: {{:array, [name: {:string, %{is_nullable?: false}}]}, %{is_nullable?: true}}]

  defp request_schema(2),
    do: [topics: {{:array, [name: {:string, %{is_nullable?: false}}]}, %{is_nullable?: true}}]

  defp request_schema(3),
    do: [topics: {{:array, [name: {:string, %{is_nullable?: false}}]}, %{is_nullable?: true}}]

  defp request_schema(4),
    do: [
      topics: {{:array, [name: {:string, %{is_nullable?: false}}]}, %{is_nullable?: true}},
      allow_auto_topic_creation: {:boolean, %{is_nullable?: false}}
    ]

  defp request_schema(5),
    do: [
      topics: {{:array, [name: {:string, %{is_nullable?: false}}]}, %{is_nullable?: true}},
      allow_auto_topic_creation: {:boolean, %{is_nullable?: false}}
    ]

  defp request_schema(6),
    do: [
      topics: {{:array, [name: {:string, %{is_nullable?: false}}]}, %{is_nullable?: true}},
      allow_auto_topic_creation: {:boolean, %{is_nullable?: false}}
    ]

  defp request_schema(7),
    do: [
      topics: {{:array, [name: {:string, %{is_nullable?: false}}]}, %{is_nullable?: true}},
      allow_auto_topic_creation: {:boolean, %{is_nullable?: false}}
    ]

  defp request_schema(8),
    do: [
      topics: {{:array, [name: {:string, %{is_nullable?: false}}]}, %{is_nullable?: true}},
      allow_auto_topic_creation: {:boolean, %{is_nullable?: false}},
      include_cluster_authorized_operations: {:boolean, %{is_nullable?: false}},
      include_topic_authorized_operations: {:boolean, %{is_nullable?: false}}
    ]

  defp request_schema(9),
    do: [
      topics:
        {{:compact_array,
          [name: {:compact_string, %{is_nullable?: false}}, tag_buffer: {:tag_buffer, []}]},
         %{is_nullable?: true}},
      allow_auto_topic_creation: {:boolean, %{is_nullable?: false}},
      include_cluster_authorized_operations: {:boolean, %{is_nullable?: false}},
      include_topic_authorized_operations: {:boolean, %{is_nullable?: false}},
      tag_buffer: {:tag_buffer, []}
    ]

  defp request_schema(10),
    do: [
      topics:
        {{:compact_array,
          [
            topic_id: {:uuid, %{is_nullable?: false}},
            name: {:compact_string, %{is_nullable?: true}},
            tag_buffer: {:tag_buffer, []}
          ]}, %{is_nullable?: true}},
      allow_auto_topic_creation: {:boolean, %{is_nullable?: false}},
      include_cluster_authorized_operations: {:boolean, %{is_nullable?: false}},
      include_topic_authorized_operations: {:boolean, %{is_nullable?: false}},
      tag_buffer: {:tag_buffer, []}
    ]

  defp request_schema(11),
    do: [
      topics:
        {{:compact_array,
          [
            topic_id: {:uuid, %{is_nullable?: false}},
            name: {:compact_string, %{is_nullable?: true}},
            tag_buffer: {:tag_buffer, []}
          ]}, %{is_nullable?: true}},
      allow_auto_topic_creation: {:boolean, %{is_nullable?: false}},
      include_topic_authorized_operations: {:boolean, %{is_nullable?: false}},
      tag_buffer: {:tag_buffer, []}
    ]

  defp request_schema(12),
    do: [
      topics:
        {{:compact_array,
          [
            topic_id: {:uuid, %{is_nullable?: false}},
            name: {:compact_string, %{is_nullable?: true}},
            tag_buffer: {:tag_buffer, []}
          ]}, %{is_nullable?: true}},
      allow_auto_topic_creation: {:boolean, %{is_nullable?: false}},
      include_topic_authorized_operations: {:boolean, %{is_nullable?: false}},
      tag_buffer: {:tag_buffer, []}
    ]

  defp response_schema(0),
    do: [
      brokers:
        {{:array,
          [
            node_id: {:int32, %{is_nullable?: false}},
            host: {:string, %{is_nullable?: false}},
            port: {:int32, %{is_nullable?: false}}
          ]}, %{is_nullable?: false}},
      topics:
        {{:array,
          [
            error_code: {:int16, %{is_nullable?: false}},
            name: {:string, %{is_nullable?: false}},
            partitions:
              {{:array,
                [
                  error_code: {:int16, %{is_nullable?: false}},
                  partition_index: {:int32, %{is_nullable?: false}},
                  leader_id: {:int32, %{is_nullable?: false}},
                  replica_nodes: {{:array, :int32}, %{is_nullable?: false}},
                  isr_nodes: {{:array, :int32}, %{is_nullable?: false}}
                ]}, %{is_nullable?: false}}
          ]}, %{is_nullable?: false}}
    ]

  defp response_schema(1),
    do: [
      brokers:
        {{:array,
          [
            node_id: {:int32, %{is_nullable?: false}},
            host: {:string, %{is_nullable?: false}},
            port: {:int32, %{is_nullable?: false}},
            rack: {:string, %{is_nullable?: true}}
          ]}, %{is_nullable?: false}},
      controller_id: {:int32, %{is_nullable?: false}},
      topics:
        {{:array,
          [
            error_code: {:int16, %{is_nullable?: false}},
            name: {:string, %{is_nullable?: false}},
            is_internal: {:boolean, %{is_nullable?: false}},
            partitions:
              {{:array,
                [
                  error_code: {:int16, %{is_nullable?: false}},
                  partition_index: {:int32, %{is_nullable?: false}},
                  leader_id: {:int32, %{is_nullable?: false}},
                  replica_nodes: {{:array, :int32}, %{is_nullable?: false}},
                  isr_nodes: {{:array, :int32}, %{is_nullable?: false}}
                ]}, %{is_nullable?: false}}
          ]}, %{is_nullable?: false}}
    ]

  defp response_schema(2),
    do: [
      brokers:
        {{:array,
          [
            node_id: {:int32, %{is_nullable?: false}},
            host: {:string, %{is_nullable?: false}},
            port: {:int32, %{is_nullable?: false}},
            rack: {:string, %{is_nullable?: true}}
          ]}, %{is_nullable?: false}},
      cluster_id: {:string, %{is_nullable?: true}},
      controller_id: {:int32, %{is_nullable?: false}},
      topics:
        {{:array,
          [
            error_code: {:int16, %{is_nullable?: false}},
            name: {:string, %{is_nullable?: false}},
            is_internal: {:boolean, %{is_nullable?: false}},
            partitions:
              {{:array,
                [
                  error_code: {:int16, %{is_nullable?: false}},
                  partition_index: {:int32, %{is_nullable?: false}},
                  leader_id: {:int32, %{is_nullable?: false}},
                  replica_nodes: {{:array, :int32}, %{is_nullable?: false}},
                  isr_nodes: {{:array, :int32}, %{is_nullable?: false}}
                ]}, %{is_nullable?: false}}
          ]}, %{is_nullable?: false}}
    ]

  defp response_schema(3),
    do: [
      throttle_time_ms: {:int32, %{is_nullable?: false}},
      brokers:
        {{:array,
          [
            node_id: {:int32, %{is_nullable?: false}},
            host: {:string, %{is_nullable?: false}},
            port: {:int32, %{is_nullable?: false}},
            rack: {:string, %{is_nullable?: true}}
          ]}, %{is_nullable?: false}},
      cluster_id: {:string, %{is_nullable?: true}},
      controller_id: {:int32, %{is_nullable?: false}},
      topics:
        {{:array,
          [
            error_code: {:int16, %{is_nullable?: false}},
            name: {:string, %{is_nullable?: false}},
            is_internal: {:boolean, %{is_nullable?: false}},
            partitions:
              {{:array,
                [
                  error_code: {:int16, %{is_nullable?: false}},
                  partition_index: {:int32, %{is_nullable?: false}},
                  leader_id: {:int32, %{is_nullable?: false}},
                  replica_nodes: {{:array, :int32}, %{is_nullable?: false}},
                  isr_nodes: {{:array, :int32}, %{is_nullable?: false}}
                ]}, %{is_nullable?: false}}
          ]}, %{is_nullable?: false}}
    ]

  defp response_schema(4),
    do: [
      throttle_time_ms: {:int32, %{is_nullable?: false}},
      brokers:
        {{:array,
          [
            node_id: {:int32, %{is_nullable?: false}},
            host: {:string, %{is_nullable?: false}},
            port: {:int32, %{is_nullable?: false}},
            rack: {:string, %{is_nullable?: true}}
          ]}, %{is_nullable?: false}},
      cluster_id: {:string, %{is_nullable?: true}},
      controller_id: {:int32, %{is_nullable?: false}},
      topics:
        {{:array,
          [
            error_code: {:int16, %{is_nullable?: false}},
            name: {:string, %{is_nullable?: false}},
            is_internal: {:boolean, %{is_nullable?: false}},
            partitions:
              {{:array,
                [
                  error_code: {:int16, %{is_nullable?: false}},
                  partition_index: {:int32, %{is_nullable?: false}},
                  leader_id: {:int32, %{is_nullable?: false}},
                  replica_nodes: {{:array, :int32}, %{is_nullable?: false}},
                  isr_nodes: {{:array, :int32}, %{is_nullable?: false}}
                ]}, %{is_nullable?: false}}
          ]}, %{is_nullable?: false}}
    ]

  defp response_schema(5),
    do: [
      throttle_time_ms: {:int32, %{is_nullable?: false}},
      brokers:
        {{:array,
          [
            node_id: {:int32, %{is_nullable?: false}},
            host: {:string, %{is_nullable?: false}},
            port: {:int32, %{is_nullable?: false}},
            rack: {:string, %{is_nullable?: true}}
          ]}, %{is_nullable?: false}},
      cluster_id: {:string, %{is_nullable?: true}},
      controller_id: {:int32, %{is_nullable?: false}},
      topics:
        {{:array,
          [
            error_code: {:int16, %{is_nullable?: false}},
            name: {:string, %{is_nullable?: false}},
            is_internal: {:boolean, %{is_nullable?: false}},
            partitions:
              {{:array,
                [
                  error_code: {:int16, %{is_nullable?: false}},
                  partition_index: {:int32, %{is_nullable?: false}},
                  leader_id: {:int32, %{is_nullable?: false}},
                  replica_nodes: {{:array, :int32}, %{is_nullable?: false}},
                  isr_nodes: {{:array, :int32}, %{is_nullable?: false}},
                  offline_replicas: {{:array, :int32}, %{is_nullable?: false}}
                ]}, %{is_nullable?: false}}
          ]}, %{is_nullable?: false}}
    ]

  defp response_schema(6),
    do: [
      throttle_time_ms: {:int32, %{is_nullable?: false}},
      brokers:
        {{:array,
          [
            node_id: {:int32, %{is_nullable?: false}},
            host: {:string, %{is_nullable?: false}},
            port: {:int32, %{is_nullable?: false}},
            rack: {:string, %{is_nullable?: true}}
          ]}, %{is_nullable?: false}},
      cluster_id: {:string, %{is_nullable?: true}},
      controller_id: {:int32, %{is_nullable?: false}},
      topics:
        {{:array,
          [
            error_code: {:int16, %{is_nullable?: false}},
            name: {:string, %{is_nullable?: false}},
            is_internal: {:boolean, %{is_nullable?: false}},
            partitions:
              {{:array,
                [
                  error_code: {:int16, %{is_nullable?: false}},
                  partition_index: {:int32, %{is_nullable?: false}},
                  leader_id: {:int32, %{is_nullable?: false}},
                  replica_nodes: {{:array, :int32}, %{is_nullable?: false}},
                  isr_nodes: {{:array, :int32}, %{is_nullable?: false}},
                  offline_replicas: {{:array, :int32}, %{is_nullable?: false}}
                ]}, %{is_nullable?: false}}
          ]}, %{is_nullable?: false}}
    ]

  defp response_schema(7),
    do: [
      throttle_time_ms: {:int32, %{is_nullable?: false}},
      brokers:
        {{:array,
          [
            node_id: {:int32, %{is_nullable?: false}},
            host: {:string, %{is_nullable?: false}},
            port: {:int32, %{is_nullable?: false}},
            rack: {:string, %{is_nullable?: true}}
          ]}, %{is_nullable?: false}},
      cluster_id: {:string, %{is_nullable?: true}},
      controller_id: {:int32, %{is_nullable?: false}},
      topics:
        {{:array,
          [
            error_code: {:int16, %{is_nullable?: false}},
            name: {:string, %{is_nullable?: false}},
            is_internal: {:boolean, %{is_nullable?: false}},
            partitions:
              {{:array,
                [
                  error_code: {:int16, %{is_nullable?: false}},
                  partition_index: {:int32, %{is_nullable?: false}},
                  leader_id: {:int32, %{is_nullable?: false}},
                  leader_epoch: {:int32, %{is_nullable?: false}},
                  replica_nodes: {{:array, :int32}, %{is_nullable?: false}},
                  isr_nodes: {{:array, :int32}, %{is_nullable?: false}},
                  offline_replicas: {{:array, :int32}, %{is_nullable?: false}}
                ]}, %{is_nullable?: false}}
          ]}, %{is_nullable?: false}}
    ]

  defp response_schema(8),
    do: [
      throttle_time_ms: {:int32, %{is_nullable?: false}},
      brokers:
        {{:array,
          [
            node_id: {:int32, %{is_nullable?: false}},
            host: {:string, %{is_nullable?: false}},
            port: {:int32, %{is_nullable?: false}},
            rack: {:string, %{is_nullable?: true}}
          ]}, %{is_nullable?: false}},
      cluster_id: {:string, %{is_nullable?: true}},
      controller_id: {:int32, %{is_nullable?: false}},
      topics:
        {{:array,
          [
            error_code: {:int16, %{is_nullable?: false}},
            name: {:string, %{is_nullable?: false}},
            is_internal: {:boolean, %{is_nullable?: false}},
            partitions:
              {{:array,
                [
                  error_code: {:int16, %{is_nullable?: false}},
                  partition_index: {:int32, %{is_nullable?: false}},
                  leader_id: {:int32, %{is_nullable?: false}},
                  leader_epoch: {:int32, %{is_nullable?: false}},
                  replica_nodes: {{:array, :int32}, %{is_nullable?: false}},
                  isr_nodes: {{:array, :int32}, %{is_nullable?: false}},
                  offline_replicas: {{:array, :int32}, %{is_nullable?: false}}
                ]}, %{is_nullable?: false}},
            topic_authorized_operations: {:int32, %{is_nullable?: false}}
          ]}, %{is_nullable?: false}},
      cluster_authorized_operations: {:int32, %{is_nullable?: false}}
    ]

  defp response_schema(9),
    do: [
      throttle_time_ms: {:int32, %{is_nullable?: false}},
      brokers:
        {{:compact_array,
          [
            node_id: {:int32, %{is_nullable?: false}},
            host: {:compact_string, %{is_nullable?: false}},
            port: {:int32, %{is_nullable?: false}},
            rack: {:compact_string, %{is_nullable?: true}},
            tag_buffer: {:tag_buffer, %{}}
          ]}, %{is_nullable?: false}},
      cluster_id: {:compact_string, %{is_nullable?: true}},
      controller_id: {:int32, %{is_nullable?: false}},
      topics:
        {{:compact_array,
          [
            error_code: {:int16, %{is_nullable?: false}},
            name: {:compact_string, %{is_nullable?: false}},
            is_internal: {:boolean, %{is_nullable?: false}},
            partitions:
              {{:compact_array,
                [
                  error_code: {:int16, %{is_nullable?: false}},
                  partition_index: {:int32, %{is_nullable?: false}},
                  leader_id: {:int32, %{is_nullable?: false}},
                  leader_epoch: {:int32, %{is_nullable?: false}},
                  replica_nodes: {{:compact_array, :int32}, %{is_nullable?: false}},
                  isr_nodes: {{:compact_array, :int32}, %{is_nullable?: false}},
                  offline_replicas: {{:compact_array, :int32}, %{is_nullable?: false}},
                  tag_buffer: {:tag_buffer, %{}}
                ]}, %{is_nullable?: false}},
            topic_authorized_operations: {:int32, %{is_nullable?: false}},
            tag_buffer: {:tag_buffer, %{}}
          ]}, %{is_nullable?: false}},
      cluster_authorized_operations: {:int32, %{is_nullable?: false}},
      tag_buffer: {:tag_buffer, %{}}
    ]

  defp response_schema(10),
    do: [
      throttle_time_ms: {:int32, %{is_nullable?: false}},
      brokers:
        {{:compact_array,
          [
            node_id: {:int32, %{is_nullable?: false}},
            host: {:compact_string, %{is_nullable?: false}},
            port: {:int32, %{is_nullable?: false}},
            rack: {:compact_string, %{is_nullable?: true}},
            tag_buffer: {:tag_buffer, %{}}
          ]}, %{is_nullable?: false}},
      cluster_id: {:compact_string, %{is_nullable?: true}},
      controller_id: {:int32, %{is_nullable?: false}},
      topics:
        {{:compact_array,
          [
            error_code: {:int16, %{is_nullable?: false}},
            name: {:compact_string, %{is_nullable?: false}},
            topic_id: {:uuid, %{is_nullable?: false}},
            is_internal: {:boolean, %{is_nullable?: false}},
            partitions:
              {{:compact_array,
                [
                  error_code: {:int16, %{is_nullable?: false}},
                  partition_index: {:int32, %{is_nullable?: false}},
                  leader_id: {:int32, %{is_nullable?: false}},
                  leader_epoch: {:int32, %{is_nullable?: false}},
                  replica_nodes: {{:compact_array, :int32}, %{is_nullable?: false}},
                  isr_nodes: {{:compact_array, :int32}, %{is_nullable?: false}},
                  offline_replicas: {{:compact_array, :int32}, %{is_nullable?: false}},
                  tag_buffer: {:tag_buffer, %{}}
                ]}, %{is_nullable?: false}},
            topic_authorized_operations: {:int32, %{is_nullable?: false}},
            tag_buffer: {:tag_buffer, %{}}
          ]}, %{is_nullable?: false}},
      cluster_authorized_operations: {:int32, %{is_nullable?: false}},
      tag_buffer: {:tag_buffer, %{}}
    ]

  defp response_schema(11),
    do: [
      throttle_time_ms: {:int32, %{is_nullable?: false}},
      brokers:
        {{:compact_array,
          [
            node_id: {:int32, %{is_nullable?: false}},
            host: {:compact_string, %{is_nullable?: false}},
            port: {:int32, %{is_nullable?: false}},
            rack: {:compact_string, %{is_nullable?: true}},
            tag_buffer: {:tag_buffer, %{}}
          ]}, %{is_nullable?: false}},
      cluster_id: {:compact_string, %{is_nullable?: true}},
      controller_id: {:int32, %{is_nullable?: false}},
      topics:
        {{:compact_array,
          [
            error_code: {:int16, %{is_nullable?: false}},
            name: {:compact_string, %{is_nullable?: false}},
            topic_id: {:uuid, %{is_nullable?: false}},
            is_internal: {:boolean, %{is_nullable?: false}},
            partitions:
              {{:compact_array,
                [
                  error_code: {:int16, %{is_nullable?: false}},
                  partition_index: {:int32, %{is_nullable?: false}},
                  leader_id: {:int32, %{is_nullable?: false}},
                  leader_epoch: {:int32, %{is_nullable?: false}},
                  replica_nodes: {{:compact_array, :int32}, %{is_nullable?: false}},
                  isr_nodes: {{:compact_array, :int32}, %{is_nullable?: false}},
                  offline_replicas: {{:compact_array, :int32}, %{is_nullable?: false}},
                  tag_buffer: {:tag_buffer, %{}}
                ]}, %{is_nullable?: false}},
            topic_authorized_operations: {:int32, %{is_nullable?: false}},
            tag_buffer: {:tag_buffer, %{}}
          ]}, %{is_nullable?: false}},
      tag_buffer: {:tag_buffer, %{}}
    ]

  defp response_schema(12),
    do: [
      throttle_time_ms: {:int32, %{is_nullable?: false}},
      brokers:
        {{:compact_array,
          [
            node_id: {:int32, %{is_nullable?: false}},
            host: {:compact_string, %{is_nullable?: false}},
            port: {:int32, %{is_nullable?: false}},
            rack: {:compact_string, %{is_nullable?: true}},
            tag_buffer: {:tag_buffer, %{}}
          ]}, %{is_nullable?: false}},
      cluster_id: {:compact_string, %{is_nullable?: true}},
      controller_id: {:int32, %{is_nullable?: false}},
      topics:
        {{:compact_array,
          [
            error_code: {:int16, %{is_nullable?: false}},
            name: {:compact_string, %{is_nullable?: true}},
            topic_id: {:uuid, %{is_nullable?: false}},
            is_internal: {:boolean, %{is_nullable?: false}},
            partitions:
              {{:compact_array,
                [
                  error_code: {:int16, %{is_nullable?: false}},
                  partition_index: {:int32, %{is_nullable?: false}},
                  leader_id: {:int32, %{is_nullable?: false}},
                  leader_epoch: {:int32, %{is_nullable?: false}},
                  replica_nodes: {{:compact_array, :int32}, %{is_nullable?: false}},
                  isr_nodes: {{:compact_array, :int32}, %{is_nullable?: false}},
                  offline_replicas: {{:compact_array, :int32}, %{is_nullable?: false}},
                  tag_buffer: {:tag_buffer, %{}}
                ]}, %{is_nullable?: false}},
            topic_authorized_operations: {:int32, %{is_nullable?: false}},
            tag_buffer: {:tag_buffer, %{}}
          ]}, %{is_nullable?: false}},
      tag_buffer: {:tag_buffer, %{}}
    ]
end
