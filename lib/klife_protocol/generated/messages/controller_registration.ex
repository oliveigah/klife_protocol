# DO NOT EDIT THIS FILE MANUALLY
# This module is automatically generated by running mix task generate_file
# every change must be done inside the mix task directly

defmodule KlifeProtocol.Messages.ControllerRegistration do
  @moduledoc """
  Kafka protocol ControllerRegistration message

  Request versions summary:

  Response versions summary:

  """

  alias KlifeProtocol.Deserializer
  alias KlifeProtocol.Serializer
  alias KlifeProtocol.Header

  @api_key 70
  @min_flexible_version_req 0
  @min_flexible_version_res 0

  @doc """
  Receives a map and serialize it to kafka wire format of the given version.

  Input content fields:
  - controller_id: The ID of the controller to register. (int32 | versions 0+)
  - incarnation_id: The controller incarnation ID, which is unique to each process run. (uuid | versions 0+)
  - zk_migration_ready: Set if the required configurations for ZK migration are present. (bool | versions 0+)
  - listeners: The listeners of this controller. ([]Listener | versions 0+)
      - name: The name of the endpoint. (string | versions 0+)
      - host: The hostname. (string | versions 0+)
      - port: The port. (uint16 | versions 0+)
      - security_protocol: The security protocol. (int16 | versions 0+)
  - features: The features on this controller. ([]Feature | versions 0+)
      - name: The feature name. (string | versions 0+)
      - min_supported_version: The minimum supported feature level. (int16 | versions 0+)
      - max_supported_version: The maximum supported feature level. (int16 | versions 0+)

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

  - throttle_time_ms: Duration in milliseconds for which the request was throttled due to a quota violation, or zero if the request did not violate any quota. (int32 | versions 0+)
  - error_code: The response error code. (int16 | versions 0+)
  - error_message: The response error message, or null if there was no error. (string | versions 0+)

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
  def max_supported_version(), do: 0

  @doc """
  Returns the current min supported version of this message.
  """
  def min_supported_version(), do: 0

  defp req_header_version(msg_version),
    do: if(msg_version >= @min_flexible_version_req, do: 2, else: 1)

  defp res_header_version(msg_version),
    do: if(msg_version >= @min_flexible_version_res, do: 1, else: 0)

  def request_schema(0),
    do: [
      controller_id: {:int32, %{is_nullable?: false}},
      incarnation_id: {:uuid, %{is_nullable?: false}},
      zk_migration_ready: {:boolean, %{is_nullable?: false}},
      listeners:
        {{:compact_array,
          [
            name: {:compact_string, %{is_nullable?: false}},
            host: {:compact_string, %{is_nullable?: false}},
            port: {:uint16, %{is_nullable?: false}},
            security_protocol: {:int16, %{is_nullable?: false}},
            tag_buffer: {:tag_buffer, []}
          ]}, %{is_nullable?: false}},
      features:
        {{:compact_array,
          [
            name: {:compact_string, %{is_nullable?: false}},
            min_supported_version: {:int16, %{is_nullable?: false}},
            max_supported_version: {:int16, %{is_nullable?: false}},
            tag_buffer: {:tag_buffer, []}
          ]}, %{is_nullable?: false}},
      tag_buffer: {:tag_buffer, []}
    ]

  def request_schema(unkown_version),
    do: raise("Unknown version #{unkown_version} for message ControllerRegistration")

  def response_schema(0),
    do: [
      throttle_time_ms: {:int32, %{is_nullable?: false}},
      error_code: {:int16, %{is_nullable?: false}},
      error_message: {:compact_string, %{is_nullable?: true}},
      tag_buffer: {:tag_buffer, %{}}
    ]

  def response_schema(unkown_version),
    do: raise("Unknown version #{unkown_version} for message ControllerRegistration")
end
