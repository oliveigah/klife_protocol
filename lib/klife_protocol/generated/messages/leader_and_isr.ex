# DO NOT EDIT THIS FILE MANUALLY
# This module is automatically generated by running mix task generate_file
# every change must be done inside the mix task directly

defmodule KlifeProtocol.Messages.LeaderAndIsr do
  @moduledoc """
  Kafka protocol LeaderAndIsr message

  Request versions summary:
  - Version 1 adds IsNew.
  - Version 2 adds broker epoch and reorganizes the partitions by topic.
  - Version 3 adds AddingReplicas and RemovingReplicas.
  - Version 4 is the first flexible version.
  - Version 5 adds Topic ID and Type to the TopicStates, as described in KIP-516.
  - Version 6 adds LeaderRecoveryState as described in KIP-704.
  - Version 7 adds KRaft Controller ID field as part of KIP-866

  Response versions summary:
  - Version 1 adds KAFKA_STORAGE_ERROR as a valid error code.
  - Version 2 is the same as version 1.
  - Version 3 is the same as version 2.
  - Version 4 is the first flexible version.
  - Version 5 removes TopicName and replaces it with TopicId and reorganizes
  the partitions by topic, as described by KIP-516.

  """

  alias KlifeProtocol.Deserializer
  alias KlifeProtocol.Serializer
  alias KlifeProtocol.Header

  @api_key 4
  @min_flexible_version_req 4
  @min_flexible_version_res 4

  @doc """
  Receives a map and serialize it to kafka wire format of the given version.

  Input content fields:
  - controller_id: The current controller ID. (int32 | versions 0+)
  - is_k_raft_controller: If KRaft controller id is used during migration. See KIP-866 (bool | versions 7+)
  - controller_epoch: The current controller epoch. (int32 | versions 0+)
  - broker_epoch: The current broker epoch. (int64 | versions 2+)
  - type: The type that indicates whether all topics are included in the request (int8 | versions 5+)
  - ungrouped_partition_states: The state of each partition, in a v0 or v1 message. ([]LeaderAndIsrPartitionState | versions 0-1)
      - topic_name: The topic name.  This is only present in v0 or v1. (string | versions 0-1)
      - partition_index: The partition index. (int32 | versions 0+)
      - controller_epoch: The controller epoch. (int32 | versions 0+)
      - leader: The broker ID of the leader. (int32 | versions 0+)
      - leader_epoch: The leader epoch. (int32 | versions 0+)
      - isr: The in-sync replica IDs. ([]int32 | versions 0+)
      - partition_epoch: The current epoch for the partition. The epoch is a monotonically increasing value which is incremented after every partition change. (Since the LeaderAndIsr request is only used by the legacy controller, this corresponds to the zkVersion) (int32 | versions 0+)
      - replicas: The replica IDs. ([]int32 | versions 0+)
      - adding_replicas: The replica IDs that we are adding this partition to, or null if no replicas are being added. ([]int32 | versions 3+)
      - removing_replicas: The replica IDs that we are removing this partition from, or null if no replicas are being removed. ([]int32 | versions 3+)
      - is_new: Whether the replica should have existed on the broker or not. (bool | versions 1+)
      - leader_recovery_state: 1 if the partition is recovering from an unclean leader election; 0 otherwise. (int8 | versions 6+)
  - topic_states: Each topic. ([]LeaderAndIsrTopicState | versions 2+)
      - topic_name: The topic name. (string | versions 2+)
      - topic_id: The unique topic ID. (uuid | versions 5+)
      - partition_states: The state of each partition ([]LeaderAndIsrPartitionState | versions 2+)
          - topic_name: The topic name.  This is only present in v0 or v1. (string | versions 0-1)
          - partition_index: The partition index. (int32 | versions 0+)
          - controller_epoch: The controller epoch. (int32 | versions 0+)
          - leader: The broker ID of the leader. (int32 | versions 0+)
          - leader_epoch: The leader epoch. (int32 | versions 0+)
          - isr: The in-sync replica IDs. ([]int32 | versions 0+)
          - partition_epoch: The current epoch for the partition. The epoch is a monotonically increasing value which is incremented after every partition change. (Since the LeaderAndIsr request is only used by the legacy controller, this corresponds to the zkVersion) (int32 | versions 0+)
          - replicas: The replica IDs. ([]int32 | versions 0+)
          - adding_replicas: The replica IDs that we are adding this partition to, or null if no replicas are being added. ([]int32 | versions 3+)
          - removing_replicas: The replica IDs that we are removing this partition from, or null if no replicas are being removed. ([]int32 | versions 3+)
          - is_new: Whether the replica should have existed on the broker or not. (bool | versions 1+)
          - leader_recovery_state: 1 if the partition is recovering from an unclean leader election; 0 otherwise. (int8 | versions 6+)
  - live_leaders: The current live leaders. ([]LeaderAndIsrLiveLeader | versions 0+)
      - broker_id: The leader's broker ID. (int32 | versions 0+)
      - host_name: The leader's hostname. (string | versions 0+)
      - port: The leader's port. (int32 | versions 0+)

  """
  def serialize_request(%{headers: headers, content: content}, version) do
    headers
    |> Map.put(:request_api_key, @api_key)
    |> Map.put(:request_api_version, version)
    |> Header.serialize_request(req_header_version(version))
    |> then(&Serializer.execute(content, request_schema(version), &1))
  end

  @doc """
  Receive a binary in the kafka wire format and deserialize it into a map.

  Response content fields:

  - error_code: The error code, or 0 if there was no error. (int16 | versions 0+)
  - partition_errors: Each partition in v0 to v4 message. ([]LeaderAndIsrPartitionError | versions 0-4)
      - topic_name: The topic name. (string | versions 0-4)
      - partition_index: The partition index. (int32 | versions 0+)
      - error_code: The partition error code, or 0 if there was no error. (int16 | versions 0+)
  - topics: Each topic ([]LeaderAndIsrTopicError | versions 5+)
      - topic_id: The unique topic ID (uuid | versions 5+)
      - partition_errors: Each partition. ([]LeaderAndIsrPartitionError | versions 5+)
          - topic_name: The topic name. (string | versions 0-4)
          - partition_index: The partition index. (int32 | versions 0+)
          - error_code: The partition error code, or 0 if there was no error. (int16 | versions 0+)

  """
  def deserialize_response(data, version, with_header? \\ true)

  def deserialize_response(data, version, true) do
    {:ok, {headers, rest_data}} = Header.deserialize_response(data, res_header_version(version))

    case Deserializer.execute(rest_data, response_schema(version)) do
      {:ok, {content, <<>>}} ->
        {:ok, %{headers: headers, content: content}}

      {:error, _reason} = err ->
        err
    end
  end

  def deserialize_response(data, version, false) do
    case Deserializer.execute(data, response_schema(version)) do
      {:ok, {content, <<>>}} ->
        {:ok, %{content: content}}

      {:error, _reason} = err ->
        err
    end
  end

  @doc """
  Returns the message api key number.
  """
  def api_key(), do: @api_key

  @doc """
  Returns the current max supported version of this message.
  """
  def max_supported_version(), do: 7

  @doc """
  Returns the current min supported version of this message.
  """
  def min_supported_version(), do: 0

  defp req_header_version(msg_version),
    do: if(msg_version >= @min_flexible_version_req, do: 2, else: 1)

  defp res_header_version(msg_version),
    do: if(msg_version >= @min_flexible_version_res, do: 1, else: 0)

  def request_schema(0),
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
            partition_epoch: {:int32, %{is_nullable?: false}},
            replicas: {{:array, :int32}, %{is_nullable?: false}}
          ]}, %{is_nullable?: false}},
      live_leaders:
        {{:array,
          [
            broker_id: {:int32, %{is_nullable?: false}},
            host_name: {:string, %{is_nullable?: false}},
            port: {:int32, %{is_nullable?: false}}
          ]}, %{is_nullable?: false}}
    ]

  def request_schema(1),
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
            partition_epoch: {:int32, %{is_nullable?: false}},
            replicas: {{:array, :int32}, %{is_nullable?: false}},
            is_new: {:boolean, %{is_nullable?: false}}
          ]}, %{is_nullable?: false}},
      live_leaders:
        {{:array,
          [
            broker_id: {:int32, %{is_nullable?: false}},
            host_name: {:string, %{is_nullable?: false}},
            port: {:int32, %{is_nullable?: false}}
          ]}, %{is_nullable?: false}}
    ]

  def request_schema(2),
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
                  partition_epoch: {:int32, %{is_nullable?: false}},
                  replicas: {{:array, :int32}, %{is_nullable?: false}},
                  is_new: {:boolean, %{is_nullable?: false}}
                ]}, %{is_nullable?: false}}
          ]}, %{is_nullable?: false}},
      live_leaders:
        {{:array,
          [
            broker_id: {:int32, %{is_nullable?: false}},
            host_name: {:string, %{is_nullable?: false}},
            port: {:int32, %{is_nullable?: false}}
          ]}, %{is_nullable?: false}}
    ]

  def request_schema(3),
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
                  partition_epoch: {:int32, %{is_nullable?: false}},
                  replicas: {{:array, :int32}, %{is_nullable?: false}},
                  adding_replicas: {{:array, :int32}, %{is_nullable?: false}},
                  removing_replicas: {{:array, :int32}, %{is_nullable?: false}},
                  is_new: {:boolean, %{is_nullable?: false}}
                ]}, %{is_nullable?: false}}
          ]}, %{is_nullable?: false}},
      live_leaders:
        {{:array,
          [
            broker_id: {:int32, %{is_nullable?: false}},
            host_name: {:string, %{is_nullable?: false}},
            port: {:int32, %{is_nullable?: false}}
          ]}, %{is_nullable?: false}}
    ]

  def request_schema(4),
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
                  partition_epoch: {:int32, %{is_nullable?: false}},
                  replicas: {{:compact_array, :int32}, %{is_nullable?: false}},
                  adding_replicas: {{:compact_array, :int32}, %{is_nullable?: false}},
                  removing_replicas: {{:compact_array, :int32}, %{is_nullable?: false}},
                  is_new: {:boolean, %{is_nullable?: false}},
                  tag_buffer: {:tag_buffer, []}
                ]}, %{is_nullable?: false}},
            tag_buffer: {:tag_buffer, []}
          ]}, %{is_nullable?: false}},
      live_leaders:
        {{:compact_array,
          [
            broker_id: {:int32, %{is_nullable?: false}},
            host_name: {:compact_string, %{is_nullable?: false}},
            port: {:int32, %{is_nullable?: false}},
            tag_buffer: {:tag_buffer, []}
          ]}, %{is_nullable?: false}},
      tag_buffer: {:tag_buffer, []}
    ]

  def request_schema(5),
    do: [
      controller_id: {:int32, %{is_nullable?: false}},
      controller_epoch: {:int32, %{is_nullable?: false}},
      broker_epoch: {:int64, %{is_nullable?: false}},
      type: {:int8, %{is_nullable?: false}},
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
                  partition_epoch: {:int32, %{is_nullable?: false}},
                  replicas: {{:compact_array, :int32}, %{is_nullable?: false}},
                  adding_replicas: {{:compact_array, :int32}, %{is_nullable?: false}},
                  removing_replicas: {{:compact_array, :int32}, %{is_nullable?: false}},
                  is_new: {:boolean, %{is_nullable?: false}},
                  tag_buffer: {:tag_buffer, []}
                ]}, %{is_nullable?: false}},
            tag_buffer: {:tag_buffer, []}
          ]}, %{is_nullable?: false}},
      live_leaders:
        {{:compact_array,
          [
            broker_id: {:int32, %{is_nullable?: false}},
            host_name: {:compact_string, %{is_nullable?: false}},
            port: {:int32, %{is_nullable?: false}},
            tag_buffer: {:tag_buffer, []}
          ]}, %{is_nullable?: false}},
      tag_buffer: {:tag_buffer, []}
    ]

  def request_schema(6),
    do: [
      controller_id: {:int32, %{is_nullable?: false}},
      controller_epoch: {:int32, %{is_nullable?: false}},
      broker_epoch: {:int64, %{is_nullable?: false}},
      type: {:int8, %{is_nullable?: false}},
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
                  partition_epoch: {:int32, %{is_nullable?: false}},
                  replicas: {{:compact_array, :int32}, %{is_nullable?: false}},
                  adding_replicas: {{:compact_array, :int32}, %{is_nullable?: false}},
                  removing_replicas: {{:compact_array, :int32}, %{is_nullable?: false}},
                  is_new: {:boolean, %{is_nullable?: false}},
                  leader_recovery_state: {:int8, %{is_nullable?: false}},
                  tag_buffer: {:tag_buffer, []}
                ]}, %{is_nullable?: false}},
            tag_buffer: {:tag_buffer, []}
          ]}, %{is_nullable?: false}},
      live_leaders:
        {{:compact_array,
          [
            broker_id: {:int32, %{is_nullable?: false}},
            host_name: {:compact_string, %{is_nullable?: false}},
            port: {:int32, %{is_nullable?: false}},
            tag_buffer: {:tag_buffer, []}
          ]}, %{is_nullable?: false}},
      tag_buffer: {:tag_buffer, []}
    ]

  def request_schema(7),
    do: [
      controller_id: {:int32, %{is_nullable?: false}},
      is_k_raft_controller: {:boolean, %{is_nullable?: false}},
      controller_epoch: {:int32, %{is_nullable?: false}},
      broker_epoch: {:int64, %{is_nullable?: false}},
      type: {:int8, %{is_nullable?: false}},
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
                  partition_epoch: {:int32, %{is_nullable?: false}},
                  replicas: {{:compact_array, :int32}, %{is_nullable?: false}},
                  adding_replicas: {{:compact_array, :int32}, %{is_nullable?: false}},
                  removing_replicas: {{:compact_array, :int32}, %{is_nullable?: false}},
                  is_new: {:boolean, %{is_nullable?: false}},
                  leader_recovery_state: {:int8, %{is_nullable?: false}},
                  tag_buffer: {:tag_buffer, []}
                ]}, %{is_nullable?: false}},
            tag_buffer: {:tag_buffer, []}
          ]}, %{is_nullable?: false}},
      live_leaders:
        {{:compact_array,
          [
            broker_id: {:int32, %{is_nullable?: false}},
            host_name: {:compact_string, %{is_nullable?: false}},
            port: {:int32, %{is_nullable?: false}},
            tag_buffer: {:tag_buffer, []}
          ]}, %{is_nullable?: false}},
      tag_buffer: {:tag_buffer, []}
    ]

  def request_schema(unkown_version),
    do: raise("Unknown version #{unkown_version} for message LeaderAndIsr")

  def response_schema(0),
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

  def response_schema(1),
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

  def response_schema(2),
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

  def response_schema(3),
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

  def response_schema(4),
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

  def response_schema(5),
    do: [
      error_code: {:int16, %{is_nullable?: false}},
      topics:
        {{:compact_array,
          [
            topic_id: {:uuid, %{is_nullable?: false}},
            partition_errors:
              {{:compact_array,
                [
                  partition_index: {:int32, %{is_nullable?: false}},
                  error_code: {:int16, %{is_nullable?: false}},
                  tag_buffer: {:tag_buffer, %{}}
                ]}, %{is_nullable?: false}},
            tag_buffer: {:tag_buffer, %{}}
          ]}, %{is_nullable?: false}},
      tag_buffer: {:tag_buffer, %{}}
    ]

  def response_schema(6),
    do: [
      error_code: {:int16, %{is_nullable?: false}},
      topics:
        {{:compact_array,
          [
            topic_id: {:uuid, %{is_nullable?: false}},
            partition_errors:
              {{:compact_array,
                [
                  partition_index: {:int32, %{is_nullable?: false}},
                  error_code: {:int16, %{is_nullable?: false}},
                  tag_buffer: {:tag_buffer, %{}}
                ]}, %{is_nullable?: false}},
            tag_buffer: {:tag_buffer, %{}}
          ]}, %{is_nullable?: false}},
      tag_buffer: {:tag_buffer, %{}}
    ]

  def response_schema(7),
    do: [
      error_code: {:int16, %{is_nullable?: false}},
      topics:
        {{:compact_array,
          [
            topic_id: {:uuid, %{is_nullable?: false}},
            partition_errors:
              {{:compact_array,
                [
                  partition_index: {:int32, %{is_nullable?: false}},
                  error_code: {:int16, %{is_nullable?: false}},
                  tag_buffer: {:tag_buffer, %{}}
                ]}, %{is_nullable?: false}},
            tag_buffer: {:tag_buffer, %{}}
          ]}, %{is_nullable?: false}},
      tag_buffer: {:tag_buffer, %{}}
    ]

  def response_schema(unkown_version),
    do: raise("Unknown version #{unkown_version} for message LeaderAndIsr")
end
