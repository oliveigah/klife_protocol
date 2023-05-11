# DO NOT EDIT THIS FILE MANUALLY  
# This module is automatically generated by running mix task generate_file
# every change must be done inside the mix task directly

defmodule KlifeProtocol.Messages.CreateTopics do
  @moduledoc """
  Kafka protocol CreateTopics message

  Request versions summary:   
  - Version 1 adds validateOnly.
  - Version 4 makes partitions/replicationFactor optional even when assignments are not present (KIP-464)
  - Version 5 is the first flexible version.
  Version 5 also returns topic configs in the response (KIP-525).
  - Version 6 is identical to version 5 but may return a THROTTLING_QUOTA_EXCEEDED error
  in the response if the topics creation is throttled (KIP-599).
  - Version 7 is the same as version 6.

  Response versions summary:
  - Version 1 adds a per-topic error message string.
  - Version 2 adds the throttle time.
  - Starting in version 3, on quota violation, brokers send out responses before throttling.
  - Version 4 makes partitions/replicationFactor optional even when assignments are not present (KIP-464).
  - Version 5 is the first flexible version.
  Version 5 also returns topic configs in the response (KIP-525).
  - Version 6 is identical to version 5 but may return a THROTTLING_QUOTA_EXCEEDED error
  in the response if the topics creation is throttled (KIP-599).
  - Version 7 returns the topic ID of the newly created topic if creation is sucessful.

  """

  alias KlifeProtocol.Deserializer
  alias KlifeProtocol.Serializer
  alias KlifeProtocol.Header

  @api_key 19
  @min_flexible_version_req 5
  @min_flexible_version_res 5

  @doc """
  Content fields:

  - topics: The topics to create. ([]CreatableTopic | versions 0+)
      - name: The topic name. (string | versions 0+)
      - num_partitions: The number of partitions to create in the topic, or -1 if we are either specifying a manual partition assignment or using the default partitions. (int32 | versions 0+)
      - replication_factor: The number of replicas to create for each partition in the topic, or -1 if we are either specifying a manual partition assignment or using the default replication factor. (int16 | versions 0+)
      - assignments: The manual partition assignment, or the empty array if we are using automatic assignment. ([]CreatableReplicaAssignment | versions 0+)
          - partition_index: The partition index. (int32 | versions 0+)
          - broker_ids: The brokers to place the partition on. ([]int32 | versions 0+)
      - configs: The custom topic configurations to set. ([]CreateableTopicConfig | versions 0+)
          - name: The configuration name. (string | versions 0+)
          - value: The configuration value. (string | versions 0+)
  - timeout_ms: How long to wait in milliseconds before timing out the request. (int32 | versions 0+)
  - validate_only: If true, check that the topics can be created as specified, but don't create anything. (bool | versions 1+)

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

  - throttle_time_ms: The duration in milliseconds for which the request was throttled due to a quota violation, or zero if the request did not violate any quota. (int32 | versions 2+)
  - topics: Results for each topic we tried to create. ([]CreatableTopicResult | versions 0+)
      - name: The topic name. (string | versions 0+)
      - topic_id: The unique topic ID (uuid | versions 7+)
      - error_code: The error code, or 0 if there was no error. (int16 | versions 0+)
      - error_message: The error message, or null if there was no error. (string | versions 1+)
      - topic_config_error_code: Optional topic config error returned if configs are not returned in the response. (int16 | versions 5+)
      - num_partitions: Number of partitions of the topic. (int32 | versions 5+)
      - replication_factor: Replication factor of the topic. (int16 | versions 5+)
      - configs: Configuration of the topic. ([]CreatableTopicConfigs | versions 5+)
          - name: The configuration name. (string | versions 5+)
          - value: The configuration value. (string | versions 5+)
          - read_only: True if the configuration is read-only. (bool | versions 5+)
          - config_source: The configuration source. (int8 | versions 5+)
          - is_sensitive: True if this configuration is sensitive. (bool | versions 5+)

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

  def max_supported_version(), do: 7
  def min_supported_version(), do: 0

  defp req_header_version(msg_version),
    do: if(msg_version >= @min_flexible_version_req, do: 2, else: 1)

  defp res_header_version(msg_version),
    do: if(msg_version >= @min_flexible_version_res, do: 1, else: 0)

  defp request_schema(0),
    do: [
      topics:
        {{:array,
          [
            name: {:string, %{is_nullable?: false}},
            num_partitions: {:int32, %{is_nullable?: false}},
            replication_factor: {:int16, %{is_nullable?: false}},
            assignments:
              {{:array,
                [
                  partition_index: {:int32, %{is_nullable?: false}},
                  broker_ids: {{:array, :int32}, %{is_nullable?: false}}
                ]}, %{is_nullable?: false}},
            configs:
              {{:array,
                [name: {:string, %{is_nullable?: false}}, value: {:string, %{is_nullable?: true}}]},
               %{is_nullable?: false}}
          ]}, %{is_nullable?: false}},
      timeout_ms: {:int32, %{is_nullable?: false}}
    ]

  defp request_schema(1),
    do: [
      topics:
        {{:array,
          [
            name: {:string, %{is_nullable?: false}},
            num_partitions: {:int32, %{is_nullable?: false}},
            replication_factor: {:int16, %{is_nullable?: false}},
            assignments:
              {{:array,
                [
                  partition_index: {:int32, %{is_nullable?: false}},
                  broker_ids: {{:array, :int32}, %{is_nullable?: false}}
                ]}, %{is_nullable?: false}},
            configs:
              {{:array,
                [name: {:string, %{is_nullable?: false}}, value: {:string, %{is_nullable?: true}}]},
               %{is_nullable?: false}}
          ]}, %{is_nullable?: false}},
      timeout_ms: {:int32, %{is_nullable?: false}},
      validate_only: {:boolean, %{is_nullable?: false}}
    ]

  defp request_schema(2),
    do: [
      topics:
        {{:array,
          [
            name: {:string, %{is_nullable?: false}},
            num_partitions: {:int32, %{is_nullable?: false}},
            replication_factor: {:int16, %{is_nullable?: false}},
            assignments:
              {{:array,
                [
                  partition_index: {:int32, %{is_nullable?: false}},
                  broker_ids: {{:array, :int32}, %{is_nullable?: false}}
                ]}, %{is_nullable?: false}},
            configs:
              {{:array,
                [name: {:string, %{is_nullable?: false}}, value: {:string, %{is_nullable?: true}}]},
               %{is_nullable?: false}}
          ]}, %{is_nullable?: false}},
      timeout_ms: {:int32, %{is_nullable?: false}},
      validate_only: {:boolean, %{is_nullable?: false}}
    ]

  defp request_schema(3),
    do: [
      topics:
        {{:array,
          [
            name: {:string, %{is_nullable?: false}},
            num_partitions: {:int32, %{is_nullable?: false}},
            replication_factor: {:int16, %{is_nullable?: false}},
            assignments:
              {{:array,
                [
                  partition_index: {:int32, %{is_nullable?: false}},
                  broker_ids: {{:array, :int32}, %{is_nullable?: false}}
                ]}, %{is_nullable?: false}},
            configs:
              {{:array,
                [name: {:string, %{is_nullable?: false}}, value: {:string, %{is_nullable?: true}}]},
               %{is_nullable?: false}}
          ]}, %{is_nullable?: false}},
      timeout_ms: {:int32, %{is_nullable?: false}},
      validate_only: {:boolean, %{is_nullable?: false}}
    ]

  defp request_schema(4),
    do: [
      topics:
        {{:array,
          [
            name: {:string, %{is_nullable?: false}},
            num_partitions: {:int32, %{is_nullable?: false}},
            replication_factor: {:int16, %{is_nullable?: false}},
            assignments:
              {{:array,
                [
                  partition_index: {:int32, %{is_nullable?: false}},
                  broker_ids: {{:array, :int32}, %{is_nullable?: false}}
                ]}, %{is_nullable?: false}},
            configs:
              {{:array,
                [name: {:string, %{is_nullable?: false}}, value: {:string, %{is_nullable?: true}}]},
               %{is_nullable?: false}}
          ]}, %{is_nullable?: false}},
      timeout_ms: {:int32, %{is_nullable?: false}},
      validate_only: {:boolean, %{is_nullable?: false}}
    ]

  defp request_schema(5),
    do: [
      topics:
        {{:compact_array,
          [
            name: {:compact_string, %{is_nullable?: false}},
            num_partitions: {:int32, %{is_nullable?: false}},
            replication_factor: {:int16, %{is_nullable?: false}},
            assignments:
              {{:compact_array,
                [
                  partition_index: {:int32, %{is_nullable?: false}},
                  broker_ids: {{:compact_array, :int32}, %{is_nullable?: false}},
                  tag_buffer: {:tag_buffer, []}
                ]}, %{is_nullable?: false}},
            configs:
              {{:compact_array,
                [
                  name: {:compact_string, %{is_nullable?: false}},
                  value: {:compact_string, %{is_nullable?: true}},
                  tag_buffer: {:tag_buffer, []}
                ]}, %{is_nullable?: false}},
            tag_buffer: {:tag_buffer, []}
          ]}, %{is_nullable?: false}},
      timeout_ms: {:int32, %{is_nullable?: false}},
      validate_only: {:boolean, %{is_nullable?: false}},
      tag_buffer: {:tag_buffer, []}
    ]

  defp request_schema(6),
    do: [
      topics:
        {{:compact_array,
          [
            name: {:compact_string, %{is_nullable?: false}},
            num_partitions: {:int32, %{is_nullable?: false}},
            replication_factor: {:int16, %{is_nullable?: false}},
            assignments:
              {{:compact_array,
                [
                  partition_index: {:int32, %{is_nullable?: false}},
                  broker_ids: {{:compact_array, :int32}, %{is_nullable?: false}},
                  tag_buffer: {:tag_buffer, []}
                ]}, %{is_nullable?: false}},
            configs:
              {{:compact_array,
                [
                  name: {:compact_string, %{is_nullable?: false}},
                  value: {:compact_string, %{is_nullable?: true}},
                  tag_buffer: {:tag_buffer, []}
                ]}, %{is_nullable?: false}},
            tag_buffer: {:tag_buffer, []}
          ]}, %{is_nullable?: false}},
      timeout_ms: {:int32, %{is_nullable?: false}},
      validate_only: {:boolean, %{is_nullable?: false}},
      tag_buffer: {:tag_buffer, []}
    ]

  defp request_schema(7),
    do: [
      topics:
        {{:compact_array,
          [
            name: {:compact_string, %{is_nullable?: false}},
            num_partitions: {:int32, %{is_nullable?: false}},
            replication_factor: {:int16, %{is_nullable?: false}},
            assignments:
              {{:compact_array,
                [
                  partition_index: {:int32, %{is_nullable?: false}},
                  broker_ids: {{:compact_array, :int32}, %{is_nullable?: false}},
                  tag_buffer: {:tag_buffer, []}
                ]}, %{is_nullable?: false}},
            configs:
              {{:compact_array,
                [
                  name: {:compact_string, %{is_nullable?: false}},
                  value: {:compact_string, %{is_nullable?: true}},
                  tag_buffer: {:tag_buffer, []}
                ]}, %{is_nullable?: false}},
            tag_buffer: {:tag_buffer, []}
          ]}, %{is_nullable?: false}},
      timeout_ms: {:int32, %{is_nullable?: false}},
      validate_only: {:boolean, %{is_nullable?: false}},
      tag_buffer: {:tag_buffer, []}
    ]

  defp request_schema(unkown_version),
    do: raise("Unknown version #{unkown_version} for message CreateTopics")

  defp response_schema(0),
    do: [
      topics:
        {{:array,
          [name: {:string, %{is_nullable?: false}}, error_code: {:int16, %{is_nullable?: false}}]},
         %{is_nullable?: false}}
    ]

  defp response_schema(1),
    do: [
      topics:
        {{:array,
          [
            name: {:string, %{is_nullable?: false}},
            error_code: {:int16, %{is_nullable?: false}},
            error_message: {:string, %{is_nullable?: true}}
          ]}, %{is_nullable?: false}}
    ]

  defp response_schema(2),
    do: [
      throttle_time_ms: {:int32, %{is_nullable?: false}},
      topics:
        {{:array,
          [
            name: {:string, %{is_nullable?: false}},
            error_code: {:int16, %{is_nullable?: false}},
            error_message: {:string, %{is_nullable?: true}}
          ]}, %{is_nullable?: false}}
    ]

  defp response_schema(3),
    do: [
      throttle_time_ms: {:int32, %{is_nullable?: false}},
      topics:
        {{:array,
          [
            name: {:string, %{is_nullable?: false}},
            error_code: {:int16, %{is_nullable?: false}},
            error_message: {:string, %{is_nullable?: true}}
          ]}, %{is_nullable?: false}}
    ]

  defp response_schema(4),
    do: [
      throttle_time_ms: {:int32, %{is_nullable?: false}},
      topics:
        {{:array,
          [
            name: {:string, %{is_nullable?: false}},
            error_code: {:int16, %{is_nullable?: false}},
            error_message: {:string, %{is_nullable?: true}}
          ]}, %{is_nullable?: false}}
    ]

  defp response_schema(5),
    do: [
      throttle_time_ms: {:int32, %{is_nullable?: false}},
      topics:
        {{:compact_array,
          [
            name: {:compact_string, %{is_nullable?: false}},
            error_code: {:int16, %{is_nullable?: false}},
            error_message: {:compact_string, %{is_nullable?: true}},
            num_partitions: {:int32, %{is_nullable?: false}},
            replication_factor: {:int16, %{is_nullable?: false}},
            configs:
              {{:compact_array,
                [
                  name: {:compact_string, %{is_nullable?: false}},
                  value: {:compact_string, %{is_nullable?: true}},
                  read_only: {:boolean, %{is_nullable?: false}},
                  config_source: {:int8, %{is_nullable?: false}},
                  is_sensitive: {:boolean, %{is_nullable?: false}},
                  tag_buffer: {:tag_buffer, %{}}
                ]}, %{is_nullable?: true}},
            tag_buffer:
              {:tag_buffer, %{0 => {{:topic_config_error_code, :int16}, %{is_nullable?: false}}}}
          ]}, %{is_nullable?: false}},
      tag_buffer: {:tag_buffer, %{}}
    ]

  defp response_schema(6),
    do: [
      throttle_time_ms: {:int32, %{is_nullable?: false}},
      topics:
        {{:compact_array,
          [
            name: {:compact_string, %{is_nullable?: false}},
            error_code: {:int16, %{is_nullable?: false}},
            error_message: {:compact_string, %{is_nullable?: true}},
            num_partitions: {:int32, %{is_nullable?: false}},
            replication_factor: {:int16, %{is_nullable?: false}},
            configs:
              {{:compact_array,
                [
                  name: {:compact_string, %{is_nullable?: false}},
                  value: {:compact_string, %{is_nullable?: true}},
                  read_only: {:boolean, %{is_nullable?: false}},
                  config_source: {:int8, %{is_nullable?: false}},
                  is_sensitive: {:boolean, %{is_nullable?: false}},
                  tag_buffer: {:tag_buffer, %{}}
                ]}, %{is_nullable?: true}},
            tag_buffer:
              {:tag_buffer, %{0 => {{:topic_config_error_code, :int16}, %{is_nullable?: false}}}}
          ]}, %{is_nullable?: false}},
      tag_buffer: {:tag_buffer, %{}}
    ]

  defp response_schema(7),
    do: [
      throttle_time_ms: {:int32, %{is_nullable?: false}},
      topics:
        {{:compact_array,
          [
            name: {:compact_string, %{is_nullable?: false}},
            topic_id: {:uuid, %{is_nullable?: false}},
            error_code: {:int16, %{is_nullable?: false}},
            error_message: {:compact_string, %{is_nullable?: true}},
            num_partitions: {:int32, %{is_nullable?: false}},
            replication_factor: {:int16, %{is_nullable?: false}},
            configs:
              {{:compact_array,
                [
                  name: {:compact_string, %{is_nullable?: false}},
                  value: {:compact_string, %{is_nullable?: true}},
                  read_only: {:boolean, %{is_nullable?: false}},
                  config_source: {:int8, %{is_nullable?: false}},
                  is_sensitive: {:boolean, %{is_nullable?: false}},
                  tag_buffer: {:tag_buffer, %{}}
                ]}, %{is_nullable?: true}},
            tag_buffer:
              {:tag_buffer, %{0 => {{:topic_config_error_code, :int16}, %{is_nullable?: false}}}}
          ]}, %{is_nullable?: false}},
      tag_buffer: {:tag_buffer, %{}}
    ]

  defp response_schema(unkown_version),
    do: raise("Unknown version #{unkown_version} for message CreateTopics")
end