# DO NOT EDIT THIS FILE MANUALLY  
# This module is automatically generated by running mix task generate_file
# every change must be done inside the mix task directly

defmodule KlifeProtocol.Messages.CreateDelegationToken do
  @moduledoc """
  Kafka protocol CreateDelegationToken message

  Request versions summary:   
  - Version 1 is the same as version 0.
  - Version 2 is the first flexible version.
  - Version 3 adds owner principal

  Response versions summary:
  - Starting in version 1, on quota violation, brokers send out responses before throttling.
  - Version 2 is the first flexible version.
  - Version 3 adds token requester details

  """

  alias KlifeProtocol.Deserializer
  alias KlifeProtocol.Serializer
  alias KlifeProtocol.Header

  @api_key 38
  @min_flexible_version_req 2
  @min_flexible_version_res 2

  @doc """
  Receives a map and serialize it to kafka wire format of the given version.

  Input content fields:
  - owner_principal_type: The principal type of the owner of the token. If it's null it defaults to the token request principal. (string | versions 3+)
  - owner_principal_name: The principal name of the owner of the token. If it's null it defaults to the token request principal. (string | versions 3+)
  - renewers: A list of those who are allowed to renew this token before it expires. ([]CreatableRenewers | versions 0+)
      - principal_type: The type of the Kafka principal. (string | versions 0+)
      - principal_name: The name of the Kafka principal. (string | versions 0+)
  - max_lifetime_ms: The maximum lifetime of the token in milliseconds, or -1 to use the server side default. (int64 | versions 0+)

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

  - error_code: The top-level error, or zero if there was no error. (int16 | versions 0+)
  - principal_type: The principal type of the token owner. (string | versions 0+)
  - principal_name: The name of the token owner. (string | versions 0+)
  - token_requester_principal_type: The principal type of the requester of the token. (string | versions 3+)
  - token_requester_principal_name: The principal type of the requester of the token. (string | versions 3+)
  - issue_timestamp_ms: When this token was generated. (int64 | versions 0+)
  - expiry_timestamp_ms: When this token expires. (int64 | versions 0+)
  - max_timestamp_ms: The maximum lifetime of this token. (int64 | versions 0+)
  - token_id: The token UUID. (string | versions 0+)
  - hmac: HMAC of the delegation token. (bytes | versions 0+)
  - throttle_time_ms: The duration in milliseconds for which the request was throttled due to a quota violation, or zero if the request did not violate any quota. (int32 | versions 0+)

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
  def max_supported_version(), do: 3

  @doc """
  Returns the current min supported version of this message.
  """
  def min_supported_version(), do: 0

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

  defp request_schema(unkown_version),
    do: raise("Unknown version #{unkown_version} for message CreateDelegationToken")

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

  defp response_schema(unkown_version),
    do: raise("Unknown version #{unkown_version} for message CreateDelegationToken")
end