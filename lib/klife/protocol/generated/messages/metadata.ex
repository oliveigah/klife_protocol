defmodule Klife.Protocol.Messages.Metadata do
  alias Klife.Protocol.Deserializer
  alias Klife.Protocol.Serializer
  alias Klife.Protocol.Header

  @api_key 3
  @min_flexible_version_req 9
  @min_flexible_version_res 9

  def deserialize_response(data, version) do
    with {headers, rest_data} <- Header.deserialize_response(data, res_header_version(version)),
         {content, <<>>} <- Deserializer.execute(rest_data, response_schema(version)) do
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

  defp request_schema(0), do: [topics: {:array, [name: :string]}]
  defp request_schema(1), do: [topics: {:array, [name: :string]}]
  defp request_schema(2), do: [topics: {:array, [name: :string]}]
  defp request_schema(3), do: [topics: {:array, [name: :string]}]

  defp request_schema(4),
    do: [topics: {:array, [name: :string]}, allow_auto_topic_creation: :boolean]

  defp request_schema(5),
    do: [topics: {:array, [name: :string]}, allow_auto_topic_creation: :boolean]

  defp request_schema(6),
    do: [topics: {:array, [name: :string]}, allow_auto_topic_creation: :boolean]

  defp request_schema(7),
    do: [topics: {:array, [name: :string]}, allow_auto_topic_creation: :boolean]

  defp request_schema(8),
    do: [
      topics: {:array, [name: :string]},
      allow_auto_topic_creation: :boolean,
      include_cluster_authorized_operations: :boolean,
      include_topic_authorized_operations: :boolean
    ]

  defp request_schema(9),
    do: [
      topics: {:compact_array, [name: :compact_string, tag_buffer: {:tag_buffer, %{}}]},
      allow_auto_topic_creation: :boolean,
      include_topic_authorized_operations: :boolean,
      tag_buffer: {:tag_buffer, %{}}
    ]

  defp request_schema(10),
    do: [
      topics:
        {:compact_array, [topic_id: :uuid, name: :compact_string, tag_buffer: {:tag_buffer, %{}}]},
      allow_auto_topic_creation: :boolean,
      include_cluster_authorized_operations: :boolean,
      include_topic_authorized_operations: :boolean,
      tag_buffer: {:tag_buffer, %{}}
    ]

  defp request_schema(11),
    do: [
      topics:
        {:compact_array, [topic_id: :uuid, name: :compact_string, tag_buffer: {:tag_buffer, %{}}]},
      allow_auto_topic_creation: :boolean,
      include_topic_authorized_operations: :boolean,
      tag_buffer: {:tag_buffer, %{}}
    ]

  defp request_schema(12),
    do: [
      topics:
        {:compact_array, [topic_id: :uuid, name: :compact_string, tag_buffer: {:tag_buffer, %{}}]},
      allow_auto_topic_creation: :boolean,
      include_topic_authorized_operations: :boolean,
      tag_buffer: {:tag_buffer, %{}}
    ]

  defp response_schema(0),
    do: [
      brokers: {:array, [node_id: :int32, host: :string, port: :int32]},
      topics:
        {:array,
         [
           error_code: :int16,
           name: :string,
           partitions:
             {:array,
              [
                error_code: :int16,
                partition_index: :int32,
                leader_id: :int32,
                replica_nodes: {:array, :int32},
                isr_nodes: {:array, :int32}
              ]}
         ]}
    ]

  defp response_schema(1),
    do: [
      brokers: {:array, [node_id: :int32, host: :string, port: :int32, rack: :string]},
      controller_id: :int32,
      topics:
        {:array,
         [
           error_code: :int16,
           name: :string,
           is_internal: :boolean,
           partitions:
             {:array,
              [
                error_code: :int16,
                partition_index: :int32,
                leader_id: :int32,
                replica_nodes: {:array, :int32},
                isr_nodes: {:array, :int32}
              ]}
         ]}
    ]

  defp response_schema(2),
    do: [
      brokers: {:array, [node_id: :int32, host: :string, port: :int32, rack: :string]},
      cluster_id: :string,
      controller_id: :int32,
      topics:
        {:array,
         [
           error_code: :int16,
           name: :string,
           is_internal: :boolean,
           partitions:
             {:array,
              [
                error_code: :int16,
                partition_index: :int32,
                leader_id: :int32,
                replica_nodes: {:array, :int32},
                isr_nodes: {:array, :int32}
              ]}
         ]}
    ]

  defp response_schema(3),
    do: [
      throttle_time_ms: :int32,
      brokers: {:array, [node_id: :int32, host: :string, port: :int32, rack: :string]},
      cluster_id: :string,
      controller_id: :int32,
      topics:
        {:array,
         [
           error_code: :int16,
           name: :string,
           is_internal: :boolean,
           partitions:
             {:array,
              [
                error_code: :int16,
                partition_index: :int32,
                leader_id: :int32,
                replica_nodes: {:array, :int32},
                isr_nodes: {:array, :int32}
              ]}
         ]}
    ]

  defp response_schema(4),
    do: [
      throttle_time_ms: :int32,
      brokers: {:array, [node_id: :int32, host: :string, port: :int32, rack: :string]},
      cluster_id: :string,
      controller_id: :int32,
      topics:
        {:array,
         [
           error_code: :int16,
           name: :string,
           is_internal: :boolean,
           partitions:
             {:array,
              [
                error_code: :int16,
                partition_index: :int32,
                leader_id: :int32,
                replica_nodes: {:array, :int32},
                isr_nodes: {:array, :int32}
              ]}
         ]}
    ]

  defp response_schema(5),
    do: [
      throttle_time_ms: :int32,
      brokers: {:array, [node_id: :int32, host: :string, port: :int32, rack: :string]},
      cluster_id: :string,
      controller_id: :int32,
      topics:
        {:array,
         [
           error_code: :int16,
           name: :string,
           is_internal: :boolean,
           partitions:
             {:array,
              [
                error_code: :int16,
                partition_index: :int32,
                leader_id: :int32,
                replica_nodes: {:array, :int32},
                isr_nodes: {:array, :int32},
                offline_replicas: {:array, :int32}
              ]}
         ]}
    ]

  defp response_schema(6),
    do: [
      throttle_time_ms: :int32,
      brokers: {:array, [node_id: :int32, host: :string, port: :int32, rack: :string]},
      cluster_id: :string,
      controller_id: :int32,
      topics:
        {:array,
         [
           error_code: :int16,
           name: :string,
           is_internal: :boolean,
           partitions:
             {:array,
              [
                error_code: :int16,
                partition_index: :int32,
                leader_id: :int32,
                replica_nodes: {:array, :int32},
                isr_nodes: {:array, :int32},
                offline_replicas: {:array, :int32}
              ]}
         ]}
    ]

  defp response_schema(7),
    do: [
      throttle_time_ms: :int32,
      brokers: {:array, [node_id: :int32, host: :string, port: :int32, rack: :string]},
      cluster_id: :string,
      controller_id: :int32,
      topics:
        {:array,
         [
           error_code: :int16,
           name: :string,
           is_internal: :boolean,
           partitions:
             {:array,
              [
                error_code: :int16,
                partition_index: :int32,
                leader_id: :int32,
                leader_epoch: :int32,
                replica_nodes: {:array, :int32},
                isr_nodes: {:array, :int32},
                offline_replicas: {:array, :int32}
              ]}
         ]}
    ]

  defp response_schema(8),
    do: [
      throttle_time_ms: :int32,
      brokers: {:array, [node_id: :int32, host: :string, port: :int32, rack: :string]},
      cluster_id: :string,
      controller_id: :int32,
      topics:
        {:array,
         [
           error_code: :int16,
           name: :string,
           is_internal: :boolean,
           partitions:
             {:array,
              [
                error_code: :int16,
                partition_index: :int32,
                leader_id: :int32,
                leader_epoch: :int32,
                replica_nodes: {:array, :int32},
                isr_nodes: {:array, :int32},
                offline_replicas: {:array, :int32}
              ]},
           topic_authorized_operations: :int32
         ]},
      cluster_authorized_operations: :int32
    ]

  defp response_schema(9),
    do: [
      throttle_time_ms: :int32,
      brokers:
        {:compact_array,
         [
           node_id: :int32,
           host: :compact_string,
           port: :int32,
           rack: :compact_string,
           tag_buffer: {:tag_buffer, %{}}
         ]},
      cluster_id: :compact_string,
      controller_id: :int32,
      topics:
        {:compact_array,
         [
           error_code: :int16,
           name: :compact_string,
           is_internal: :boolean,
           partitions:
             {:compact_array,
              [
                error_code: :int16,
                partition_index: :int32,
                leader_id: :int32,
                leader_epoch: :int32,
                replica_nodes: {:compact_array, :int32},
                isr_nodes: {:compact_array, :int32},
                offline_replicas: {:compact_array, :int32},
                tag_buffer: {:tag_buffer, %{}}
              ]},
           topic_authorized_operations: :int32,
           tag_buffer: {:tag_buffer, %{}}
         ]},
      tag_buffer: {:tag_buffer, %{}}
    ]

  defp response_schema(10),
    do: [
      throttle_time_ms: :int32,
      brokers:
        {:compact_array,
         [
           node_id: :int32,
           host: :compact_string,
           port: :int32,
           rack: :compact_string,
           tag_buffer: {:tag_buffer, %{}}
         ]},
      cluster_id: :compact_string,
      controller_id: :int32,
      topics:
        {:compact_array,
         [
           error_code: :int16,
           name: :compact_string,
           topic_id: :uuid,
           is_internal: :boolean,
           partitions:
             {:compact_array,
              [
                error_code: :int16,
                partition_index: :int32,
                leader_id: :int32,
                leader_epoch: :int32,
                replica_nodes: {:compact_array, :int32},
                isr_nodes: {:compact_array, :int32},
                offline_replicas: {:compact_array, :int32},
                tag_buffer: {:tag_buffer, %{}}
              ]},
           topic_authorized_operations: :int32,
           tag_buffer: {:tag_buffer, %{}}
         ]},
      cluster_authorized_operations: :int32,
      tag_buffer: {:tag_buffer, %{}}
    ]

  defp response_schema(11),
    do: [
      throttle_time_ms: :int32,
      brokers:
        {:compact_array,
         [
           node_id: :int32,
           host: :compact_string,
           port: :int32,
           rack: :compact_string,
           tag_buffer: {:tag_buffer, %{}}
         ]},
      cluster_id: :compact_string,
      controller_id: :int32,
      topics:
        {:compact_array,
         [
           error_code: :int16,
           name: :compact_string,
           topic_id: :uuid,
           is_internal: :boolean,
           partitions:
             {:compact_array,
              [
                error_code: :int16,
                partition_index: :int32,
                leader_id: :int32,
                leader_epoch: :int32,
                replica_nodes: {:compact_array, :int32},
                isr_nodes: {:compact_array, :int32},
                offline_replicas: {:compact_array, :int32},
                tag_buffer: {:tag_buffer, %{}}
              ]},
           topic_authorized_operations: :int32,
           tag_buffer: {:tag_buffer, %{}}
         ]},
      tag_buffer: {:tag_buffer, %{}}
    ]

  defp response_schema(12),
    do: [
      throttle_time_ms: :int32,
      brokers:
        {:compact_array,
         [
           node_id: :int32,
           host: :compact_string,
           port: :int32,
           rack: :compact_string,
           tag_buffer: {:tag_buffer, %{}}
         ]},
      cluster_id: :compact_string,
      controller_id: :int32,
      topics:
        {:compact_array,
         [
           error_code: :int16,
           name: :compact_string,
           topic_id: :uuid,
           is_internal: :boolean,
           partitions:
             {:compact_array,
              [
                error_code: :int16,
                partition_index: :int32,
                leader_id: :int32,
                leader_epoch: :int32,
                replica_nodes: {:compact_array, :int32},
                isr_nodes: {:compact_array, :int32},
                offline_replicas: {:compact_array, :int32},
                tag_buffer: {:tag_buffer, %{}}
              ]},
           topic_authorized_operations: :int32,
           tag_buffer: {:tag_buffer, %{}}
         ]},
      tag_buffer: {:tag_buffer, %{}}
    ]
end