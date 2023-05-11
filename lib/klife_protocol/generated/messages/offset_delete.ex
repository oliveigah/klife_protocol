# DO NOT EDIT THIS FILE MANUALLY  
# This module is automatically generated by running mix task generate_file
# every change must be done inside the mix task directly

defmodule KlifeProtocol.Messages.OffsetDelete do
  @moduledoc """
  Kafka protocol OffsetDelete message

  Request versions summary:   

  Response versions summary:

  """

  alias KlifeProtocol.Deserializer
  alias KlifeProtocol.Serializer
  alias KlifeProtocol.Header

  @api_key 47
  @min_flexible_version_req :none
  @min_flexible_version_res :none

  @doc """
  Content fields:

  - group_id: The unique group identifier. (string | versions 0+)
  - topics: The topics to delete offsets for ([]OffsetDeleteRequestTopic | versions 0+)
      - name: The topic name. (string | versions 0+)
      - partitions: Each partition to delete offsets for. ([]OffsetDeleteRequestPartition | versions 0+)
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

  - error_code: The top-level error code, or 0 if there was no error. (int16 | versions 0+)
  - throttle_time_ms: The duration in milliseconds for which the request was throttled due to a quota violation, or zero if the request did not violate any quota. (int32 | versions 0+)
  - topics: The responses for each topic. ([]OffsetDeleteResponseTopic | versions 0+)
      - name: The topic name. (string | versions 0+)
      - partitions: The responses for each partition in the topic. ([]OffsetDeleteResponsePartition | versions 0+)
          - partition_index: The partition index. (int32 | versions 0+)
          - error_code: The error code, or 0 if there was no error. (int16 | versions 0+)

  """
  def deserialize_response(data, version) do
    {headers, rest_data} = Header.deserialize_response(data, res_header_version(version))

    case Deserializer.execute(rest_data, response_schema(version)) do
      {content, <<>>} ->
        %{headers: headers, content: content}

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
      group_id: {:string, %{is_nullable?: false}},
      topics:
        {{:array,
          [
            name: {:string, %{is_nullable?: false}},
            partitions:
              {{:array, [partition_index: {:int32, %{is_nullable?: false}}]},
               %{is_nullable?: false}}
          ]}, %{is_nullable?: false}}
    ]

  defp request_schema(unkown_version),
    do: raise("Unknown version #{unkown_version} for message OffsetDelete")

  defp response_schema(0),
    do: [
      error_code: {:int16, %{is_nullable?: false}},
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

  defp response_schema(unkown_version),
    do: raise("Unknown version #{unkown_version} for message OffsetDelete")
end