defmodule KlifeProtocol.Messages.DescribeTransactions do
  alias KlifeProtocol.Deserializer
  alias KlifeProtocol.Serializer
  alias KlifeProtocol.Header

  @api_key 65
  @min_flexible_version_req 0
  @min_flexible_version_res 0

  def serialize_request(%{headers: headers, content: content}, version) do
    headers
    |> Map.put(:request_api_key, @api_key)
    |> Map.put(:request_api_version, version)
    |> Header.serialize_request(req_header_version(version))
    |> then(&Serializer.execute(content, request_schema(version), &1))
  end

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
      transactional_ids: {{:compact_array, :compact_string}, %{is_nullable?: false}},
      tag_buffer: {:tag_buffer, []}
    ]

  defp response_schema(0),
    do: [
      throttle_time_ms: {:int32, %{is_nullable?: false}},
      transaction_states:
        {{:compact_array,
          [
            error_code: {:int16, %{is_nullable?: false}},
            transactional_id: {:compact_string, %{is_nullable?: false}},
            transaction_state: {:compact_string, %{is_nullable?: false}},
            transaction_timeout_ms: {:int32, %{is_nullable?: false}},
            transaction_start_time_ms: {:int64, %{is_nullable?: false}},
            producer_id: {:int64, %{is_nullable?: false}},
            producer_epoch: {:int16, %{is_nullable?: false}},
            topics:
              {{:compact_array,
                [
                  topic: {:compact_string, %{is_nullable?: false}},
                  partitions: {{:compact_array, :int32}, %{is_nullable?: false}},
                  tag_buffer: {:tag_buffer, %{}}
                ]}, %{is_nullable?: false}},
            tag_buffer: {:tag_buffer, %{}}
          ]}, %{is_nullable?: false}},
      tag_buffer: {:tag_buffer, %{}}
    ]
end