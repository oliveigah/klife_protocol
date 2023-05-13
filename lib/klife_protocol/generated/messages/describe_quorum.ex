# DO NOT EDIT THIS FILE MANUALLY  
# This module is automatically generated by running mix task generate_file
# every change must be done inside the mix task directly

defmodule KlifeProtocol.Messages.DescribeQuorum do
  @moduledoc """
  Kafka protocol DescribeQuorum message

  Request versions summary:   
  - Version 1 adds additional fields in the response. The request is unchanged (KIP-836).

  Response versions summary:
  - Version 1 adds LastFetchTimeStamp and LastCaughtUpTimestamp in ReplicaState (KIP-836).

  """

  alias KlifeProtocol.Deserializer
  alias KlifeProtocol.Serializer
  alias KlifeProtocol.Header

  @api_key 55
  @min_flexible_version_req 0
  @min_flexible_version_res 0

  @doc """
  Content fields:

  - topics:  ([]TopicData | versions 0+)
      - topic_name: The topic name. (string | versions 0+)
      - partitions:  ([]PartitionData | versions 0+)
          - partition_index: The partition index. (int32 | versions 0+)

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

  - error_code: The top level error code. (int16 | versions 0+)
  - topics:  ([]TopicData | versions 0+)
      - topic_name: The topic name. (string | versions 0+)
      - partitions:  ([]PartitionData | versions 0+)
          - partition_index: The partition index. (int32 | versions 0+)
          - error_code:  (int16 | versions 0+)
          - leader_id: The ID of the current leader or -1 if the leader is unknown. (int32 | versions 0+)
          - leader_epoch: The latest known leader epoch (int32 | versions 0+)
          - high_watermark:  (int64 | versions 0+)
          - current_voters:  ([]ReplicaState | versions 0+)
              - replica_id:  (int32 | versions 0+)
              - log_end_offset: The last known log end offset of the follower or -1 if it is unknown (int64 | versions 0+)
              - last_fetch_timestamp: The last known leader wall clock time time when a follower fetched from the leader. This is reported as -1 both for the current leader or if it is unknown for a voter (int64 | versions 1+)
              - last_caught_up_timestamp: The leader wall clock append time of the offset for which the follower made the most recent fetch request. This is reported as the current time for the leader and -1 if unknown for a voter (int64 | versions 1+)
          - observers:  ([]ReplicaState | versions 0+)
              - replica_id:  (int32 | versions 0+)
              - log_end_offset: The last known log end offset of the follower or -1 if it is unknown (int64 | versions 0+)
              - last_fetch_timestamp: The last known leader wall clock time time when a follower fetched from the leader. This is reported as -1 both for the current leader or if it is unknown for a voter (int64 | versions 1+)
              - last_caught_up_timestamp: The leader wall clock append time of the offset for which the follower made the most recent fetch request. This is reported as the current time for the leader and -1 if unknown for a voter (int64 | versions 1+)

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

  def max_supported_version(), do: 1
  def min_supported_version(), do: 0

  defp req_header_version(msg_version),
    do: if(msg_version >= @min_flexible_version_req, do: 2, else: 1)

  defp res_header_version(msg_version),
    do: if(msg_version >= @min_flexible_version_res, do: 1, else: 0)

  defp request_schema(0),
    do: [
      topics:
        {{:compact_array,
          [
            topic_name: {:compact_string, %{is_nullable?: false}},
            partitions:
              {{:compact_array,
                [partition_index: {:int32, %{is_nullable?: false}}, tag_buffer: {:tag_buffer, []}]},
               %{is_nullable?: false}},
            tag_buffer: {:tag_buffer, []}
          ]}, %{is_nullable?: false}},
      tag_buffer: {:tag_buffer, []}
    ]

  defp request_schema(1),
    do: [
      topics:
        {{:compact_array,
          [
            topic_name: {:compact_string, %{is_nullable?: false}},
            partitions:
              {{:compact_array,
                [partition_index: {:int32, %{is_nullable?: false}}, tag_buffer: {:tag_buffer, []}]},
               %{is_nullable?: false}},
            tag_buffer: {:tag_buffer, []}
          ]}, %{is_nullable?: false}},
      tag_buffer: {:tag_buffer, []}
    ]

  defp request_schema(unkown_version),
    do: raise("Unknown version #{unkown_version} for message DescribeQuorum")

  defp response_schema(0),
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
                  high_watermark: {:int64, %{is_nullable?: false}},
                  current_voters:
                    {{:compact_array,
                      [
                        replica_id: {:int32, %{is_nullable?: false}},
                        log_end_offset: {:int64, %{is_nullable?: false}},
                        tag_buffer: {:tag_buffer, %{}}
                      ]}, %{is_nullable?: false}},
                  observers:
                    {{:compact_array,
                      [
                        replica_id: {:int32, %{is_nullable?: false}},
                        log_end_offset: {:int64, %{is_nullable?: false}},
                        tag_buffer: {:tag_buffer, %{}}
                      ]}, %{is_nullable?: false}},
                  tag_buffer: {:tag_buffer, %{}}
                ]}, %{is_nullable?: false}},
            tag_buffer: {:tag_buffer, %{}}
          ]}, %{is_nullable?: false}},
      tag_buffer: {:tag_buffer, %{}}
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
                  high_watermark: {:int64, %{is_nullable?: false}},
                  current_voters:
                    {{:compact_array,
                      [
                        replica_id: {:int32, %{is_nullable?: false}},
                        log_end_offset: {:int64, %{is_nullable?: false}},
                        last_fetch_timestamp: {:int64, %{is_nullable?: false}},
                        last_caught_up_timestamp: {:int64, %{is_nullable?: false}},
                        tag_buffer: {:tag_buffer, %{}}
                      ]}, %{is_nullable?: false}},
                  observers:
                    {{:compact_array,
                      [
                        replica_id: {:int32, %{is_nullable?: false}},
                        log_end_offset: {:int64, %{is_nullable?: false}},
                        last_fetch_timestamp: {:int64, %{is_nullable?: false}},
                        last_caught_up_timestamp: {:int64, %{is_nullable?: false}},
                        tag_buffer: {:tag_buffer, %{}}
                      ]}, %{is_nullable?: false}},
                  tag_buffer: {:tag_buffer, %{}}
                ]}, %{is_nullable?: false}},
            tag_buffer: {:tag_buffer, %{}}
          ]}, %{is_nullable?: false}},
      tag_buffer: {:tag_buffer, %{}}
    ]

  defp response_schema(unkown_version),
    do: raise("Unknown version #{unkown_version} for message DescribeQuorum")
end