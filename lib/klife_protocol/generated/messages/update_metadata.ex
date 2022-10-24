# DO NOT EDIT THIS FILE MANUALLY  
# This module is automatically generated by running mix task generate_file
# every change must be done inside the mix task directly

defmodule KlifeProtocol.Messages.UpdateMetadata do
  @moduledoc """
  Kafka protocol UpdateMetadata message

  Request versions summary:   
  - Version 1 allows specifying multiple endpoints for each broker.
  - Version 2 adds the rack.
  - Version 3 adds the listener name.
  - Version 4 adds the offline replica list.
  - Version 5 adds the broker epoch field and normalizes partitions by topic.
  Version 7 adds topicId

  Response versions summary:
  - Versions 1, 2, 3, 4, and 5 are the same as version 0

  """

  alias KlifeProtocol.Deserializer
  alias KlifeProtocol.Serializer
  alias KlifeProtocol.Header

  @api_key 6
  @min_flexible_version_req 6
  @min_flexible_version_res 6

  @doc """
  Content fields:

  - controller_id: The controller id. (int32 | versions 0+)
  - controller_epoch: The controller epoch. (int32 | versions 0+)
  - broker_epoch: The broker epoch. (int64 | versions 5+)
  - ungrouped_partition_states: In older versions of this RPC, each partition that we would like to update. ([]UpdateMetadataPartitionState | versions 0-4)
      - topic_name: In older versions of this RPC, the topic name. (string | versions 0-4)
      - partition_index: The partition index. (int32 | versions 0+)
      - controller_epoch: The controller epoch. (int32 | versions 0+)
      - leader: The ID of the broker which is the current partition leader. (int32 | versions 0+)
      - leader_epoch: The leader epoch of this partition. (int32 | versions 0+)
      - isr: The brokers which are in the ISR for this partition. ([]int32 | versions 0+)
      - zk_version: The Zookeeper version. (int32 | versions 0+)
      - replicas: All the replicas of this partition. ([]int32 | versions 0+)
      - offline_replicas: The replicas of this partition which are offline. ([]int32 | versions 4+)
  - topic_states: In newer versions of this RPC, each topic that we would like to update. ([]UpdateMetadataTopicState | versions 5+)
      - topic_name: The topic name. (string | versions 5+)
      - topic_id: The topic id. (uuid | versions 7+)
      - partition_states: The partition that we would like to update. ([]UpdateMetadataPartitionState | versions 5+)
          - topic_name: In older versions of this RPC, the topic name. (string | versions 0-4)
          - partition_index: The partition index. (int32 | versions 0+)
          - controller_epoch: The controller epoch. (int32 | versions 0+)
          - leader: The ID of the broker which is the current partition leader. (int32 | versions 0+)
          - leader_epoch: The leader epoch of this partition. (int32 | versions 0+)
          - isr: The brokers which are in the ISR for this partition. ([]int32 | versions 0+)
          - zk_version: The Zookeeper version. (int32 | versions 0+)
          - replicas: All the replicas of this partition. ([]int32 | versions 0+)
          - offline_replicas: The replicas of this partition which are offline. ([]int32 | versions 4+)
  - live_brokers:  ([]UpdateMetadataBroker | versions 0+)
      - id: The broker id. (int32 | versions 0+)
      - v0_host: The broker hostname. (string | versions 0)
      - v0_port: The broker port. (int32 | versions 0)
      - endpoints: The broker endpoints. ([]UpdateMetadataEndpoint | versions 1+)
          - port: The port of this endpoint (int32 | versions 1+)
          - host: The hostname of this endpoint (string | versions 1+)
          - listener: The listener name. (string | versions 3+)
          - security_protocol: The security protocol type. (int16 | versions 1+)
      - rack: The rack which this broker belongs to. (string | versions 2+)

  """
  def serialize_request(%{headers: headers, content: content}, version) do
    headers
    |> Map.put(:request_api_key, @api_key)
    |> Map.put(:request_api_version, version)
    |> Header.serialize_request(req_header_version(version))
    |> then(&Serializer.execute(content, request_schema(version), &1))
  end

  @doc """
  Content fields:

  - error_code: The error code, or 0 if there was no error. (int16 | versions 0+)

  """
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
      controller_id: {:int32, %{is_nullable?: false}},
      controller_epoch: {:int32, %{is_nullable?: false}},
      ungrouped_partition_states:
        {{:array,
          [
            topic_name: {:string, %{is_nullable?: false}},
            partition_index: {:int32, %{is_nullable?: false}},
            controller_epoch: {:int32, %{is_nullable?: false}},
            leader: {:int32, %{is_nullable?: false}},
            leader_epoch: {:int32, %{is_nullable?: false}},
            isr: {{:array, :int32}, %{is_nullable?: false}},
            zk_version: {:int32, %{is_nullable?: false}},
            replicas: {{:array, :int32}, %{is_nullable?: false}}
          ]}, %{is_nullable?: false}},
      live_brokers:
        {{:array,
          [
            id: {:int32, %{is_nullable?: false}},
            v0_host: {:string, %{is_nullable?: false}},
            v0_port: {:int32, %{is_nullable?: false}}
          ]}, %{is_nullable?: false}}
    ]

  defp request_schema(1),
    do: [
      controller_id: {:int32, %{is_nullable?: false}},
      controller_epoch: {:int32, %{is_nullable?: false}},
      ungrouped_partition_states:
        {{:array,
          [
            topic_name: {:string, %{is_nullable?: false}},
            partition_index: {:int32, %{is_nullable?: false}},
            controller_epoch: {:int32, %{is_nullable?: false}},
            leader: {:int32, %{is_nullable?: false}},
            leader_epoch: {:int32, %{is_nullable?: false}},
            isr: {{:array, :int32}, %{is_nullable?: false}},
            zk_version: {:int32, %{is_nullable?: false}},
            replicas: {{:array, :int32}, %{is_nullable?: false}}
          ]}, %{is_nullable?: false}},
      live_brokers:
        {{:array,
          [
            id: {:int32, %{is_nullable?: false}},
            endpoints:
              {{:array,
                [
                  port: {:int32, %{is_nullable?: false}},
                  host: {:string, %{is_nullable?: false}},
                  security_protocol: {:int16, %{is_nullable?: false}}
                ]}, %{is_nullable?: false}}
          ]}, %{is_nullable?: false}}
    ]

  defp request_schema(2),
    do: [
      controller_id: {:int32, %{is_nullable?: false}},
      controller_epoch: {:int32, %{is_nullable?: false}},
      ungrouped_partition_states:
        {{:array,
          [
            topic_name: {:string, %{is_nullable?: false}},
            partition_index: {:int32, %{is_nullable?: false}},
            controller_epoch: {:int32, %{is_nullable?: false}},
            leader: {:int32, %{is_nullable?: false}},
            leader_epoch: {:int32, %{is_nullable?: false}},
            isr: {{:array, :int32}, %{is_nullable?: false}},
            zk_version: {:int32, %{is_nullable?: false}},
            replicas: {{:array, :int32}, %{is_nullable?: false}}
          ]}, %{is_nullable?: false}},
      live_brokers:
        {{:array,
          [
            id: {:int32, %{is_nullable?: false}},
            endpoints:
              {{:array,
                [
                  port: {:int32, %{is_nullable?: false}},
                  host: {:string, %{is_nullable?: false}},
                  security_protocol: {:int16, %{is_nullable?: false}}
                ]}, %{is_nullable?: false}},
            rack: {:string, %{is_nullable?: true}}
          ]}, %{is_nullable?: false}}
    ]

  defp request_schema(3),
    do: [
      controller_id: {:int32, %{is_nullable?: false}},
      controller_epoch: {:int32, %{is_nullable?: false}},
      ungrouped_partition_states:
        {{:array,
          [
            topic_name: {:string, %{is_nullable?: false}},
            partition_index: {:int32, %{is_nullable?: false}},
            controller_epoch: {:int32, %{is_nullable?: false}},
            leader: {:int32, %{is_nullable?: false}},
            leader_epoch: {:int32, %{is_nullable?: false}},
            isr: {{:array, :int32}, %{is_nullable?: false}},
            zk_version: {:int32, %{is_nullable?: false}},
            replicas: {{:array, :int32}, %{is_nullable?: false}}
          ]}, %{is_nullable?: false}},
      live_brokers:
        {{:array,
          [
            id: {:int32, %{is_nullable?: false}},
            endpoints:
              {{:array,
                [
                  port: {:int32, %{is_nullable?: false}},
                  host: {:string, %{is_nullable?: false}},
                  listener: {:string, %{is_nullable?: false}},
                  security_protocol: {:int16, %{is_nullable?: false}}
                ]}, %{is_nullable?: false}},
            rack: {:string, %{is_nullable?: true}}
          ]}, %{is_nullable?: false}}
    ]

  defp request_schema(4),
    do: [
      controller_id: {:int32, %{is_nullable?: false}},
      controller_epoch: {:int32, %{is_nullable?: false}},
      ungrouped_partition_states:
        {{:array,
          [
            topic_name: {:string, %{is_nullable?: false}},
            partition_index: {:int32, %{is_nullable?: false}},
            controller_epoch: {:int32, %{is_nullable?: false}},
            leader: {:int32, %{is_nullable?: false}},
            leader_epoch: {:int32, %{is_nullable?: false}},
            isr: {{:array, :int32}, %{is_nullable?: false}},
            zk_version: {:int32, %{is_nullable?: false}},
            replicas: {{:array, :int32}, %{is_nullable?: false}},
            offline_replicas: {{:array, :int32}, %{is_nullable?: false}}
          ]}, %{is_nullable?: false}},
      live_brokers:
        {{:array,
          [
            id: {:int32, %{is_nullable?: false}},
            endpoints:
              {{:array,
                [
                  port: {:int32, %{is_nullable?: false}},
                  host: {:string, %{is_nullable?: false}},
                  listener: {:string, %{is_nullable?: false}},
                  security_protocol: {:int16, %{is_nullable?: false}}
                ]}, %{is_nullable?: false}},
            rack: {:string, %{is_nullable?: true}}
          ]}, %{is_nullable?: false}}
    ]

  defp request_schema(5),
    do: [
      controller_id: {:int32, %{is_nullable?: false}},
      controller_epoch: {:int32, %{is_nullable?: false}},
      broker_epoch: {:int64, %{is_nullable?: false}},
      topic_states:
        {{:array,
          [
            topic_name: {:string, %{is_nullable?: false}},
            partition_states:
              {{:array,
                [
                  partition_index: {:int32, %{is_nullable?: false}},
                  controller_epoch: {:int32, %{is_nullable?: false}},
                  leader: {:int32, %{is_nullable?: false}},
                  leader_epoch: {:int32, %{is_nullable?: false}},
                  isr: {{:array, :int32}, %{is_nullable?: false}},
                  zk_version: {:int32, %{is_nullable?: false}},
                  replicas: {{:array, :int32}, %{is_nullable?: false}},
                  offline_replicas: {{:array, :int32}, %{is_nullable?: false}}
                ]}, %{is_nullable?: false}}
          ]}, %{is_nullable?: false}},
      live_brokers:
        {{:array,
          [
            id: {:int32, %{is_nullable?: false}},
            endpoints:
              {{:array,
                [
                  port: {:int32, %{is_nullable?: false}},
                  host: {:string, %{is_nullable?: false}},
                  listener: {:string, %{is_nullable?: false}},
                  security_protocol: {:int16, %{is_nullable?: false}}
                ]}, %{is_nullable?: false}},
            rack: {:string, %{is_nullable?: true}}
          ]}, %{is_nullable?: false}}
    ]

  defp request_schema(6),
    do: [
      controller_id: {:int32, %{is_nullable?: false}},
      controller_epoch: {:int32, %{is_nullable?: false}},
      broker_epoch: {:int64, %{is_nullable?: false}},
      topic_states:
        {{:compact_array,
          [
            topic_name: {:compact_string, %{is_nullable?: false}},
            partition_states:
              {{:compact_array,
                [
                  partition_index: {:int32, %{is_nullable?: false}},
                  controller_epoch: {:int32, %{is_nullable?: false}},
                  leader: {:int32, %{is_nullable?: false}},
                  leader_epoch: {:int32, %{is_nullable?: false}},
                  isr: {{:compact_array, :int32}, %{is_nullable?: false}},
                  zk_version: {:int32, %{is_nullable?: false}},
                  replicas: {{:compact_array, :int32}, %{is_nullable?: false}},
                  offline_replicas: {{:compact_array, :int32}, %{is_nullable?: false}},
                  tag_buffer: {:tag_buffer, []}
                ]}, %{is_nullable?: false}},
            tag_buffer: {:tag_buffer, []}
          ]}, %{is_nullable?: false}},
      live_brokers:
        {{:compact_array,
          [
            id: {:int32, %{is_nullable?: false}},
            endpoints:
              {{:compact_array,
                [
                  port: {:int32, %{is_nullable?: false}},
                  host: {:compact_string, %{is_nullable?: false}},
                  listener: {:compact_string, %{is_nullable?: false}},
                  security_protocol: {:int16, %{is_nullable?: false}},
                  tag_buffer: {:tag_buffer, []}
                ]}, %{is_nullable?: false}},
            rack: {:compact_string, %{is_nullable?: true}},
            tag_buffer: {:tag_buffer, []}
          ]}, %{is_nullable?: false}},
      tag_buffer: {:tag_buffer, []}
    ]

  defp request_schema(7),
    do: [
      controller_id: {:int32, %{is_nullable?: false}},
      controller_epoch: {:int32, %{is_nullable?: false}},
      broker_epoch: {:int64, %{is_nullable?: false}},
      topic_states:
        {{:compact_array,
          [
            topic_name: {:compact_string, %{is_nullable?: false}},
            topic_id: {:uuid, %{is_nullable?: false}},
            partition_states:
              {{:compact_array,
                [
                  partition_index: {:int32, %{is_nullable?: false}},
                  controller_epoch: {:int32, %{is_nullable?: false}},
                  leader: {:int32, %{is_nullable?: false}},
                  leader_epoch: {:int32, %{is_nullable?: false}},
                  isr: {{:compact_array, :int32}, %{is_nullable?: false}},
                  zk_version: {:int32, %{is_nullable?: false}},
                  replicas: {{:compact_array, :int32}, %{is_nullable?: false}},
                  offline_replicas: {{:compact_array, :int32}, %{is_nullable?: false}},
                  tag_buffer: {:tag_buffer, []}
                ]}, %{is_nullable?: false}},
            tag_buffer: {:tag_buffer, []}
          ]}, %{is_nullable?: false}},
      live_brokers:
        {{:compact_array,
          [
            id: {:int32, %{is_nullable?: false}},
            endpoints:
              {{:compact_array,
                [
                  port: {:int32, %{is_nullable?: false}},
                  host: {:compact_string, %{is_nullable?: false}},
                  listener: {:compact_string, %{is_nullable?: false}},
                  security_protocol: {:int16, %{is_nullable?: false}},
                  tag_buffer: {:tag_buffer, []}
                ]}, %{is_nullable?: false}},
            rack: {:compact_string, %{is_nullable?: true}},
            tag_buffer: {:tag_buffer, []}
          ]}, %{is_nullable?: false}},
      tag_buffer: {:tag_buffer, []}
    ]

  defp response_schema(0), do: [error_code: {:int16, %{is_nullable?: false}}]
  defp response_schema(1), do: [error_code: {:int16, %{is_nullable?: false}}]
  defp response_schema(2), do: [error_code: {:int16, %{is_nullable?: false}}]
  defp response_schema(3), do: [error_code: {:int16, %{is_nullable?: false}}]
  defp response_schema(4), do: [error_code: {:int16, %{is_nullable?: false}}]
  defp response_schema(5), do: [error_code: {:int16, %{is_nullable?: false}}]

  defp response_schema(6),
    do: [error_code: {:int16, %{is_nullable?: false}}, tag_buffer: {:tag_buffer, %{}}]

  defp response_schema(7),
    do: [error_code: {:int16, %{is_nullable?: false}}, tag_buffer: {:tag_buffer, %{}}]
end