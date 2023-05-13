# DO NOT EDIT THIS FILE MANUALLY  
# This module is automatically generated by running mix task generate_file
# every change must be done inside the mix task directly

defmodule KlifeProtocol.Messages.StopReplica do
  @moduledoc """
  Kafka protocol StopReplica message

  Request versions summary:   
  - Version 1 adds the broker epoch and reorganizes the partitions to be stored
  per topic.
  - Version 2 is the first flexible version.
  - Version 3 adds the leader epoch per partition (KIP-570).
  - Version 4 adds KRaft Controller ID field as part of KIP-866

  Response versions summary:
  - Version 1 is the same as version 0.
  - Version 2 is the first flexible version.
  - Version 3 returns FENCED_LEADER_EPOCH if the epoch of the leader is stale (KIP-570).

  """

  alias KlifeProtocol.Deserializer
  alias KlifeProtocol.Serializer
  alias KlifeProtocol.Header

  @api_key 5
  @min_flexible_version_req 2
  @min_flexible_version_res 2

  @doc """
  Content fields:

  - controller_id: The controller id. (int32 | versions 0+)
  - is_k_raft_controller: If KRaft controller id is used during migration. See KIP-866 (bool | versions 4+)
  - controller_epoch: The controller epoch. (int32 | versions 0+)
  - broker_epoch: The broker epoch. (int64 | versions 1+)
  - delete_partitions: Whether these partitions should be deleted. (bool | versions 0-2)
  - ungrouped_partitions: The partitions to stop. ([]StopReplicaPartitionV0 | versions 0)
      - topic_name: The topic name. (string | versions 0)
      - partition_index: The partition index. (int32 | versions 0)
  - topics: The topics to stop. ([]StopReplicaTopicV1 | versions 1-2)
      - name: The topic name. (string | versions 1-2)
      - partition_indexes: The partition indexes. ([]int32 | versions 1-2)
  - topic_states: Each topic. ([]StopReplicaTopicState | versions 3+)
      - topic_name: The topic name. (string | versions 3+)
      - partition_states: The state of each partition ([]StopReplicaPartitionState | versions 3+)
          - partition_index: The partition index. (int32 | versions 3+)
          - leader_epoch: The leader epoch. (int32 | versions 3+)
          - delete_partition: Whether this partition should be deleted. (bool | versions 3+)

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

  - error_code: The top-level error code, or 0 if there was no top-level error. (int16 | versions 0+)
  - partition_errors: The responses for each partition. ([]StopReplicaPartitionError | versions 0+)
      - topic_name: The topic name. (string | versions 0+)
      - partition_index: The partition index. (int32 | versions 0+)
      - error_code: The partition error code, or 0 if there was no partition error. (int16 | versions 0+)

  """
  def deserialize_response(data, version) do
    {:ok, {headers, rest_data}} = Header.deserialize_response(data, res_header_version(version))

    case Deserializer.execute(rest_data, response_schema(version)) do
      {:ok, {content, <<>>}} ->
        {:ok, %{headers: headers, content: content}}

      {:error, _reason} = err ->
        err
    end
  end

  def max_supported_version(), do: 4
  def min_supported_version(), do: 0

  defp req_header_version(msg_version),
    do: if(msg_version >= @min_flexible_version_req, do: 2, else: 1)

  defp res_header_version(msg_version),
    do: if(msg_version >= @min_flexible_version_res, do: 1, else: 0)

  defp request_schema(0),
    do: [
      controller_id: {:int32, %{is_nullable?: false}},
      controller_epoch: {:int32, %{is_nullable?: false}},
      delete_partitions: {:boolean, %{is_nullable?: false}},
      ungrouped_partitions:
        {{:array,
          [
            topic_name: {:string, %{is_nullable?: false}},
            partition_index: {:int32, %{is_nullable?: false}}
          ]}, %{is_nullable?: false}}
    ]

  defp request_schema(1),
    do: [
      controller_id: {:int32, %{is_nullable?: false}},
      controller_epoch: {:int32, %{is_nullable?: false}},
      broker_epoch: {:int64, %{is_nullable?: false}},
      delete_partitions: {:boolean, %{is_nullable?: false}},
      topics:
        {{:array,
          [
            name: {:string, %{is_nullable?: false}},
            partition_indexes: {{:array, :int32}, %{is_nullable?: false}}
          ]}, %{is_nullable?: false}}
    ]

  defp request_schema(2),
    do: [
      controller_id: {:int32, %{is_nullable?: false}},
      controller_epoch: {:int32, %{is_nullable?: false}},
      broker_epoch: {:int64, %{is_nullable?: false}},
      delete_partitions: {:boolean, %{is_nullable?: false}},
      topics:
        {{:compact_array,
          [
            name: {:compact_string, %{is_nullable?: false}},
            partition_indexes: {{:compact_array, :int32}, %{is_nullable?: false}},
            tag_buffer: {:tag_buffer, []}
          ]}, %{is_nullable?: false}},
      tag_buffer: {:tag_buffer, []}
    ]

  defp request_schema(3),
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
                  leader_epoch: {:int32, %{is_nullable?: false}},
                  delete_partition: {:boolean, %{is_nullable?: false}},
                  tag_buffer: {:tag_buffer, []}
                ]}, %{is_nullable?: false}},
            tag_buffer: {:tag_buffer, []}
          ]}, %{is_nullable?: false}},
      tag_buffer: {:tag_buffer, []}
    ]

  defp request_schema(4),
    do: [
      controller_id: {:int32, %{is_nullable?: false}},
      is_k_raft_controller: {:boolean, %{is_nullable?: false}},
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
                  leader_epoch: {:int32, %{is_nullable?: false}},
                  delete_partition: {:boolean, %{is_nullable?: false}},
                  tag_buffer: {:tag_buffer, []}
                ]}, %{is_nullable?: false}},
            tag_buffer: {:tag_buffer, []}
          ]}, %{is_nullable?: false}},
      tag_buffer: {:tag_buffer, []}
    ]

  defp request_schema(unkown_version),
    do: raise("Unknown version #{unkown_version} for message StopReplica")

  defp response_schema(0),
    do: [
      error_code: {:int16, %{is_nullable?: false}},
      partition_errors:
        {{:array,
          [
            topic_name: {:string, %{is_nullable?: false}},
            partition_index: {:int32, %{is_nullable?: false}},
            error_code: {:int16, %{is_nullable?: false}}
          ]}, %{is_nullable?: false}}
    ]

  defp response_schema(1),
    do: [
      error_code: {:int16, %{is_nullable?: false}},
      partition_errors:
        {{:array,
          [
            topic_name: {:string, %{is_nullable?: false}},
            partition_index: {:int32, %{is_nullable?: false}},
            error_code: {:int16, %{is_nullable?: false}}
          ]}, %{is_nullable?: false}}
    ]

  defp response_schema(2),
    do: [
      error_code: {:int16, %{is_nullable?: false}},
      partition_errors:
        {{:compact_array,
          [
            topic_name: {:compact_string, %{is_nullable?: false}},
            partition_index: {:int32, %{is_nullable?: false}},
            error_code: {:int16, %{is_nullable?: false}},
            tag_buffer: {:tag_buffer, %{}}
          ]}, %{is_nullable?: false}},
      tag_buffer: {:tag_buffer, %{}}
    ]

  defp response_schema(3),
    do: [
      error_code: {:int16, %{is_nullable?: false}},
      partition_errors:
        {{:compact_array,
          [
            topic_name: {:compact_string, %{is_nullable?: false}},
            partition_index: {:int32, %{is_nullable?: false}},
            error_code: {:int16, %{is_nullable?: false}},
            tag_buffer: {:tag_buffer, %{}}
          ]}, %{is_nullable?: false}},
      tag_buffer: {:tag_buffer, %{}}
    ]

  defp response_schema(4),
    do: [
      error_code: {:int16, %{is_nullable?: false}},
      partition_errors:
        {{:compact_array,
          [
            topic_name: {:compact_string, %{is_nullable?: false}},
            partition_index: {:int32, %{is_nullable?: false}},
            error_code: {:int16, %{is_nullable?: false}},
            tag_buffer: {:tag_buffer, %{}}
          ]}, %{is_nullable?: false}},
      tag_buffer: {:tag_buffer, %{}}
    ]

  defp response_schema(unkown_version),
    do: raise("Unknown version #{unkown_version} for message StopReplica")
end