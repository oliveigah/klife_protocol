# DO NOT EDIT THIS FILE MANUALLY
# This module is automatically generated by running mix task generate_file
# every change must be done inside the mix task directly

defmodule KlifeProtocol.Messages.BrokerRegistration do
  @moduledoc """
  Kafka protocol BrokerRegistration message

  Request versions summary:

  Response versions summary:

  """

  alias KlifeProtocol.Deserializer
  alias KlifeProtocol.Serializer
  alias KlifeProtocol.Header

  @api_key 62
  @min_flexible_version_req 0
  @min_flexible_version_res 0

  @doc """
  Receives a map and serialize it to kafka wire format of the given version.

  Input content fields:
  - broker_id: The broker ID. (int32 | versions 0+)
  - cluster_id: The cluster id of the broker process. (string | versions 0+)
  - incarnation_id: The incarnation id of the broker process. (uuid | versions 0+)
  - listeners: The listeners of this broker. ([]Listener | versions 0+)
      - name: The name of the endpoint. (string | versions 0+)
      - host: The hostname. (string | versions 0+)
      - port: The port. (uint16 | versions 0+)
      - security_protocol: The security protocol. (int16 | versions 0+)
  - features: The features on this broker. Note: in v0-v3, features with MinSupportedVersion = 0 are omitted. ([]Feature | versions 0+)
      - name: The feature name. (string | versions 0+)
      - min_supported_version: The minimum supported feature level. (int16 | versions 0+)
      - max_supported_version: The maximum supported feature level. (int16 | versions 0+)
  - rack: The rack which this broker is in. (string | versions 0+)
  - is_migrating_zk_broker: If the required configurations for ZK migration are present, this value is set to true. (bool | versions 1+)
  - log_dirs: Log directories configured in this broker which are available. ([]uuid | versions 2+)
  - previous_broker_epoch: The epoch before a clean shutdown. (int64 | versions 3+)

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
  - error_code: The error code, or 0 if there was no error. (int16 | versions 0+)
  - broker_epoch: The broker's assigned epoch, or -1 if none was assigned. (int64 | versions 0+)

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
  def max_supported_version(), do: 4

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
      broker_id: {:int32, %{is_nullable?: false}},
      cluster_id: {:compact_string, %{is_nullable?: false}},
      incarnation_id: {:uuid, %{is_nullable?: false}},
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
      rack: {:compact_string, %{is_nullable?: true}},
      tag_buffer: {:tag_buffer, []}
    ]

  def request_schema(1),
    do: [
      broker_id: {:int32, %{is_nullable?: false}},
      cluster_id: {:compact_string, %{is_nullable?: false}},
      incarnation_id: {:uuid, %{is_nullable?: false}},
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
      rack: {:compact_string, %{is_nullable?: true}},
      is_migrating_zk_broker: {:boolean, %{is_nullable?: false}},
      tag_buffer: {:tag_buffer, []}
    ]

  def request_schema(2),
    do: [
      broker_id: {:int32, %{is_nullable?: false}},
      cluster_id: {:compact_string, %{is_nullable?: false}},
      incarnation_id: {:uuid, %{is_nullable?: false}},
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
      rack: {:compact_string, %{is_nullable?: true}},
      is_migrating_zk_broker: {:boolean, %{is_nullable?: false}},
      log_dirs: {{:compact_array, :uuid}, %{is_nullable?: false}},
      tag_buffer: {:tag_buffer, []}
    ]

  def request_schema(3),
    do: [
      broker_id: {:int32, %{is_nullable?: false}},
      cluster_id: {:compact_string, %{is_nullable?: false}},
      incarnation_id: {:uuid, %{is_nullable?: false}},
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
      rack: {:compact_string, %{is_nullable?: true}},
      is_migrating_zk_broker: {:boolean, %{is_nullable?: false}},
      log_dirs: {{:compact_array, :uuid}, %{is_nullable?: false}},
      previous_broker_epoch: {:int64, %{is_nullable?: false}},
      tag_buffer: {:tag_buffer, []}
    ]

  def request_schema(4),
    do: [
      broker_id: {:int32, %{is_nullable?: false}},
      cluster_id: {:compact_string, %{is_nullable?: false}},
      incarnation_id: {:uuid, %{is_nullable?: false}},
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
      rack: {:compact_string, %{is_nullable?: true}},
      is_migrating_zk_broker: {:boolean, %{is_nullable?: false}},
      log_dirs: {{:compact_array, :uuid}, %{is_nullable?: false}},
      previous_broker_epoch: {:int64, %{is_nullable?: false}},
      tag_buffer: {:tag_buffer, []}
    ]

  def request_schema(unkown_version),
    do: raise("Unknown version #{unkown_version} for message BrokerRegistration")

  def response_schema(0),
    do: [
      throttle_time_ms: {:int32, %{is_nullable?: false}},
      error_code: {:int16, %{is_nullable?: false}},
      broker_epoch: {:int64, %{is_nullable?: false}},
      tag_buffer: {:tag_buffer, %{}}
    ]

  def response_schema(1),
    do: [
      throttle_time_ms: {:int32, %{is_nullable?: false}},
      error_code: {:int16, %{is_nullable?: false}},
      broker_epoch: {:int64, %{is_nullable?: false}},
      tag_buffer: {:tag_buffer, %{}}
    ]

  def response_schema(2),
    do: [
      throttle_time_ms: {:int32, %{is_nullable?: false}},
      error_code: {:int16, %{is_nullable?: false}},
      broker_epoch: {:int64, %{is_nullable?: false}},
      tag_buffer: {:tag_buffer, %{}}
    ]

  def response_schema(3),
    do: [
      throttle_time_ms: {:int32, %{is_nullable?: false}},
      error_code: {:int16, %{is_nullable?: false}},
      broker_epoch: {:int64, %{is_nullable?: false}},
      tag_buffer: {:tag_buffer, %{}}
    ]

  def response_schema(4),
    do: [
      throttle_time_ms: {:int32, %{is_nullable?: false}},
      error_code: {:int16, %{is_nullable?: false}},
      broker_epoch: {:int64, %{is_nullable?: false}},
      tag_buffer: {:tag_buffer, %{}}
    ]

  def response_schema(unkown_version),
    do: raise("Unknown version #{unkown_version} for message BrokerRegistration")
end
