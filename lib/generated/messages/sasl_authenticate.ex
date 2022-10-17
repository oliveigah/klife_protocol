defmodule KlifeProtocol.Messages.SaslAuthenticate do
  alias KlifeProtocol.Deserializer
  alias KlifeProtocol.Serializer
  alias KlifeProtocol.Header

  @api_key 36
  @min_flexible_version_req 2
  @min_flexible_version_res 2

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

  defp request_schema(0), do: [auth_bytes: {:bytes, %{is_nullable?: false}}]
  defp request_schema(1), do: [auth_bytes: {:bytes, %{is_nullable?: false}}]

  defp request_schema(2),
    do: [auth_bytes: {:compact_bytes, %{is_nullable?: false}}, tag_buffer: {:tag_buffer, []}]

  defp response_schema(0),
    do: [
      error_code: {:int16, %{is_nullable?: false}},
      error_message: {:string, %{is_nullable?: true}},
      auth_bytes: {:bytes, %{is_nullable?: false}}
    ]

  defp response_schema(1),
    do: [
      error_code: {:int16, %{is_nullable?: false}},
      error_message: {:string, %{is_nullable?: true}},
      auth_bytes: {:bytes, %{is_nullable?: false}},
      session_lifetime_ms: {:int64, %{is_nullable?: false}}
    ]

  defp response_schema(2),
    do: [
      error_code: {:int16, %{is_nullable?: false}},
      error_message: {:compact_string, %{is_nullable?: true}},
      auth_bytes: {:compact_bytes, %{is_nullable?: false}},
      session_lifetime_ms: {:int64, %{is_nullable?: false}},
      tag_buffer: {:tag_buffer, %{}}
    ]
end