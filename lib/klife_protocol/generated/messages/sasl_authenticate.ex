# DO NOT EDIT THIS FILE MANUALLY
# This module is automatically generated by running mix task generate_file
# every change must be done inside the mix task directly

defmodule KlifeProtocol.Messages.SaslAuthenticate do
  @moduledoc """
  Kafka protocol SaslAuthenticate message

  Request versions summary:
  - Version 1 is the same as version 0.
  Version 2 adds flexible version support

  Response versions summary:
  - Version 1 adds the session lifetime.
  Version 2 adds flexible version support

  """

  alias KlifeProtocol.Deserializer
  alias KlifeProtocol.Serializer
  alias KlifeProtocol.Header

  @api_key 36
  @min_flexible_version_req 2
  @min_flexible_version_res 2

  @doc """
  Receives a map and serialize it to kafka wire format of the given version.

  Input content fields:
  - auth_bytes: The SASL authentication bytes from the client, as defined by the SASL mechanism. (bytes | versions 0+)

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

  - error_code: The error code, or 0 if there was no error. (int16 | versions 0+)
  - error_message: The error message, or null if there was no error. (string | versions 0+)
  - auth_bytes: The SASL authentication bytes from the server, as defined by the SASL mechanism. (bytes | versions 0+)
  - session_lifetime_ms: Number of milliseconds after which only re-authentication over the existing connection to create a new session can occur. (int64 | versions 1+)

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
  def max_supported_version(), do: 2

  @doc """
  Returns the current min supported version of this message.
  """
  def min_supported_version(), do: 0

  defp req_header_version(msg_version),
    do: if(msg_version >= @min_flexible_version_req, do: 2, else: 1)

  defp res_header_version(msg_version),
    do: if(msg_version >= @min_flexible_version_res, do: 1, else: 0)

  defp request_schema(0), do: [auth_bytes: {:bytes, %{is_nullable?: false}}]
  defp request_schema(1), do: [auth_bytes: {:bytes, %{is_nullable?: false}}]

  defp request_schema(2),
    do: [auth_bytes: {:compact_bytes, %{is_nullable?: false}}, tag_buffer: {:tag_buffer, []}]

  defp request_schema(unkown_version),
    do: raise("Unknown version #{unkown_version} for message SaslAuthenticate")

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

  defp response_schema(unkown_version),
    do: raise("Unknown version #{unkown_version} for message SaslAuthenticate")
end