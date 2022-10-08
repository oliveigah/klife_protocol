defmodule Klife.Protocol.Messages.Produce do
  alias Klife.Protocol.Deserializer
  alias Klife.Protocol.Serializer
  alias Klife.Protocol.Header

  @api_key 0
  @min_flexible_version_req 9
  @min_flexible_version_res 9

  def deserialize_response(data, version) do
    with {headers, rest_data} <- Header.deserialize_response(data, res_header_version(version)),
         {content, _} <- Deserializer.execute(rest_data, response_schema(version)) do
      %{headers: headers, content: content}
    end
  end

  def serialize_request(input, version) do
    input
    |> Map.put(:request_api_key, @api_key)
    |> Map.put(:request_api_version, version)
    |> Header.serialize_request(req_header_version(version))
    |> then(&Serializer.execute(input, request_schema(version), &1))
  end

  defp req_header_version(msg_version),
    do: if(msg_version >= @min_flexible_version_req, do: 2, else: 1)

  defp res_header_version(msg_version),
    do: if(msg_version >= @min_flexible_version_res, do: 1, else: 0)

  defp request_schema(0),
    do: [
      acks: :int16,
      timeout_ms: :int32,
      topic_data:
        {:array, [name: :string, partition_data: {:array, [index: :int32, records: :records]}]}
    ]

  defp request_schema(1),
    do: [
      acks: :int16,
      timeout_ms: :int32,
      topic_data:
        {:array, [name: :string, partition_data: {:array, [index: :int32, records: :records]}]}
    ]

  defp request_schema(2),
    do: [
      acks: :int16,
      timeout_ms: :int32,
      topic_data:
        {:array, [name: :string, partition_data: {:array, [index: :int32, records: :records]}]}
    ]

  defp request_schema(3),
    do: [
      transactional_id: :string,
      acks: :int16,
      timeout_ms: :int32,
      topic_data:
        {:array, [name: :string, partition_data: {:array, [index: :int32, records: :records]}]}
    ]

  defp request_schema(4),
    do: [
      transactional_id: :string,
      acks: :int16,
      timeout_ms: :int32,
      topic_data:
        {:array, [name: :string, partition_data: {:array, [index: :int32, records: :records]}]}
    ]

  defp request_schema(5),
    do: [
      transactional_id: :string,
      acks: :int16,
      timeout_ms: :int32,
      topic_data:
        {:array, [name: :string, partition_data: {:array, [index: :int32, records: :records]}]}
    ]

  defp request_schema(6),
    do: [
      transactional_id: :string,
      acks: :int16,
      timeout_ms: :int32,
      topic_data:
        {:array, [name: :string, partition_data: {:array, [index: :int32, records: :records]}]}
    ]

  defp request_schema(7),
    do: [
      transactional_id: :string,
      acks: :int16,
      timeout_ms: :int32,
      topic_data:
        {:array, [name: :string, partition_data: {:array, [index: :int32, records: :records]}]}
    ]

  defp request_schema(8),
    do: [
      transactional_id: :string,
      acks: :int16,
      timeout_ms: :int32,
      topic_data:
        {:array, [name: :string, partition_data: {:array, [index: :int32, records: :records]}]}
    ]

  defp request_schema(9),
    do: [
      transactional_id: :compact_string,
      acks: :int16,
      timeout_ms: :int32,
      topic_data:
        {:compact_array,
         [
           name: :compact_string,
           partition_data:
             {:compact_array, [index: :int32, records: :records, tag_buffer: {:tag_buffer, %{}}]},
           tag_buffer: {:tag_buffer, %{}}
         ]},
      tag_buffer: {:tag_buffer, %{}}
    ]

  defp response_schema(0),
    do: [
      responses:
        {:array,
         [
           name: :string,
           partition_responses: {:array, [index: :int32, error_code: :int16, base_offset: :int64]}
         ]}
    ]

  defp response_schema(1),
    do: [
      responses:
        {:array,
         [
           name: :string,
           partition_responses: {:array, [index: :int32, error_code: :int16, base_offset: :int64]}
         ]},
      throttle_time_ms: :int32
    ]

  defp response_schema(2),
    do: [
      responses:
        {:array,
         [
           name: :string,
           partition_responses:
             {:array,
              [index: :int32, error_code: :int16, base_offset: :int64, log_append_time_ms: :int64]}
         ]},
      throttle_time_ms: :int32
    ]

  defp response_schema(3),
    do: [
      responses:
        {:array,
         [
           name: :string,
           partition_responses:
             {:array,
              [index: :int32, error_code: :int16, base_offset: :int64, log_append_time_ms: :int64]}
         ]},
      throttle_time_ms: :int32
    ]

  defp response_schema(4),
    do: [
      responses:
        {:array,
         [
           name: :string,
           partition_responses:
             {:array,
              [index: :int32, error_code: :int16, base_offset: :int64, log_append_time_ms: :int64]}
         ]},
      throttle_time_ms: :int32
    ]

  defp response_schema(5),
    do: [
      responses:
        {:array,
         [
           name: :string,
           partition_responses:
             {:array,
              [
                index: :int32,
                error_code: :int16,
                base_offset: :int64,
                log_append_time_ms: :int64,
                log_start_offset: :int64
              ]}
         ]},
      throttle_time_ms: :int32
    ]

  defp response_schema(6),
    do: [
      responses:
        {:array,
         [
           name: :string,
           partition_responses:
             {:array,
              [
                index: :int32,
                error_code: :int16,
                base_offset: :int64,
                log_append_time_ms: :int64,
                log_start_offset: :int64
              ]}
         ]},
      throttle_time_ms: :int32
    ]

  defp response_schema(7),
    do: [
      responses:
        {:array,
         [
           name: :string,
           partition_responses:
             {:array,
              [
                index: :int32,
                error_code: :int16,
                base_offset: :int64,
                log_append_time_ms: :int64,
                log_start_offset: :int64
              ]}
         ]},
      throttle_time_ms: :int32
    ]

  defp response_schema(8),
    do: [
      responses:
        {:array,
         [
           name: :string,
           partition_responses:
             {:array,
              [
                index: :int32,
                error_code: :int16,
                base_offset: :int64,
                log_append_time_ms: :int64,
                log_start_offset: :int64,
                record_errors:
                  {:array, [batch_index: :int32, batch_index_error_message: :string]},
                error_message: :string
              ]}
         ]},
      throttle_time_ms: :int32
    ]

  defp response_schema(9),
    do: [
      responses:
        {:compact_array,
         [
           name: :compact_string,
           partition_responses:
             {:compact_array,
              [
                index: :int32,
                error_code: :int16,
                base_offset: :int64,
                log_append_time_ms: :int64,
                log_start_offset: :int64,
                record_errors:
                  {:compact_array,
                   [
                     batch_index: :int32,
                     batch_index_error_message: :compact_string,
                     tag_buffer: {:tag_buffer, %{}}
                   ]},
                error_message: :compact_string,
                tag_buffer: {:tag_buffer, %{}}
              ]},
           tag_buffer: {:tag_buffer, %{}}
         ]},
      throttle_time_ms: :int32,
      tag_buffer: {:tag_buffer, %{}}
    ]
end