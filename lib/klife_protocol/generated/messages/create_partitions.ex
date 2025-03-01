# DO NOT EDIT THIS FILE MANUALLY
# This module is automatically generated by running mix task generate_file
# every change must be done inside the mix task directly

defmodule KlifeProtocol.Messages.CreatePartitions do
  @moduledoc """
  Kafka protocol CreatePartitions message

  Request versions summary:
  - Version 1 is the same as version 0.
  - Version 2 adds flexible version support
  - Version 3 is identical to version 2 but may return a THROTTLING_QUOTA_EXCEEDED error
  in the response if the partitions creation is throttled (KIP-599).

  Response versions summary:
  - Starting in version 1, on quota violation, brokers send out responses before throttling.
  - Version 2 adds flexible version support
  - Version 3 is identical to version 2 but may return a THROTTLING_QUOTA_EXCEEDED error
  in the response if the partitions creation is throttled (KIP-599).

  """

  alias KlifeProtocol.Deserializer
  alias KlifeProtocol.Serializer
  alias KlifeProtocol.Header

  @api_key 37
  @min_flexible_version_req 2
  @min_flexible_version_res 2

  @doc """
  Receives a map and serialize it to kafka wire format of the given version.

  Input content fields:
  - topics: Each topic that we want to create new partitions inside. ([]CreatePartitionsTopic | versions 0+)
      - name: The topic name. (string | versions 0+)
      - count: The new partition count. (int32 | versions 0+)
      - assignments: The new partition assignments. ([]CreatePartitionsAssignment | versions 0+)
          - broker_ids: The assigned broker IDs. ([]int32 | versions 0+)
  - timeout_ms: The time in ms to wait for the partitions to be created. (int32 | versions 0+)
  - validate_only: If true, then validate the request, but don't actually increase the number of partitions. (bool | versions 0+)

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
  - results: The partition creation results for each topic. ([]CreatePartitionsTopicResult | versions 0+)
      - name: The topic name. (string | versions 0+)
      - error_code: The result error, or zero if there was no error. (int16 | versions 0+)
      - error_message: The result message, or null if there was no error. (string | versions 0+)

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
  def max_supported_version(), do: 3

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
      topics:
        {{:array,
          [
            name: {:string, %{is_nullable?: false}},
            count: {:int32, %{is_nullable?: false}},
            assignments:
              {{:array, [broker_ids: {{:array, :int32}, %{is_nullable?: false}}]},
               %{is_nullable?: true}}
          ]}, %{is_nullable?: false}},
      timeout_ms: {:int32, %{is_nullable?: false}},
      validate_only: {:boolean, %{is_nullable?: false}}
    ]

  def request_schema(1),
    do: [
      topics:
        {{:array,
          [
            name: {:string, %{is_nullable?: false}},
            count: {:int32, %{is_nullable?: false}},
            assignments:
              {{:array, [broker_ids: {{:array, :int32}, %{is_nullable?: false}}]},
               %{is_nullable?: true}}
          ]}, %{is_nullable?: false}},
      timeout_ms: {:int32, %{is_nullable?: false}},
      validate_only: {:boolean, %{is_nullable?: false}}
    ]

  def request_schema(2),
    do: [
      topics:
        {{:compact_array,
          [
            name: {:compact_string, %{is_nullable?: false}},
            count: {:int32, %{is_nullable?: false}},
            assignments:
              {{:compact_array,
                [
                  broker_ids: {{:compact_array, :int32}, %{is_nullable?: false}},
                  tag_buffer: {:tag_buffer, []}
                ]}, %{is_nullable?: true}},
            tag_buffer: {:tag_buffer, []}
          ]}, %{is_nullable?: false}},
      timeout_ms: {:int32, %{is_nullable?: false}},
      validate_only: {:boolean, %{is_nullable?: false}},
      tag_buffer: {:tag_buffer, []}
    ]

  def request_schema(3),
    do: [
      topics:
        {{:compact_array,
          [
            name: {:compact_string, %{is_nullable?: false}},
            count: {:int32, %{is_nullable?: false}},
            assignments:
              {{:compact_array,
                [
                  broker_ids: {{:compact_array, :int32}, %{is_nullable?: false}},
                  tag_buffer: {:tag_buffer, []}
                ]}, %{is_nullable?: true}},
            tag_buffer: {:tag_buffer, []}
          ]}, %{is_nullable?: false}},
      timeout_ms: {:int32, %{is_nullable?: false}},
      validate_only: {:boolean, %{is_nullable?: false}},
      tag_buffer: {:tag_buffer, []}
    ]

  def request_schema(unkown_version),
    do: raise("Unknown version #{unkown_version} for message CreatePartitions")

  def response_schema(0),
    do: [
      throttle_time_ms: {:int32, %{is_nullable?: false}},
      results:
        {{:array,
          [
            name: {:string, %{is_nullable?: false}},
            error_code: {:int16, %{is_nullable?: false}},
            error_message: {:string, %{is_nullable?: true}}
          ]}, %{is_nullable?: false}}
    ]

  def response_schema(1),
    do: [
      throttle_time_ms: {:int32, %{is_nullable?: false}},
      results:
        {{:array,
          [
            name: {:string, %{is_nullable?: false}},
            error_code: {:int16, %{is_nullable?: false}},
            error_message: {:string, %{is_nullable?: true}}
          ]}, %{is_nullable?: false}}
    ]

  def response_schema(2),
    do: [
      throttle_time_ms: {:int32, %{is_nullable?: false}},
      results:
        {{:compact_array,
          [
            name: {:compact_string, %{is_nullable?: false}},
            error_code: {:int16, %{is_nullable?: false}},
            error_message: {:compact_string, %{is_nullable?: true}},
            tag_buffer: {:tag_buffer, %{}}
          ]}, %{is_nullable?: false}},
      tag_buffer: {:tag_buffer, %{}}
    ]

  def response_schema(3),
    do: [
      throttle_time_ms: {:int32, %{is_nullable?: false}},
      results:
        {{:compact_array,
          [
            name: {:compact_string, %{is_nullable?: false}},
            error_code: {:int16, %{is_nullable?: false}},
            error_message: {:compact_string, %{is_nullable?: true}},
            tag_buffer: {:tag_buffer, %{}}
          ]}, %{is_nullable?: false}},
      tag_buffer: {:tag_buffer, %{}}
    ]

  def response_schema(unkown_version),
    do: raise("Unknown version #{unkown_version} for message CreatePartitions")
end
