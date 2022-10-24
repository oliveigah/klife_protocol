# DO NOT EDIT THIS FILE MANUALLY  
# This module is automatically generated by running mix task generate_file
# every change must be done inside the mix task directly

defmodule KlifeProtocol.Messages.Vote do
  @moduledoc """
  Kafka protocol Vote message

  Request versions summary:   

  Response versions summary:

  """

  alias KlifeProtocol.Deserializer
  alias KlifeProtocol.Serializer
  alias KlifeProtocol.Header

  @api_key 52
  @min_flexible_version_req 0
  @min_flexible_version_res 0

  @doc """
  Content fields:

  - cluster_id:  (string | versions 0+)
  - topics:  ([]TopicData | versions 0+)
      - topic_name: The topic name. (string | versions 0+)
      - partitions:  ([]PartitionData | versions 0+)
          - partition_index: The partition index. (int32 | versions 0+)
          - candidate_epoch: The bumped epoch of the candidate sending the request (int32 | versions 0+)
          - candidate_id: The ID of the voter sending the request (int32 | versions 0+)
          - last_offset_epoch: The epoch of the last record written to the metadata log (int32 | versions 0+)
          - last_offset: The offset of the last record written to the metadata log (int64 | versions 0+)

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
          - vote_granted: True if the vote was granted and false otherwise (bool | versions 0+)

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
      cluster_id: {:compact_string, %{is_nullable?: true}},
      topics:
        {{:compact_array,
          [
            topic_name: {:compact_string, %{is_nullable?: false}},
            partitions:
              {{:compact_array,
                [
                  partition_index: {:int32, %{is_nullable?: false}},
                  candidate_epoch: {:int32, %{is_nullable?: false}},
                  candidate_id: {:int32, %{is_nullable?: false}},
                  last_offset_epoch: {:int32, %{is_nullable?: false}},
                  last_offset: {:int64, %{is_nullable?: false}},
                  tag_buffer: {:tag_buffer, []}
                ]}, %{is_nullable?: false}},
            tag_buffer: {:tag_buffer, []}
          ]}, %{is_nullable?: false}},
      tag_buffer: {:tag_buffer, []}
    ]

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
                  vote_granted: {:boolean, %{is_nullable?: false}},
                  tag_buffer: {:tag_buffer, %{}}
                ]}, %{is_nullable?: false}},
            tag_buffer: {:tag_buffer, %{}}
          ]}, %{is_nullable?: false}},
      tag_buffer: {:tag_buffer, %{}}
    ]
end