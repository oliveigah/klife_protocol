# DO NOT EDIT THIS FILE MANUALLY  
# This module is automatically generated by running mix task generate_file
# every change must be done inside the mix task directly

defmodule KlifeProtocol.Messages.Produce do
  @moduledoc """
  Kafka protocol Produce message

  Request versions summary:   
  - Version 1 and 2 are the same as version 0.
  - Version 3 adds the transactional ID, which is used for authorization when attempting to write
  transactional data.  Version 3 also adds support for Kafka Message Format v2.
  - Version 4 is the same as version 3, but the requestor must be prepared to handle a
  KAFKA_STORAGE_ERROR.
  - Version 5 and 6 are the same as version 3.
  - Starting in version 7, records can be produced using ZStandard compression.  See KIP-110.
  - Starting in Version 8, response has RecordErrors and ErrorMEssage. See KIP-467.
  - Version 9 enables flexible versions.

  Response versions summary:
  - Version 1 added the throttle time.
  - Version 2 added the log append time.
  - Version 3 is the same as version 2.
  - Version 4 added KAFKA_STORAGE_ERROR as a possible error code.
  - Version 5 added LogStartOffset to filter out spurious
  OutOfOrderSequenceExceptions on the client.
  - Version 8 added RecordErrors and ErrorMessage to include information about
  records that cause the whole batch to be dropped.  See KIP-467 for details.
  - Version 9 enables flexible versions.

  """

  alias KlifeProtocol.Deserializer
  alias KlifeProtocol.Serializer
  alias KlifeProtocol.Header

  @api_key 0
  @min_flexible_version_req 9
  @min_flexible_version_res 9

  @doc """
  Content fields:

  - transactional_id: The transactional ID, or null if the producer is not transactional. (string | versions 3+)
  - acks: The number of acknowledgments the producer requires the leader to have received before considering a request complete. Allowed values: 0 for no acknowledgments, 1 for only the leader and -1 for the full ISR. (int16 | versions 0+)
  - timeout_ms: The timeout to await a response in milliseconds. (int32 | versions 0+)
  - topic_data: Each topic to produce to. ([]TopicProduceData | versions 0+)
      - name: The topic name. (string | versions 0+)
      - partition_data: Each partition to produce to. ([]PartitionProduceData | versions 0+)
          - index: The partition index. (int32 | versions 0+)
          - records: The record data to be produced. (records | versions 0+)

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

  - responses: Each produce response ([]TopicProduceResponse | versions 0+)
      - name: The topic name (string | versions 0+)
      - partition_responses: Each partition that we produced to within the topic. ([]PartitionProduceResponse | versions 0+)
          - index: The partition index. (int32 | versions 0+)
          - error_code: The error code, or 0 if there was no error. (int16 | versions 0+)
          - base_offset: The base offset. (int64 | versions 0+)
          - log_append_time_ms: The timestamp returned by broker after appending the messages. If CreateTime is used for the topic, the timestamp will be -1.  If LogAppendTime is used for the topic, the timestamp will be the broker local time when the messages are appended. (int64 | versions 2+)
          - log_start_offset: The log start offset. (int64 | versions 5+)
          - record_errors: The batch indices of records that caused the batch to be dropped ([]BatchIndexAndErrorMessage | versions 8+)
              - batch_index: The batch index of the record that cause the batch to be dropped (int32 | versions 8+)
              - batch_index_error_message: The error message of the record that caused the batch to be dropped (string | versions 8+)
          - error_message: The global error message summarizing the common root cause of the records that caused the batch to be dropped (string | versions 8+)
  - throttle_time_ms: The duration in milliseconds for which the request was throttled due to a quota violation, or zero if the request did not violate any quota. (int32 | versions 1+)

  """
  def deserialize_response(data, version) do
    {headers, rest_data} = Header.deserialize_response(data, res_header_version(version))
    {content, <<>>} = Deserializer.execute(rest_data, response_schema(version))

    %{headers: headers, content: content}
  end

  def max_supported_version(), do: 9
  def min_supported_version(), do: 0

  defp req_header_version(msg_version),
    do: if(msg_version >= @min_flexible_version_req, do: 2, else: 1)

  defp res_header_version(msg_version),
    do: if(msg_version >= @min_flexible_version_res, do: 1, else: 0)

  defp request_schema(0),
    do: [
      acks: {:int16, %{is_nullable?: false}},
      timeout_ms: {:int32, %{is_nullable?: false}},
      topic_data:
        {{:array,
          [
            name: {:string, %{is_nullable?: false}},
            partition_data:
              {{:array,
                [
                  index: {:int32, %{is_nullable?: false}},
                  records: {:record_batch, %{is_nullable?: true}}
                ]}, %{is_nullable?: false}}
          ]}, %{is_nullable?: false}}
    ]

  defp request_schema(1),
    do: [
      acks: {:int16, %{is_nullable?: false}},
      timeout_ms: {:int32, %{is_nullable?: false}},
      topic_data:
        {{:array,
          [
            name: {:string, %{is_nullable?: false}},
            partition_data:
              {{:array,
                [
                  index: {:int32, %{is_nullable?: false}},
                  records: {:record_batch, %{is_nullable?: true}}
                ]}, %{is_nullable?: false}}
          ]}, %{is_nullable?: false}}
    ]

  defp request_schema(2),
    do: [
      acks: {:int16, %{is_nullable?: false}},
      timeout_ms: {:int32, %{is_nullable?: false}},
      topic_data:
        {{:array,
          [
            name: {:string, %{is_nullable?: false}},
            partition_data:
              {{:array,
                [
                  index: {:int32, %{is_nullable?: false}},
                  records: {:record_batch, %{is_nullable?: true}}
                ]}, %{is_nullable?: false}}
          ]}, %{is_nullable?: false}}
    ]

  defp request_schema(3),
    do: [
      transactional_id: {:string, %{is_nullable?: true}},
      acks: {:int16, %{is_nullable?: false}},
      timeout_ms: {:int32, %{is_nullable?: false}},
      topic_data:
        {{:array,
          [
            name: {:string, %{is_nullable?: false}},
            partition_data:
              {{:array,
                [
                  index: {:int32, %{is_nullable?: false}},
                  records: {:record_batch, %{is_nullable?: true}}
                ]}, %{is_nullable?: false}}
          ]}, %{is_nullable?: false}}
    ]

  defp request_schema(4),
    do: [
      transactional_id: {:string, %{is_nullable?: true}},
      acks: {:int16, %{is_nullable?: false}},
      timeout_ms: {:int32, %{is_nullable?: false}},
      topic_data:
        {{:array,
          [
            name: {:string, %{is_nullable?: false}},
            partition_data:
              {{:array,
                [
                  index: {:int32, %{is_nullable?: false}},
                  records: {:record_batch, %{is_nullable?: true}}
                ]}, %{is_nullable?: false}}
          ]}, %{is_nullable?: false}}
    ]

  defp request_schema(5),
    do: [
      transactional_id: {:string, %{is_nullable?: true}},
      acks: {:int16, %{is_nullable?: false}},
      timeout_ms: {:int32, %{is_nullable?: false}},
      topic_data:
        {{:array,
          [
            name: {:string, %{is_nullable?: false}},
            partition_data:
              {{:array,
                [
                  index: {:int32, %{is_nullable?: false}},
                  records: {:record_batch, %{is_nullable?: true}}
                ]}, %{is_nullable?: false}}
          ]}, %{is_nullable?: false}}
    ]

  defp request_schema(6),
    do: [
      transactional_id: {:string, %{is_nullable?: true}},
      acks: {:int16, %{is_nullable?: false}},
      timeout_ms: {:int32, %{is_nullable?: false}},
      topic_data:
        {{:array,
          [
            name: {:string, %{is_nullable?: false}},
            partition_data:
              {{:array,
                [
                  index: {:int32, %{is_nullable?: false}},
                  records: {:record_batch, %{is_nullable?: true}}
                ]}, %{is_nullable?: false}}
          ]}, %{is_nullable?: false}}
    ]

  defp request_schema(7),
    do: [
      transactional_id: {:string, %{is_nullable?: true}},
      acks: {:int16, %{is_nullable?: false}},
      timeout_ms: {:int32, %{is_nullable?: false}},
      topic_data:
        {{:array,
          [
            name: {:string, %{is_nullable?: false}},
            partition_data:
              {{:array,
                [
                  index: {:int32, %{is_nullable?: false}},
                  records: {:record_batch, %{is_nullable?: true}}
                ]}, %{is_nullable?: false}}
          ]}, %{is_nullable?: false}}
    ]

  defp request_schema(8),
    do: [
      transactional_id: {:string, %{is_nullable?: true}},
      acks: {:int16, %{is_nullable?: false}},
      timeout_ms: {:int32, %{is_nullable?: false}},
      topic_data:
        {{:array,
          [
            name: {:string, %{is_nullable?: false}},
            partition_data:
              {{:array,
                [
                  index: {:int32, %{is_nullable?: false}},
                  records: {:record_batch, %{is_nullable?: true}}
                ]}, %{is_nullable?: false}}
          ]}, %{is_nullable?: false}}
    ]

  defp request_schema(9),
    do: [
      transactional_id: {:compact_string, %{is_nullable?: true}},
      acks: {:int16, %{is_nullable?: false}},
      timeout_ms: {:int32, %{is_nullable?: false}},
      topic_data:
        {{:compact_array,
          [
            name: {:compact_string, %{is_nullable?: false}},
            partition_data:
              {{:compact_array,
                [
                  index: {:int32, %{is_nullable?: false}},
                  records: {:compact_record_batch, %{is_nullable?: true}},
                  tag_buffer: {:tag_buffer, []}
                ]}, %{is_nullable?: false}},
            tag_buffer: {:tag_buffer, []}
          ]}, %{is_nullable?: false}},
      tag_buffer: {:tag_buffer, []}
    ]

  defp request_schema(unkown_version),
    do: raise("Unknown version #{unkown_version} for message Produce")

  defp response_schema(0),
    do: [
      responses:
        {{:array,
          [
            name: {:string, %{is_nullable?: false}},
            partition_responses:
              {{:array,
                [
                  index: {:int32, %{is_nullable?: false}},
                  error_code: {:int16, %{is_nullable?: false}},
                  base_offset: {:int64, %{is_nullable?: false}}
                ]}, %{is_nullable?: false}}
          ]}, %{is_nullable?: false}}
    ]

  defp response_schema(1),
    do: [
      responses:
        {{:array,
          [
            name: {:string, %{is_nullable?: false}},
            partition_responses:
              {{:array,
                [
                  index: {:int32, %{is_nullable?: false}},
                  error_code: {:int16, %{is_nullable?: false}},
                  base_offset: {:int64, %{is_nullable?: false}}
                ]}, %{is_nullable?: false}}
          ]}, %{is_nullable?: false}},
      throttle_time_ms: {:int32, %{is_nullable?: false}}
    ]

  defp response_schema(2),
    do: [
      responses:
        {{:array,
          [
            name: {:string, %{is_nullable?: false}},
            partition_responses:
              {{:array,
                [
                  index: {:int32, %{is_nullable?: false}},
                  error_code: {:int16, %{is_nullable?: false}},
                  base_offset: {:int64, %{is_nullable?: false}},
                  log_append_time_ms: {:int64, %{is_nullable?: false}}
                ]}, %{is_nullable?: false}}
          ]}, %{is_nullable?: false}},
      throttle_time_ms: {:int32, %{is_nullable?: false}}
    ]

  defp response_schema(3),
    do: [
      responses:
        {{:array,
          [
            name: {:string, %{is_nullable?: false}},
            partition_responses:
              {{:array,
                [
                  index: {:int32, %{is_nullable?: false}},
                  error_code: {:int16, %{is_nullable?: false}},
                  base_offset: {:int64, %{is_nullable?: false}},
                  log_append_time_ms: {:int64, %{is_nullable?: false}}
                ]}, %{is_nullable?: false}}
          ]}, %{is_nullable?: false}},
      throttle_time_ms: {:int32, %{is_nullable?: false}}
    ]

  defp response_schema(4),
    do: [
      responses:
        {{:array,
          [
            name: {:string, %{is_nullable?: false}},
            partition_responses:
              {{:array,
                [
                  index: {:int32, %{is_nullable?: false}},
                  error_code: {:int16, %{is_nullable?: false}},
                  base_offset: {:int64, %{is_nullable?: false}},
                  log_append_time_ms: {:int64, %{is_nullable?: false}}
                ]}, %{is_nullable?: false}}
          ]}, %{is_nullable?: false}},
      throttle_time_ms: {:int32, %{is_nullable?: false}}
    ]

  defp response_schema(5),
    do: [
      responses:
        {{:array,
          [
            name: {:string, %{is_nullable?: false}},
            partition_responses:
              {{:array,
                [
                  index: {:int32, %{is_nullable?: false}},
                  error_code: {:int16, %{is_nullable?: false}},
                  base_offset: {:int64, %{is_nullable?: false}},
                  log_append_time_ms: {:int64, %{is_nullable?: false}},
                  log_start_offset: {:int64, %{is_nullable?: false}}
                ]}, %{is_nullable?: false}}
          ]}, %{is_nullable?: false}},
      throttle_time_ms: {:int32, %{is_nullable?: false}}
    ]

  defp response_schema(6),
    do: [
      responses:
        {{:array,
          [
            name: {:string, %{is_nullable?: false}},
            partition_responses:
              {{:array,
                [
                  index: {:int32, %{is_nullable?: false}},
                  error_code: {:int16, %{is_nullable?: false}},
                  base_offset: {:int64, %{is_nullable?: false}},
                  log_append_time_ms: {:int64, %{is_nullable?: false}},
                  log_start_offset: {:int64, %{is_nullable?: false}}
                ]}, %{is_nullable?: false}}
          ]}, %{is_nullable?: false}},
      throttle_time_ms: {:int32, %{is_nullable?: false}}
    ]

  defp response_schema(7),
    do: [
      responses:
        {{:array,
          [
            name: {:string, %{is_nullable?: false}},
            partition_responses:
              {{:array,
                [
                  index: {:int32, %{is_nullable?: false}},
                  error_code: {:int16, %{is_nullable?: false}},
                  base_offset: {:int64, %{is_nullable?: false}},
                  log_append_time_ms: {:int64, %{is_nullable?: false}},
                  log_start_offset: {:int64, %{is_nullable?: false}}
                ]}, %{is_nullable?: false}}
          ]}, %{is_nullable?: false}},
      throttle_time_ms: {:int32, %{is_nullable?: false}}
    ]

  defp response_schema(8),
    do: [
      responses:
        {{:array,
          [
            name: {:string, %{is_nullable?: false}},
            partition_responses:
              {{:array,
                [
                  index: {:int32, %{is_nullable?: false}},
                  error_code: {:int16, %{is_nullable?: false}},
                  base_offset: {:int64, %{is_nullable?: false}},
                  log_append_time_ms: {:int64, %{is_nullable?: false}},
                  log_start_offset: {:int64, %{is_nullable?: false}},
                  record_errors:
                    {{:array,
                      [
                        batch_index: {:int32, %{is_nullable?: false}},
                        batch_index_error_message: {:string, %{is_nullable?: true}}
                      ]}, %{is_nullable?: false}},
                  error_message: {:string, %{is_nullable?: true}}
                ]}, %{is_nullable?: false}}
          ]}, %{is_nullable?: false}},
      throttle_time_ms: {:int32, %{is_nullable?: false}}
    ]

  defp response_schema(9),
    do: [
      responses:
        {{:compact_array,
          [
            name: {:compact_string, %{is_nullable?: false}},
            partition_responses:
              {{:compact_array,
                [
                  index: {:int32, %{is_nullable?: false}},
                  error_code: {:int16, %{is_nullable?: false}},
                  base_offset: {:int64, %{is_nullable?: false}},
                  log_append_time_ms: {:int64, %{is_nullable?: false}},
                  log_start_offset: {:int64, %{is_nullable?: false}},
                  record_errors:
                    {{:compact_array,
                      [
                        batch_index: {:int32, %{is_nullable?: false}},
                        batch_index_error_message: {:compact_string, %{is_nullable?: true}},
                        tag_buffer: {:tag_buffer, %{}}
                      ]}, %{is_nullable?: false}},
                  error_message: {:compact_string, %{is_nullable?: true}},
                  tag_buffer: {:tag_buffer, %{}}
                ]}, %{is_nullable?: false}},
            tag_buffer: {:tag_buffer, %{}}
          ]}, %{is_nullable?: false}},
      throttle_time_ms: {:int32, %{is_nullable?: false}},
      tag_buffer: {:tag_buffer, %{}}
    ]

  defp response_schema(unkown_version),
    do: raise("Unknown version #{unkown_version} for message Produce")
end