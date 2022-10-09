defmodule KlifeProtocol.Messages.CreateDelegationToken do
  alias KlifeProtocol.Deserializer
  alias KlifeProtocol.Serializer
  alias KlifeProtocol.Header

  @api_key 38
  @min_flexible_version_req 2
  @min_flexible_version_res 2

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
      renewers:
        {{:array,
          [
            principal_type: {:string, %{is_nullable?: false}},
            principal_name: {:string, %{is_nullable?: false}}
          ]}, %{is_nullable?: false}},
      max_lifetime_ms: {:int64, %{is_nullable?: false}}
    ]

  defp request_schema(1),
    do: [
      renewers:
        {{:array,
          [
            principal_type: {:string, %{is_nullable?: false}},
            principal_name: {:string, %{is_nullable?: false}}
          ]}, %{is_nullable?: false}},
      max_lifetime_ms: {:int64, %{is_nullable?: false}}
    ]

  defp request_schema(2),
    do: [
      renewers:
        {{:compact_array,
          [
            principal_type: {:compact_string, %{is_nullable?: false}},
            principal_name: {:compact_string, %{is_nullable?: false}},
            tag_buffer: {:tag_buffer, []}
          ]}, %{is_nullable?: false}},
      max_lifetime_ms: {:int64, %{is_nullable?: false}},
      tag_buffer: {:tag_buffer, []}
    ]

  defp request_schema(3),
    do: [
      owner_principal_type: {:compact_string, %{is_nullable?: true}},
      owner_principal_name: {:compact_string, %{is_nullable?: true}},
      renewers:
        {{:compact_array,
          [
            principal_type: {:compact_string, %{is_nullable?: false}},
            principal_name: {:compact_string, %{is_nullable?: false}},
            tag_buffer: {:tag_buffer, []}
          ]}, %{is_nullable?: false}},
      max_lifetime_ms: {:int64, %{is_nullable?: false}},
      tag_buffer: {:tag_buffer, []}
    ]

  defp response_schema(0),
    do: [
      error_code: {:int16, %{is_nullable?: false}},
      principal_type: {:string, %{is_nullable?: false}},
      principal_name: {:string, %{is_nullable?: false}},
      issue_timestamp_ms: {:int64, %{is_nullable?: false}},
      expiry_timestamp_ms: {:int64, %{is_nullable?: false}},
      max_timestamp_ms: {:int64, %{is_nullable?: false}},
      token_id: {:string, %{is_nullable?: false}},
      hmac: {:bytes, %{is_nullable?: false}},
      throttle_time_ms: {:int32, %{is_nullable?: false}}
    ]

  defp response_schema(1),
    do: [
      error_code: {:int16, %{is_nullable?: false}},
      principal_type: {:string, %{is_nullable?: false}},
      principal_name: {:string, %{is_nullable?: false}},
      issue_timestamp_ms: {:int64, %{is_nullable?: false}},
      expiry_timestamp_ms: {:int64, %{is_nullable?: false}},
      max_timestamp_ms: {:int64, %{is_nullable?: false}},
      token_id: {:string, %{is_nullable?: false}},
      hmac: {:bytes, %{is_nullable?: false}},
      throttle_time_ms: {:int32, %{is_nullable?: false}}
    ]

  defp response_schema(2),
    do: [
      error_code: {:int16, %{is_nullable?: false}},
      principal_type: {:compact_string, %{is_nullable?: false}},
      principal_name: {:compact_string, %{is_nullable?: false}},
      issue_timestamp_ms: {:int64, %{is_nullable?: false}},
      expiry_timestamp_ms: {:int64, %{is_nullable?: false}},
      max_timestamp_ms: {:int64, %{is_nullable?: false}},
      token_id: {:compact_string, %{is_nullable?: false}},
      hmac: {:compact_bytes, %{is_nullable?: false}},
      throttle_time_ms: {:int32, %{is_nullable?: false}},
      tag_buffer: {:tag_buffer, %{}}
    ]

  defp response_schema(3),
    do: [
      error_code: {:int16, %{is_nullable?: false}},
      principal_type: {:compact_string, %{is_nullable?: false}},
      principal_name: {:compact_string, %{is_nullable?: false}},
      token_requester_principal_type: {:compact_string, %{is_nullable?: false}},
      token_requester_principal_name: {:compact_string, %{is_nullable?: false}},
      issue_timestamp_ms: {:int64, %{is_nullable?: false}},
      expiry_timestamp_ms: {:int64, %{is_nullable?: false}},
      max_timestamp_ms: {:int64, %{is_nullable?: false}},
      token_id: {:compact_string, %{is_nullable?: false}},
      hmac: {:compact_bytes, %{is_nullable?: false}},
      throttle_time_ms: {:int32, %{is_nullable?: false}},
      tag_buffer: {:tag_buffer, %{}}
    ]
end