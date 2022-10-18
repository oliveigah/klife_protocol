defmodule KlifeProtocol.Messages.DeleteTopics do
  alias KlifeProtocol.Deserializer
  alias KlifeProtocol.Serializer
  alias KlifeProtocol.Header

  @api_key 20
  @min_flexible_version_req 4
  @min_flexible_version_res 4

  def serialize_request(input, version) do
    input
    |> Map.put(:request_api_key, @api_key)
    |> Map.put(:request_api_version, version)
    |> Header.serialize_request(req_header_version(version))
    |> then(&Serializer.execute(input, request_schema(version), &1))
  end

  def deserialize_response(data, version) do
    with {headers, rest_data} <- Header.deserialize_response(data, res_header_version(version)),
         {content, <<>>} <- Deserializer.execute(rest_data, response_schema(version)) do
      %{headers: headers, content: content}
    end
  end

  defp req_header_version(msg_version),
    do: if(msg_version >= @min_flexible_version_req, do: 2, else: 1)

  defp res_header_version(msg_version),
    do: if(msg_version >= @min_flexible_version_res, do: 1, else: 0)

  defp request_schema(0),
    do: [
      topic_names: {{:array, :string}, %{is_nullable?: false}},
      timeout_ms: {:int32, %{is_nullable?: false}}
    ]

  defp request_schema(1),
    do: [
      topic_names: {{:array, :string}, %{is_nullable?: false}},
      timeout_ms: {:int32, %{is_nullable?: false}}
    ]

  defp request_schema(2),
    do: [
      topic_names: {{:array, :string}, %{is_nullable?: false}},
      timeout_ms: {:int32, %{is_nullable?: false}}
    ]

  defp request_schema(3),
    do: [
      topic_names: {{:array, :string}, %{is_nullable?: false}},
      timeout_ms: {:int32, %{is_nullable?: false}}
    ]

  defp request_schema(4),
    do: [
      topic_names: {{:compact_array, :compact_string}, %{is_nullable?: false}},
      timeout_ms: {:int32, %{is_nullable?: false}},
      tag_buffer: {:tag_buffer, []}
    ]

  defp request_schema(5),
    do: [
      topic_names: {{:compact_array, :compact_string}, %{is_nullable?: false}},
      timeout_ms: {:int32, %{is_nullable?: false}},
      tag_buffer: {:tag_buffer, []}
    ]

  defp request_schema(6),
    do: [
      topics:
        {{:compact_array,
          [
            name: {:compact_string, %{is_nullable?: true}},
            topic_id: {:uuid, %{is_nullable?: false}},
            tag_buffer: {:tag_buffer, []}
          ]}, %{is_nullable?: false}},
      timeout_ms: {:int32, %{is_nullable?: false}},
      tag_buffer: {:tag_buffer, []}
    ]

  defp response_schema(0),
    do: [
      responses:
        {{:array,
          [name: {:string, %{is_nullable?: false}}, error_code: {:int16, %{is_nullable?: false}}]},
         %{is_nullable?: false}}
    ]

  defp response_schema(1),
    do: [
      throttle_time_ms: {:int32, %{is_nullable?: false}},
      responses:
        {{:array,
          [name: {:string, %{is_nullable?: false}}, error_code: {:int16, %{is_nullable?: false}}]},
         %{is_nullable?: false}}
    ]

  defp response_schema(2),
    do: [
      throttle_time_ms: {:int32, %{is_nullable?: false}},
      responses:
        {{:array,
          [name: {:string, %{is_nullable?: false}}, error_code: {:int16, %{is_nullable?: false}}]},
         %{is_nullable?: false}}
    ]

  defp response_schema(3),
    do: [
      throttle_time_ms: {:int32, %{is_nullable?: false}},
      responses:
        {{:array,
          [name: {:string, %{is_nullable?: false}}, error_code: {:int16, %{is_nullable?: false}}]},
         %{is_nullable?: false}}
    ]

  defp response_schema(4),
    do: [
      throttle_time_ms: {:int32, %{is_nullable?: false}},
      responses:
        {{:compact_array,
          [
            name: {:compact_string, %{is_nullable?: false}},
            error_code: {:int16, %{is_nullable?: false}},
            tag_buffer: {:tag_buffer, %{}}
          ]}, %{is_nullable?: false}},
      tag_buffer: {:tag_buffer, %{}}
    ]

  defp response_schema(5),
    do: [
      throttle_time_ms: {:int32, %{is_nullable?: false}},
      responses:
        {{:compact_array,
          [
            name: {:compact_string, %{is_nullable?: false}},
            error_code: {:int16, %{is_nullable?: false}},
            error_message: {:compact_string, %{is_nullable?: true}},
            tag_buffer: {:tag_buffer, %{}}
          ]}, %{is_nullable?: false}},
      tag_buffer: {:tag_buffer, %{}}
    ]

  defp response_schema(6),
    do: [
      throttle_time_ms: {:int32, %{is_nullable?: false}},
      responses:
        {{:compact_array,
          [
            name: {:compact_string, %{is_nullable?: true}},
            topic_id: {:uuid, %{is_nullable?: false}},
            error_code: {:int16, %{is_nullable?: false}},
            error_message: {:compact_string, %{is_nullable?: true}},
            tag_buffer: {:tag_buffer, %{}}
          ]}, %{is_nullable?: false}},
      tag_buffer: {:tag_buffer, %{}}
    ]
end