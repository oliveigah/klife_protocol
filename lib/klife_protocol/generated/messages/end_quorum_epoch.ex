# DO NOT EDIT THIS FILE MANUALLY
# This module is automatically generated by running mix task generate_file
# every change must be done inside the mix task directly

defmodule KlifeProtocol.Messages.EndQuorumEpoch do
  @moduledoc """
  Kafka protocol EndQuorumEpoch message

  Request versions summary:
  - Version 1 adds flexible versions, replaces preferred successors with preferred candidates
  and adds leader endpoints (KIP-853)

  Response versions summary:
  - Version 1 adds flexible versions and leader endpoint (KIP-853)

  """

  alias KlifeProtocol.Deserializer
  alias KlifeProtocol.Serializer
  alias KlifeProtocol.Header

  @api_key 54
  @min_flexible_version_req 1
  @min_flexible_version_res 1

  @doc """
  Receives a map and serialize it to kafka wire format of the given version.

  Input content fields:
  - cluster_id:  (string | versions 0+)
  - topics:  ([]TopicData | versions 0+)
      - topic_name: The topic name. (string | versions 0+)
      - partitions:  ([]PartitionData | versions 0+)
          - partition_index: The partition index. (int32 | versions 0+)
          - leader_id: The current leader ID that is resigning (int32 | versions 0+)
          - leader_epoch: The current epoch (int32 | versions 0+)
          - preferred_successors: A sorted list of preferred successors to start the election ([]int32 | versions 0)
          - preferred_candidates: A sorted list of preferred candidates to start the election ([]ReplicaInfo | versions 1+)
              - candidate_id:  (int32 | versions 1+)
              - candidate_directory_id:  (uuid | versions 1+)
  - leader_endpoints: Endpoints for the leader ([]LeaderEndpoint | versions 1+)
      - name: The name of the endpoint (string | versions 1+)
      - host: The node's hostname (string | versions 1+)
      - port: The node's port (uint16 | versions 1+)

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

  - error_code: The top level error code. (int16 | versions 0+)
  - topics:  ([]TopicData | versions 0+)
      - topic_name: The topic name. (string | versions 0+)
      - partitions:  ([]PartitionData | versions 0+)
          - partition_index: The partition index. (int32 | versions 0+)
          - error_code:  (int16 | versions 0+)
          - leader_id: The ID of the current leader or -1 if the leader is unknown. (int32 | versions 0+)
          - leader_epoch: The latest known leader epoch (int32 | versions 0+)
  - node_endpoints: Endpoints for all leaders enumerated in PartitionData ([]NodeEndpoint | versions 1+)
      - node_id: The ID of the associated node (int32 | versions 1+)
      - host: The node's hostname (string | versions 1+)
      - port: The node's port (uint16 | versions 1+)

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
  def max_supported_version(), do: 1

  @doc """
  Returns the current min supported version of this message.
  """
  def min_supported_version(), do: 0

  defp req_header_version(msg_version),
    do: if(msg_version >= @min_flexible_version_req, do: 2, else: 1)

  defp res_header_version(msg_version),
    do: if(msg_version >= @min_flexible_version_res, do: 1, else: 0)

  defp request_schema(0),
    do: [
      cluster_id: {:string, %{is_nullable?: true}},
      topics:
        {{:array,
          [
            topic_name: {:string, %{is_nullable?: false}},
            partitions:
              {{:array,
                [
                  partition_index: {:int32, %{is_nullable?: false}},
                  leader_id: {:int32, %{is_nullable?: false}},
                  leader_epoch: {:int32, %{is_nullable?: false}},
                  preferred_successors: {{:array, :int32}, %{is_nullable?: false}}
                ]}, %{is_nullable?: false}}
          ]}, %{is_nullable?: false}}
    ]

  defp request_schema(1),
    do: [
      cluster_id: {:compact_string, %{is_nullable?: true}},
      topics:
        {{:compact_array,
          [
            topic_name: {:compact_string, %{is_nullable?: false}},
            partitions:
              {{:compact_array,
                [
                  partition_index: {:int32, %{is_nullable?: false}},
                  leader_id: {:int32, %{is_nullable?: false}},
                  leader_epoch: {:int32, %{is_nullable?: false}},
                  preferred_candidates:
                    {{:compact_array,
                      [
                        candidate_id: {:int32, %{is_nullable?: false}},
                        candidate_directory_id: {:uuid, %{is_nullable?: false}},
                        tag_buffer: {:tag_buffer, []}
                      ]}, %{is_nullable?: false}},
                  tag_buffer: {:tag_buffer, []}
                ]}, %{is_nullable?: false}},
            tag_buffer: {:tag_buffer, []}
          ]}, %{is_nullable?: false}},
      leader_endpoints:
        {{:compact_array,
          [
            name: {:compact_string, %{is_nullable?: false}},
            host: {:compact_string, %{is_nullable?: false}},
            port: {:uint16, %{is_nullable?: false}},
            tag_buffer: {:tag_buffer, []}
          ]}, %{is_nullable?: false}},
      tag_buffer: {:tag_buffer, []}
    ]

  defp request_schema(unkown_version),
    do: raise("Unknown version #{unkown_version} for message EndQuorumEpoch")

  defp response_schema(0),
    do: [
      error_code: {:int16, %{is_nullable?: false}},
      topics:
        {{:array,
          [
            topic_name: {:string, %{is_nullable?: false}},
            partitions:
              {{:array,
                [
                  partition_index: {:int32, %{is_nullable?: false}},
                  error_code: {:int16, %{is_nullable?: false}},
                  leader_id: {:int32, %{is_nullable?: false}},
                  leader_epoch: {:int32, %{is_nullable?: false}}
                ]}, %{is_nullable?: false}}
          ]}, %{is_nullable?: false}}
    ]

  defp response_schema(1),
    do: [
      error_code: {:int16, %{is_nullable?: false}},
      topics:
        {{:compact_array,
          [
            topic_name: {:compact_string, %{is_nullable?: false}},
            partitions:
              {{:compact_array,
                [
                  partition_index: {:int32, %{is_nullable?: false}},
                  error_code: {:int16, %{is_nullable?: false}},
                  leader_id: {:int32, %{is_nullable?: false}},
                  leader_epoch: {:int32, %{is_nullable?: false}},
                  tag_buffer: {:tag_buffer, %{}}
                ]}, %{is_nullable?: false}},
            tag_buffer: {:tag_buffer, %{}}
          ]}, %{is_nullable?: false}},
      tag_buffer:
        {:tag_buffer,
         %{
           0 =>
             {{:node_endpoints,
               {:compact_array,
                [
                  node_id: {:int32, %{is_nullable?: false}},
                  host: {:compact_string, %{is_nullable?: false}},
                  port: {:uint16, %{is_nullable?: false}},
                  tag_buffer: {:tag_buffer, %{}}
                ]}}, %{is_nullable?: false}}
         }}
    ]

  defp response_schema(unkown_version),
    do: raise("Unknown version #{unkown_version} for message EndQuorumEpoch")
end