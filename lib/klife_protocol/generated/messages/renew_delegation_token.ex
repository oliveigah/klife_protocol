# DO NOT EDIT THIS FILE MANUALLY  
# This module is automatically generated by running mix task generate_file
# every change must be done inside the mix task directly

defmodule KlifeProtocol.Messages.RenewDelegationToken do
  @moduledoc """
  Kafka protocol RenewDelegationToken message

  Request versions summary:   
  - Version 1 is the same as version 0.
  Version 2 adds flexible version support

  Response versions summary:
  - Starting in version 1, on quota violation, brokers send out responses before throttling.
  Version 2 adds flexible version support

  """

  alias KlifeProtocol.Deserializer
  alias KlifeProtocol.Serializer
  alias KlifeProtocol.Header

  @api_key 39
  @min_flexible_version_req 2
  @min_flexible_version_res 2

  @doc """
  Content fields:

  - hmac: The HMAC of the delegation token to be renewed. (bytes | versions 0+)
  - renew_period_ms: The renewal time period in milliseconds. (int64 | versions 0+)

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

  - error_code: The error code, or 0 if there was no error. (int16 | versions 0+)
  - expiry_timestamp_ms: The timestamp in milliseconds at which this token expires. (int64 | versions 0+)
  - throttle_time_ms: The duration in milliseconds for which the request was throttled due to a quota violation, or zero if the request did not violate any quota. (int32 | versions 0+)

  """
  def deserialize_response(data, version) do
    {headers, rest_data} = Header.deserialize_response(data, res_header_version(version))
    {content, <<>>} = Deserializer.execute(rest_data, response_schema(version))

    %{headers: headers, content: content}
  end

  def max_supported_version(), do: 2
  def min_supported_version(), do: 0

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