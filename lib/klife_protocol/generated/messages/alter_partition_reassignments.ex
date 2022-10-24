# DO NOT EDIT THIS FILE MANUALLY  
# This module is automatically generated by running mix task generate_file
# every change must be done inside the mix task directly

defmodule KlifeProtocol.Messages.AlterPartitionReassignments do
  @moduledoc """
  Kafka protocol AlterPartitionReassignments message

  Request versions summary:   

  Response versions summary:

  """

  alias KlifeProtocol.Deserializer
  alias KlifeProtocol.Serializer
  alias KlifeProtocol.Header

  @api_key 45
  @min_flexible_version_req 0
  @min_flexible_version_res 0

  @doc """
  Content fields:

  - timeout_ms: The time in ms to wait for the request to complete. (int32 | versions 0+)
  - topics: The topics to reassign. ([]ReassignableTopic | versions 0+)
      - name: The topic name. (string | versions 0+)
      - partitions: The partitions to reassign. ([]ReassignablePartition | versions 0+)
          - partition_index: The partition index. (int32 | versions 0+)
          - replicas: The replicas to place the partitions on, or null to cancel a pending reassignment for this partition. ([]int32 | versions 0+)

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
  - error_code: The top-level error code, or 0 if there was no error. (int16 | versions 0+)
  - error_message: The top-level error message, or null if there was no error. (string | versions 0+)
  - responses: The responses to topics to reassign. ([]ReassignableTopicResponse | versions 0+)
      - name: The topic name (string | versions 0+)
      - partitions: The responses to partitions to reassign ([]ReassignablePartitionResponse | versions 0+)
          - partition_index: The partition index. (int32 | versions 0+)
          - error_code: The error code for this partition, or 0 if there was no error. (int16 | versions 0+)
          - error_message: The error message for this partition, or null if there was no error. (string | versions 0+)

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
      timeout_ms: {:int32, %{is_nullable?: false}},
      topics:
        {{:compact_array,
          [
            name: {:compact_string, %{is_nullable?: false}},
            partitions:
              {{:compact_array,
                [
                  partition_index: {:int32, %{is_nullable?: false}},
                  replicas: {{:compact_array, :int32}, %{is_nullable?: true}},
                  tag_buffer: {:tag_buffer, []}
                ]}, %{is_nullable?: false}},
            tag_buffer: {:tag_buffer, []}
          ]}, %{is_nullable?: false}},
      tag_buffer: {:tag_buffer, []}
    ]

  defp response_schema(0),
    do: [
      throttle_time_ms: {:int32, %{is_nullable?: false}},
      error_code: {:int16, %{is_nullable?: false}},
      error_message: {:compact_string, %{is_nullable?: true}},
      responses:
        {{:compact_array,
          [
            name: {:compact_string, %{is_nullable?: false}},
            partitions:
              {{:compact_array,
                [
                  partition_index: {:int32, %{is_nullable?: false}},
                  error_code: {:int16, %{is_nullable?: false}},
                  error_message: {:compact_string, %{is_nullable?: true}},
                  tag_buffer: {:tag_buffer, %{}}
                ]}, %{is_nullable?: false}},
            tag_buffer: {:tag_buffer, %{}}
          ]}, %{is_nullable?: false}},
      tag_buffer: {:tag_buffer, %{}}
    ]
end