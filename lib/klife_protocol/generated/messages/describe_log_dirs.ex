# DO NOT EDIT THIS FILE MANUALLY
# This module is automatically generated by running mix task generate_file
# every change must be done inside the mix task directly

defmodule KlifeProtocol.Messages.DescribeLogDirs do
  @moduledoc """
  Kafka protocol DescribeLogDirs message

  Request versions summary:
  - Version 1 is the same as version 0.
  Version 2 is the first flexible version.
  Version 3 is the same as version 2 (new field in response).
  Version 4 is the same as version 2 (new fields in response).

  Response versions summary:
  - Starting in version 1, on quota violation, brokers send out responses before throttling.

  """

  alias KlifeProtocol.Deserializer
  alias KlifeProtocol.Serializer
  alias KlifeProtocol.Header

  @api_key 35
  @min_flexible_version_req 2
  @min_flexible_version_res 2

  @doc """
  Receives a map and serialize it to kafka wire format of the given version.

  Input content fields:
  - topics: Each topic that we want to describe log directories for, or null for all topics. ([]DescribableLogDirTopic | versions 0+)
      - topic: The topic name (string | versions 0+)
      - partitions: The partition indexes. ([]int32 | versions 0+)

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
  - error_code: The error code, or 0 if there was no error. (int16 | versions 3+)
  - results: The log directories. ([]DescribeLogDirsResult | versions 0+)
      - error_code: The error code, or 0 if there was no error. (int16 | versions 0+)
      - log_dir: The absolute log directory path. (string | versions 0+)
      - topics: Each topic. ([]DescribeLogDirsTopic | versions 0+)
          - name: The topic name. (string | versions 0+)
          - partitions:  ([]DescribeLogDirsPartition | versions 0+)
              - partition_index: The partition index. (int32 | versions 0+)
              - partition_size: The size of the log segments in this partition in bytes. (int64 | versions 0+)
              - offset_lag: The lag of the log's LEO w.r.t. partition's HW (if it is the current log for the partition) or current replica's LEO (if it is the future log for the partition) (int64 | versions 0+)
              - is_future_key: True if this log is created by AlterReplicaLogDirsRequest and will replace the current log of the replica in the future. (bool | versions 0+)
      - total_bytes: The total size in bytes of the volume the log directory is in. (int64 | versions 4+)
      - usable_bytes: The usable size in bytes of the volume the log directory is in. (int64 | versions 4+)

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
  def max_supported_version(), do: 4

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
            topic: {:string, %{is_nullable?: false}},
            partitions: {{:array, :int32}, %{is_nullable?: false}}
          ]}, %{is_nullable?: true}}
    ]

  def request_schema(1),
    do: [
      topics:
        {{:array,
          [
            topic: {:string, %{is_nullable?: false}},
            partitions: {{:array, :int32}, %{is_nullable?: false}}
          ]}, %{is_nullable?: true}}
    ]

  def request_schema(2),
    do: [
      topics:
        {{:compact_array,
          [
            topic: {:compact_string, %{is_nullable?: false}},
            partitions: {{:compact_array, :int32}, %{is_nullable?: false}},
            tag_buffer: {:tag_buffer, []}
          ]}, %{is_nullable?: true}},
      tag_buffer: {:tag_buffer, []}
    ]

  def request_schema(3),
    do: [
      topics:
        {{:compact_array,
          [
            topic: {:compact_string, %{is_nullable?: false}},
            partitions: {{:compact_array, :int32}, %{is_nullable?: false}},
            tag_buffer: {:tag_buffer, []}
          ]}, %{is_nullable?: true}},
      tag_buffer: {:tag_buffer, []}
    ]

  def request_schema(4),
    do: [
      topics:
        {{:compact_array,
          [
            topic: {:compact_string, %{is_nullable?: false}},
            partitions: {{:compact_array, :int32}, %{is_nullable?: false}},
            tag_buffer: {:tag_buffer, []}
          ]}, %{is_nullable?: true}},
      tag_buffer: {:tag_buffer, []}
    ]

  def request_schema(unkown_version),
    do: raise("Unknown version #{unkown_version} for message DescribeLogDirs")

  def response_schema(0),
    do: [
      throttle_time_ms: {:int32, %{is_nullable?: false}},
      results:
        {{:array,
          [
            error_code: {:int16, %{is_nullable?: false}},
            log_dir: {:string, %{is_nullable?: false}},
            topics:
              {{:array,
                [
                  name: {:string, %{is_nullable?: false}},
                  partitions:
                    {{:array,
                      [
                        partition_index: {:int32, %{is_nullable?: false}},
                        partition_size: {:int64, %{is_nullable?: false}},
                        offset_lag: {:int64, %{is_nullable?: false}},
                        is_future_key: {:boolean, %{is_nullable?: false}}
                      ]}, %{is_nullable?: false}}
                ]}, %{is_nullable?: false}}
          ]}, %{is_nullable?: false}}
    ]

  def response_schema(1),
    do: [
      throttle_time_ms: {:int32, %{is_nullable?: false}},
      results:
        {{:array,
          [
            error_code: {:int16, %{is_nullable?: false}},
            log_dir: {:string, %{is_nullable?: false}},
            topics:
              {{:array,
                [
                  name: {:string, %{is_nullable?: false}},
                  partitions:
                    {{:array,
                      [
                        partition_index: {:int32, %{is_nullable?: false}},
                        partition_size: {:int64, %{is_nullable?: false}},
                        offset_lag: {:int64, %{is_nullable?: false}},
                        is_future_key: {:boolean, %{is_nullable?: false}}
                      ]}, %{is_nullable?: false}}
                ]}, %{is_nullable?: false}}
          ]}, %{is_nullable?: false}}
    ]

  def response_schema(2),
    do: [
      throttle_time_ms: {:int32, %{is_nullable?: false}},
      results:
        {{:compact_array,
          [
            error_code: {:int16, %{is_nullable?: false}},
            log_dir: {:compact_string, %{is_nullable?: false}},
            topics:
              {{:compact_array,
                [
                  name: {:compact_string, %{is_nullable?: false}},
                  partitions:
                    {{:compact_array,
                      [
                        partition_index: {:int32, %{is_nullable?: false}},
                        partition_size: {:int64, %{is_nullable?: false}},
                        offset_lag: {:int64, %{is_nullable?: false}},
                        is_future_key: {:boolean, %{is_nullable?: false}},
                        tag_buffer: {:tag_buffer, %{}}
                      ]}, %{is_nullable?: false}},
                  tag_buffer: {:tag_buffer, %{}}
                ]}, %{is_nullable?: false}},
            tag_buffer: {:tag_buffer, %{}}
          ]}, %{is_nullable?: false}},
      tag_buffer: {:tag_buffer, %{}}
    ]

  def response_schema(3),
    do: [
      throttle_time_ms: {:int32, %{is_nullable?: false}},
      error_code: {:int16, %{is_nullable?: false}},
      results:
        {{:compact_array,
          [
            error_code: {:int16, %{is_nullable?: false}},
            log_dir: {:compact_string, %{is_nullable?: false}},
            topics:
              {{:compact_array,
                [
                  name: {:compact_string, %{is_nullable?: false}},
                  partitions:
                    {{:compact_array,
                      [
                        partition_index: {:int32, %{is_nullable?: false}},
                        partition_size: {:int64, %{is_nullable?: false}},
                        offset_lag: {:int64, %{is_nullable?: false}},
                        is_future_key: {:boolean, %{is_nullable?: false}},
                        tag_buffer: {:tag_buffer, %{}}
                      ]}, %{is_nullable?: false}},
                  tag_buffer: {:tag_buffer, %{}}
                ]}, %{is_nullable?: false}},
            tag_buffer: {:tag_buffer, %{}}
          ]}, %{is_nullable?: false}},
      tag_buffer: {:tag_buffer, %{}}
    ]

  def response_schema(4),
    do: [
      throttle_time_ms: {:int32, %{is_nullable?: false}},
      error_code: {:int16, %{is_nullable?: false}},
      results:
        {{:compact_array,
          [
            error_code: {:int16, %{is_nullable?: false}},
            log_dir: {:compact_string, %{is_nullable?: false}},
            topics:
              {{:compact_array,
                [
                  name: {:compact_string, %{is_nullable?: false}},
                  partitions:
                    {{:compact_array,
                      [
                        partition_index: {:int32, %{is_nullable?: false}},
                        partition_size: {:int64, %{is_nullable?: false}},
                        offset_lag: {:int64, %{is_nullable?: false}},
                        is_future_key: {:boolean, %{is_nullable?: false}},
                        tag_buffer: {:tag_buffer, %{}}
                      ]}, %{is_nullable?: false}},
                  tag_buffer: {:tag_buffer, %{}}
                ]}, %{is_nullable?: false}},
            total_bytes: {:int64, %{is_nullable?: false}},
            usable_bytes: {:int64, %{is_nullable?: false}},
            tag_buffer: {:tag_buffer, %{}}
          ]}, %{is_nullable?: false}},
      tag_buffer: {:tag_buffer, %{}}
    ]

  def response_schema(unkown_version),
    do: raise("Unknown version #{unkown_version} for message DescribeLogDirs")
end
