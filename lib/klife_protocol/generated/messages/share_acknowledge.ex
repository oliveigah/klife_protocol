# DO NOT EDIT THIS FILE MANUALLY
# This module is automatically generated by running mix task generate_file
# every change must be done inside the mix task directly

defmodule KlifeProtocol.Messages.ShareAcknowledge do
  @moduledoc """
  Kafka protocol ShareAcknowledge message

  Request versions summary:

  Response versions summary:

  """

  alias KlifeProtocol.Deserializer
  alias KlifeProtocol.Serializer
  alias KlifeProtocol.Header

  @api_key 79
  @min_flexible_version_req 0
  @min_flexible_version_res 0

  @doc """
  Receives a map and serialize it to kafka wire format of the given version.

  Input content fields:
  - group_id: The group identifier. (string | versions 0+)
  - member_id: The member ID. (string | versions 0+)
  - share_session_epoch: The current share session epoch: 0 to open a share session; -1 to close it; otherwise increments for consecutive requests. (int32 | versions 0+)
  - topics: The topics containing records to acknowledge. ([]AcknowledgeTopic | versions 0+)
      - topic_id: The unique topic ID. (uuid | versions 0+)
      - partitions: The partitions containing records to acknowledge. ([]AcknowledgePartition | versions 0+)
          - partition_index: The partition index. (int32 | versions 0+)
          - acknowledgement_batches: Record batches to acknowledge. ([]AcknowledgementBatch | versions 0+)
              - first_offset: First offset of batch of records to acknowledge. (int64 | versions 0+)
              - last_offset: Last offset (inclusive) of batch of records to acknowledge. (int64 | versions 0+)
              - acknowledge_types: Array of acknowledge types - 0:Gap,1:Accept,2:Release,3:Reject. ([]int8 | versions 0+)

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

  - throttle_time_ms: The duration in milliseconds for which the request was throttled due to a quota violation, or zero if the request did not violate any quota. (int32 | versions 0+)
  - error_code: The top level response error code. (int16 | versions 0+)
  - error_message: The top-level error message, or null if there was no error. (string | versions 0+)
  - responses: The response topics. ([]ShareAcknowledgeTopicResponse | versions 0+)
      - topic_id: The unique topic ID. (uuid | versions 0+)
      - partitions: The topic partitions. ([]PartitionData | versions 0+)
          - partition_index: The partition index. (int32 | versions 0+)
          - error_code: The error code, or 0 if there was no error. (int16 | versions 0+)
          - error_message: The error message, or null if there was no error. (string | versions 0+)
          - current_leader: The current leader of the partition. (LeaderIdAndEpoch | versions 0+)
              - leader_id: The ID of the current leader or -1 if the leader is unknown. (int32 | versions 0+)
              - leader_epoch: The latest known leader epoch. (int32 | versions 0+)
  - node_endpoints: Endpoints for all current leaders enumerated in PartitionData with error NOT_LEADER_OR_FOLLOWER. ([]NodeEndpoint | versions 0+)
      - node_id: The ID of the associated node. (int32 | versions 0+)
      - host: The node's hostname. (string | versions 0+)
      - port: The node's port. (int32 | versions 0+)
      - rack: The rack of the node, or null if it has not been assigned to a rack. (string | versions 0+)

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
  def max_supported_version(), do: 0

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
      group_id: {:compact_string, %{is_nullable?: true}},
      member_id: {:compact_string, %{is_nullable?: true}},
      share_session_epoch: {:int32, %{is_nullable?: false}},
      topics:
        {{:compact_array,
          [
            topic_id: {:uuid, %{is_nullable?: false}},
            partitions:
              {{:compact_array,
                [
                  partition_index: {:int32, %{is_nullable?: false}},
                  acknowledgement_batches:
                    {{:compact_array,
                      [
                        first_offset: {:int64, %{is_nullable?: false}},
                        last_offset: {:int64, %{is_nullable?: false}},
                        acknowledge_types: {{:compact_array, :int8}, %{is_nullable?: false}},
                        tag_buffer: {:tag_buffer, []}
                      ]}, %{is_nullable?: false}},
                  tag_buffer: {:tag_buffer, []}
                ]}, %{is_nullable?: false}},
            tag_buffer: {:tag_buffer, []}
          ]}, %{is_nullable?: false}},
      tag_buffer: {:tag_buffer, []}
    ]

  def request_schema(unkown_version),
    do: raise("Unknown version #{unkown_version} for message ShareAcknowledge")

  def response_schema(0),
    do: [
      throttle_time_ms: {:int32, %{is_nullable?: false}},
      error_code: {:int16, %{is_nullable?: false}},
      error_message: {:compact_string, %{is_nullable?: true}},
      responses:
        {{:compact_array,
          [
            topic_id: {:uuid, %{is_nullable?: false}},
            partitions:
              {{:compact_array,
                [
                  partition_index: {:int32, %{is_nullable?: false}},
                  error_code: {:int16, %{is_nullable?: false}},
                  error_message: {:compact_string, %{is_nullable?: true}},
                  current_leader:
                    {{:object,
                      [
                        leader_id: {:int32, %{is_nullable?: false}},
                        leader_epoch: {:int32, %{is_nullable?: false}},
                        tag_buffer: {:tag_buffer, %{}}
                      ]}, %{is_nullable?: false}},
                  tag_buffer: {:tag_buffer, %{}}
                ]}, %{is_nullable?: false}},
            tag_buffer: {:tag_buffer, %{}}
          ]}, %{is_nullable?: false}},
      node_endpoints:
        {{:compact_array,
          [
            node_id: {:int32, %{is_nullable?: false}},
            host: {:compact_string, %{is_nullable?: false}},
            port: {:int32, %{is_nullable?: false}},
            rack: {:compact_string, %{is_nullable?: true}},
            tag_buffer: {:tag_buffer, %{}}
          ]}, %{is_nullable?: false}},
      tag_buffer: {:tag_buffer, %{}}
    ]

  def response_schema(unkown_version),
    do: raise("Unknown version #{unkown_version} for message ShareAcknowledge")
end
