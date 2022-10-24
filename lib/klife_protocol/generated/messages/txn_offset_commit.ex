# DO NOT EDIT THIS FILE MANUALLY  
# This module is automatically generated by running mix task generate_file
# every change must be done inside the mix task directly

defmodule KlifeProtocol.Messages.TxnOffsetCommit do
  @moduledoc """
  Kafka protocol TxnOffsetCommit message

  Request versions summary:   
  - Version 1 is the same as version 0.
  - Version 2 adds the committed leader epoch.
  - Version 3 adds the member.id, group.instance.id and generation.id.

  Response versions summary:
  - Starting in version 1, on quota violation, brokers send out responses before throttling.
  - Version 2 is the same as version 1.
  - Version 3 adds illegal generation, fenced instance id, and unknown member id errors.

  """

  alias KlifeProtocol.Deserializer
  alias KlifeProtocol.Serializer
  alias KlifeProtocol.Header

  @api_key 28
  @min_flexible_version_req 3
  @min_flexible_version_res 3

  @doc """
  Content fields:

  - transactional_id: The ID of the transaction. (string | versions 0+)
  - group_id: The ID of the group. (string | versions 0+)
  - producer_id: The current producer ID in use by the transactional ID. (int64 | versions 0+)
  - producer_epoch: The current epoch associated with the producer ID. (int16 | versions 0+)
  - generation_id: The generation of the consumer. (int32 | versions 3+)
  - member_id: The member ID assigned by the group coordinator. (string | versions 3+)
  - group_instance_id: The unique identifier of the consumer instance provided by end user. (string | versions 3+)
  - topics: Each topic that we want to commit offsets for. ([]TxnOffsetCommitRequestTopic | versions 0+)
      - name: The topic name. (string | versions 0+)
      - partitions: The partitions inside the topic that we want to committ offsets for. ([]TxnOffsetCommitRequestPartition | versions 0+)
          - partition_index: The index of the partition within the topic. (int32 | versions 0+)
          - committed_offset: The message offset to be committed. (int64 | versions 0+)
          - committed_leader_epoch: The leader epoch of the last consumed record. (int32 | versions 2+)
          - committed_metadata: Any associated metadata the client wants to keep. (string | versions 0+)

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
  - topics: The responses for each topic. ([]TxnOffsetCommitResponseTopic | versions 0+)
      - name: The topic name. (string | versions 0+)
      - partitions: The responses for each partition in the topic. ([]TxnOffsetCommitResponsePartition | versions 0+)
          - partition_index: The partition index. (int32 | versions 0+)
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
      transactional_id: {:string, %{is_nullable?: false}},
      group_id: {:string, %{is_nullable?: false}},
      producer_id: {:int64, %{is_nullable?: false}},
      producer_epoch: {:int16, %{is_nullable?: false}},
      topics:
        {{:array,
          [
            name: {:string, %{is_nullable?: false}},
            partitions:
              {{:array,
                [
                  partition_index: {:int32, %{is_nullable?: false}},
                  committed_offset: {:int64, %{is_nullable?: false}},
                  committed_metadata: {:string, %{is_nullable?: true}}
                ]}, %{is_nullable?: false}}
          ]}, %{is_nullable?: false}}
    ]

  defp request_schema(1),
    do: [
      transactional_id: {:string, %{is_nullable?: false}},
      group_id: {:string, %{is_nullable?: false}},
      producer_id: {:int64, %{is_nullable?: false}},
      producer_epoch: {:int16, %{is_nullable?: false}},
      topics:
        {{:array,
          [
            name: {:string, %{is_nullable?: false}},
            partitions:
              {{:array,
                [
                  partition_index: {:int32, %{is_nullable?: false}},
                  committed_offset: {:int64, %{is_nullable?: false}},
                  committed_metadata: {:string, %{is_nullable?: true}}
                ]}, %{is_nullable?: false}}
          ]}, %{is_nullable?: false}}
    ]

  defp request_schema(2),
    do: [
      transactional_id: {:string, %{is_nullable?: false}},
      group_id: {:string, %{is_nullable?: false}},
      producer_id: {:int64, %{is_nullable?: false}},
      producer_epoch: {:int16, %{is_nullable?: false}},
      topics:
        {{:array,
          [
            name: {:string, %{is_nullable?: false}},
            partitions:
              {{:array,
                [
                  partition_index: {:int32, %{is_nullable?: false}},
                  committed_offset: {:int64, %{is_nullable?: false}},
                  committed_leader_epoch: {:int32, %{is_nullable?: false}},
                  committed_metadata: {:string, %{is_nullable?: true}}
                ]}, %{is_nullable?: false}}
          ]}, %{is_nullable?: false}}
    ]

  defp request_schema(3),
    do: [
      transactional_id: {:compact_string, %{is_nullable?: false}},
      group_id: {:compact_string, %{is_nullable?: false}},
      producer_id: {:int64, %{is_nullable?: false}},
      producer_epoch: {:int16, %{is_nullable?: false}},
      generation_id: {:int32, %{is_nullable?: false}},
      member_id: {:compact_string, %{is_nullable?: false}},
      group_instance_id: {:compact_string, %{is_nullable?: true}},
      topics:
        {{:compact_array,
          [
            name: {:compact_string, %{is_nullable?: false}},
            partitions:
              {{:compact_array,
                [
                  partition_index: {:int32, %{is_nullable?: false}},
                  committed_offset: {:int64, %{is_nullable?: false}},
                  committed_leader_epoch: {:int32, %{is_nullable?: false}},
                  committed_metadata: {:compact_string, %{is_nullable?: true}},
                  tag_buffer: {:tag_buffer, []}
                ]}, %{is_nullable?: false}},
            tag_buffer: {:tag_buffer, []}
          ]}, %{is_nullable?: false}},
      tag_buffer: {:tag_buffer, []}
    ]

  defp response_schema(0),
    do: [
      throttle_time_ms: {:int32, %{is_nullable?: false}},
      topics:
        {{:array,
          [
            name: {:string, %{is_nullable?: false}},
            partitions:
              {{:array,
                [
                  partition_index: {:int32, %{is_nullable?: false}},
                  error_code: {:int16, %{is_nullable?: false}}
                ]}, %{is_nullable?: false}}
          ]}, %{is_nullable?: false}}
    ]

  defp response_schema(1),
    do: [
      throttle_time_ms: {:int32, %{is_nullable?: false}},
      topics:
        {{:array,
          [
            name: {:string, %{is_nullable?: false}},
            partitions:
              {{:array,
                [
                  partition_index: {:int32, %{is_nullable?: false}},
                  error_code: {:int16, %{is_nullable?: false}}
                ]}, %{is_nullable?: false}}
          ]}, %{is_nullable?: false}}
    ]

  defp response_schema(2),
    do: [
      throttle_time_ms: {:int32, %{is_nullable?: false}},
      topics:
        {{:array,
          [
            name: {:string, %{is_nullable?: false}},
            partitions:
              {{:array,
                [
                  partition_index: {:int32, %{is_nullable?: false}},
                  error_code: {:int16, %{is_nullable?: false}}
                ]}, %{is_nullable?: false}}
          ]}, %{is_nullable?: false}}
    ]

  defp response_schema(3),
    do: [
      throttle_time_ms: {:int32, %{is_nullable?: false}},
      topics:
        {{:compact_array,
          [
            name: {:compact_string, %{is_nullable?: false}},
            partitions:
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
end