# DO NOT EDIT THIS FILE MANUALLY  
# This module is automatically generated by running mix task generate_file
# every change must be done inside the mix task directly

defmodule KlifeProtocol.Messages.ConsumerGroupHeartbeat do
  @moduledoc """
  Kafka protocol ConsumerGroupHeartbeat message

  Request versions summary:   
  - The ConsumerGroupHeartbeat API is added as part of KIP-848 and is still
  under developement. Hence, the API is not exposed by default by brokers
  unless explicitely enabled.

  Response versions summary:

  """

  alias KlifeProtocol.Deserializer
  alias KlifeProtocol.Serializer
  alias KlifeProtocol.Header

  @api_key 68
  @min_flexible_version_req 0
  @min_flexible_version_res 0

  @doc """
  Content fields:

  - group_id: The group identifier. (string | versions 0+)
  - member_id: The member id generated by the coordinator. The member id must be kept during the entire lifetime of the member. (string | versions 0+)
  - member_epoch: The current member epoch; 0 to join the group; -1 to leave the group; -2 to indicate that the static member will rejoin. (int32 | versions 0+)
  - instance_id: null if not provided or if it didn't change since the last heartbeat; the instance Id otherwise. (string | versions 0+)
  - rack_id: null if not provided or if it didn't change since the last heartbeat; the rack ID of consumer otherwise. (string | versions 0+)
  - rebalance_timeout_ms: -1 if it didn't chance since the last heartbeat; the maximum time in milliseconds that the coordinator will wait on the member to revoke its partitions otherwise. (int32 | versions 0+)
  - subscribed_topic_names: null if it didn't change since the last heartbeat; the subscribed topic names otherwise. ([]string | versions 0+)
  - subscribed_topic_regex: null if it didn't change since the last heartbeat; the subscribed topic regex otherwise (string | versions 0+)
  - server_assignor: null if not used or if it didn't change since the last heartbeat; the server side assignor to use otherwise. (string | versions 0+)
  - client_assignors: null if not used or if it didn't change since the last heartbeat; the list of client-side assignors otherwise. ([]Assignor | versions 0+)
      - name: The name of the assignor. (string | versions 0+)
      - minimum_version: The minimum supported version for the metadata. (int16 | versions 0+)
      - maximum_version: The maximum supported version for the metadata. (int16 | versions 0+)
      - reason: The reason of the metadata update. (int8 | versions 0+)
      - metadata_version: The version of the metadata. (int16 | versions 0+)
      - metadata_bytes: The metadata. (bytes | versions 0+)
  - topic_partitions: null if it didn't change since the last heartbeat; the partitions owned by the member. ([]TopicPartitions | versions 0+)
      - topic_id: The topic ID. (uuid | versions 0+)
      - partitions: The partitions. ([]int32 | versions 0+)

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

  - throttle_time_ms: The duration in milliseconds for which the request was throttled due to a quota violation, or zero if the request did not violate any quota. (int32 | versions 0+)
  - error_code: The top-level error code, or 0 if there was no error (int16 | versions 0+)
  - error_message: The top-level error message, or null if there was no error. (string | versions 0+)
  - member_id: The member id generated by the coordinator. Only provided when the member joins with MemberEpoch == 0. (string | versions 0+)
  - member_epoch: The member epoch. (int32 | versions 0+)
  - should_compute_assignment: True if the member should compute the assignment for the group. (bool | versions 0+)
  - heartbeat_interval_ms: The heartbeat interval in milliseconds. (int32 | versions 0+)
  - assignment: null if not provided; the assignment otherwise. (Assignment | versions 0+)
      - error: The assigned error. (int8 | versions 0+)
      - assigned_topic_partitions: The partitions assigned to the member that can be used immediately. ([]TopicPartitions | versions 0+)
          - topic_id: The topic ID. (uuid | versions 0+)
          - partitions: The partitions. ([]int32 | versions 0+)
      - pending_topic_partitions: The partitions assigned to the member that cannot be used because they are not released by their former owners yet. ([]TopicPartitions | versions 0+)
          - topic_id: The topic ID. (uuid | versions 0+)
          - partitions: The partitions. ([]int32 | versions 0+)
      - metadata_version: The version of the metadata. (int16 | versions 0+)
      - metadata_bytes: The assigned metadata. (bytes | versions 0+)

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

  def max_supported_version(), do: 0
  def min_supported_version(), do: 0

  defp req_header_version(msg_version),
    do: if(msg_version >= @min_flexible_version_req, do: 2, else: 1)

  defp res_header_version(msg_version),
    do: if(msg_version >= @min_flexible_version_res, do: 1, else: 0)

  defp request_schema(0),
    do: [
      group_id: {:compact_string, %{is_nullable?: false}},
      member_id: {:compact_string, %{is_nullable?: false}},
      member_epoch: {:int32, %{is_nullable?: false}},
      instance_id: {:compact_string, %{is_nullable?: true}},
      rack_id: {:compact_string, %{is_nullable?: true}},
      rebalance_timeout_ms: {:int32, %{is_nullable?: false}},
      subscribed_topic_names: {{:compact_array, :compact_string}, %{is_nullable?: true}},
      subscribed_topic_regex: {:compact_string, %{is_nullable?: true}},
      server_assignor: {:compact_string, %{is_nullable?: true}},
      client_assignors:
        {{:compact_array,
          [
            name: {:compact_string, %{is_nullable?: false}},
            minimum_version: {:int16, %{is_nullable?: false}},
            maximum_version: {:int16, %{is_nullable?: false}},
            reason: {:int8, %{is_nullable?: false}},
            metadata_version: {:int16, %{is_nullable?: false}},
            metadata_bytes: {:compact_bytes, %{is_nullable?: false}},
            tag_buffer: {:tag_buffer, []}
          ]}, %{is_nullable?: true}},
      topic_partitions:
        {{:compact_array,
          [
            topic_id: {:uuid, %{is_nullable?: false}},
            partitions: {{:compact_array, :int32}, %{is_nullable?: false}},
            tag_buffer: {:tag_buffer, []}
          ]}, %{is_nullable?: true}},
      tag_buffer: {:tag_buffer, []}
    ]

  defp request_schema(unkown_version),
    do: raise("Unknown version #{unkown_version} for message ConsumerGroupHeartbeat")

  defp response_schema(0),
    do: [
      throttle_time_ms: {:int32, %{is_nullable?: false}},
      error_code: {:int16, %{is_nullable?: false}},
      error_message: {:compact_string, %{is_nullable?: true}},
      member_id: {:compact_string, %{is_nullable?: true}},
      member_epoch: {:int32, %{is_nullable?: false}},
      should_compute_assignment: {:boolean, %{is_nullable?: false}},
      heartbeat_interval_ms: {:int32, %{is_nullable?: false}},
      assignment:
        {{:object,
          [
            error: {:int8, %{is_nullable?: false}},
            assigned_topic_partitions:
              {{:compact_array,
                [
                  topic_id: {:uuid, %{is_nullable?: false}},
                  partitions: {{:compact_array, :int32}, %{is_nullable?: false}},
                  tag_buffer: {:tag_buffer, %{}}
                ]}, %{is_nullable?: false}},
            pending_topic_partitions:
              {{:compact_array,
                [
                  topic_id: {:uuid, %{is_nullable?: false}},
                  partitions: {{:compact_array, :int32}, %{is_nullable?: false}},
                  tag_buffer: {:tag_buffer, %{}}
                ]}, %{is_nullable?: false}},
            metadata_version: {:int16, %{is_nullable?: false}},
            metadata_bytes: {:compact_bytes, %{is_nullable?: false}},
            tag_buffer: {:tag_buffer, %{}}
          ]}, %{is_nullable?: true}},
      tag_buffer: {:tag_buffer, %{}}
    ]

  defp response_schema(unkown_version),
    do: raise("Unknown version #{unkown_version} for message ConsumerGroupHeartbeat")
end