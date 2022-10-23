defmodule KlifeProtocol.Messages.RenewDelegationToken do
  alias KlifeProtocol.Deserializer
  alias KlifeProtocol.Serializer
  alias KlifeProtocol.Header

  @api_key 39
  @min_flexible_version_req 2
  @min_flexible_version_res 2

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
      hmac: {:bytes, %{is_nullable?: false}},
      renew_period_ms: {:int64, %{is_nullable?: false}}
    ]

  defp request_schema(1),
    do: [
      hmac: {:bytes, %{is_nullable?: false}},
      renew_period_ms: {:int64, %{is_nullable?: false}}
    ]

  defp request_schema(2),
    do: [
      hmac: {:compact_bytes, %{is_nullable?: false}},
      renew_period_ms: {:int64, %{is_nullable?: false}},
      tag_buffer: {:tag_buffer, []}
    ]

  defp response_schema(0),
    do: [
      error_code: {:int16, %{is_nullable?: false}},
      expiry_timestamp_ms: {:int64, %{is_nullable?: false}},
      throttle_time_ms: {:int32, %{is_nullable?: false}}
    ]

  defp response_schema(1),
    do: [
      error_code: {:int16, %{is_nullable?: false}},
      expiry_timestamp_ms: {:int64, %{is_nullable?: false}},
      throttle_time_ms: {:int32, %{is_nullable?: false}}
    ]

  defp response_schema(2),
    do: [
      error_code: {:int16, %{is_nullable?: false}},
      expiry_timestamp_ms: {:int64, %{is_nullable?: false}},
      throttle_time_ms: {:int32, %{is_nullable?: false}},
      tag_buffer: {:tag_buffer, %{}}
    ]
end