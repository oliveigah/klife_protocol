# DO NOT EDIT THIS FILE MANUALLY
# This module is automatically generated by running mix task generate_file
# every change must be done inside the mix task directly

defmodule KlifeProtocol.Messages.ApiVersions do
  @moduledoc """
  Kafka protocol ApiVersions message

  Request versions summary:
  - Versions 0 through 2 of ApiVersionsRequest are the same.
  - Version 3 is the first flexible version and adds ClientSoftwareName and ClientSoftwareVersion.
  - Version 4 fixes KAFKA-17011, which blocked SupportedFeatures.MinVersion in the response from being 0.

  Response versions summary:
  - Version 1 adds throttle time to the response.
  - Starting in version 2, on quota violation, brokers send out responses before throttling.
  - Version 3 is the first flexible version. Tagged fields are only supported in the body but
  not in the header. The length of the header must not change in order to guarantee the
  backward compatibility.
  - Starting from Apache Kafka 2.4 (KIP-511), ApiKeys field is populated with the supported
  versions of the ApiVersionsRequest when an UNSUPPORTED_VERSION error is returned.
  - Version 4 fixes KAFKA-17011, which blocked SupportedFeatures.MinVersion from being 0.

  """

  alias KlifeProtocol.Deserializer
  alias KlifeProtocol.Serializer
  alias KlifeProtocol.Header

  @api_key 18
  @min_flexible_version_req 3

  @doc """
  Receives a map and serialize it to kafka wire format of the given version.

  Input content fields:
  - client_software_name: The name of the client. (string | versions 3+)
  - client_software_version: The version of the client. (string | versions 3+)

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

  - error_code: The top-level error code. (int16 | versions 0+)
  - api_keys: The APIs supported by the broker. ([]ApiVersion | versions 0+)
      - api_key: The API index. (int16 | versions 0+)
      - min_version: The minimum supported version, inclusive. (int16 | versions 0+)
      - max_version: The maximum supported version, inclusive. (int16 | versions 0+)
  - throttle_time_ms: The duration in milliseconds for which the request was throttled due to a quota violation, or zero if the request did not violate any quota. (int32 | versions 1+)
  - supported_features: Features supported by the broker. Note: in v0-v3, features with MinSupportedVersion = 0 are omitted. ([]SupportedFeatureKey | versions 3+)
      - name: The name of the feature. (string | versions 3+)
      - min_version: The minimum supported version for the feature. (int16 | versions 3+)
      - max_version: The maximum supported version for the feature. (int16 | versions 3+)
  - finalized_features_epoch: The monotonically increasing epoch for the finalized features information. Valid values are >= 0. A value of -1 is special and represents unknown epoch. (int64 | versions 3+)
  - finalized_features: List of cluster-wide finalized features. The information is valid only if FinalizedFeaturesEpoch >= 0. ([]FinalizedFeatureKey | versions 3+)
      - name: The name of the feature. (string | versions 3+)
      - max_version_level: The cluster-wide finalized max version level for the feature. (int16 | versions 3+)
      - min_version_level: The cluster-wide finalized min version level for the feature. (int16 | versions 3+)
  - zk_migration_ready: Set by a KRaft controller if the required configurations for ZK migration are present. (bool | versions 3+)

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

  defp res_header_version(_msg_version), do: 0

  def request_schema(0), do: []
  def request_schema(1), do: []
  def request_schema(2), do: []

  def request_schema(3),
    do: [
      client_software_name: {:compact_string, %{is_nullable?: false}},
      client_software_version: {:compact_string, %{is_nullable?: false}},
      tag_buffer: {:tag_buffer, []}
    ]

  def request_schema(4),
    do: [
      client_software_name: {:compact_string, %{is_nullable?: false}},
      client_software_version: {:compact_string, %{is_nullable?: false}},
      tag_buffer: {:tag_buffer, []}
    ]

  def request_schema(unkown_version),
    do: raise("Unknown version #{unkown_version} for message ApiVersions")

  def response_schema(0),
    do: [
      error_code: {:int16, %{is_nullable?: false}},
      api_keys:
        {{:array,
          [
            api_key: {:int16, %{is_nullable?: false}},
            min_version: {:int16, %{is_nullable?: false}},
            max_version: {:int16, %{is_nullable?: false}}
          ]}, %{is_nullable?: false}}
    ]

  def response_schema(1),
    do: [
      error_code: {:int16, %{is_nullable?: false}},
      api_keys:
        {{:array,
          [
            api_key: {:int16, %{is_nullable?: false}},
            min_version: {:int16, %{is_nullable?: false}},
            max_version: {:int16, %{is_nullable?: false}}
          ]}, %{is_nullable?: false}},
      throttle_time_ms: {:int32, %{is_nullable?: false}}
    ]

  def response_schema(2),
    do: [
      error_code: {:int16, %{is_nullable?: false}},
      api_keys:
        {{:array,
          [
            api_key: {:int16, %{is_nullable?: false}},
            min_version: {:int16, %{is_nullable?: false}},
            max_version: {:int16, %{is_nullable?: false}}
          ]}, %{is_nullable?: false}},
      throttle_time_ms: {:int32, %{is_nullable?: false}}
    ]

  def response_schema(3),
    do: [
      error_code: {:int16, %{is_nullable?: false}},
      api_keys:
        {{:compact_array,
          [
            api_key: {:int16, %{is_nullable?: false}},
            min_version: {:int16, %{is_nullable?: false}},
            max_version: {:int16, %{is_nullable?: false}},
            tag_buffer: {:tag_buffer, %{}}
          ]}, %{is_nullable?: false}},
      throttle_time_ms: {:int32, %{is_nullable?: false}},
      tag_buffer:
        {:tag_buffer,
         %{
           0 =>
             {{:supported_features,
               {:compact_array,
                [
                  name: {:compact_string, %{is_nullable?: false}},
                  min_version: {:int16, %{is_nullable?: false}},
                  max_version: {:int16, %{is_nullable?: false}},
                  tag_buffer: {:tag_buffer, %{}}
                ]}}, %{is_nullable?: false}},
           1 => {{:finalized_features_epoch, :int64}, %{is_nullable?: false}},
           2 =>
             {{:finalized_features,
               {:compact_array,
                [
                  name: {:compact_string, %{is_nullable?: false}},
                  max_version_level: {:int16, %{is_nullable?: false}},
                  min_version_level: {:int16, %{is_nullable?: false}},
                  tag_buffer: {:tag_buffer, %{}}
                ]}}, %{is_nullable?: false}},
           3 => {{:zk_migration_ready, :boolean}, %{is_nullable?: false}}
         }}
    ]

  def response_schema(4),
    do: [
      error_code: {:int16, %{is_nullable?: false}},
      api_keys:
        {{:compact_array,
          [
            api_key: {:int16, %{is_nullable?: false}},
            min_version: {:int16, %{is_nullable?: false}},
            max_version: {:int16, %{is_nullable?: false}},
            tag_buffer: {:tag_buffer, %{}}
          ]}, %{is_nullable?: false}},
      throttle_time_ms: {:int32, %{is_nullable?: false}},
      tag_buffer:
        {:tag_buffer,
         %{
           0 =>
             {{:supported_features,
               {:compact_array,
                [
                  name: {:compact_string, %{is_nullable?: false}},
                  min_version: {:int16, %{is_nullable?: false}},
                  max_version: {:int16, %{is_nullable?: false}},
                  tag_buffer: {:tag_buffer, %{}}
                ]}}, %{is_nullable?: false}},
           1 => {{:finalized_features_epoch, :int64}, %{is_nullable?: false}},
           2 =>
             {{:finalized_features,
               {:compact_array,
                [
                  name: {:compact_string, %{is_nullable?: false}},
                  max_version_level: {:int16, %{is_nullable?: false}},
                  min_version_level: {:int16, %{is_nullable?: false}},
                  tag_buffer: {:tag_buffer, %{}}
                ]}}, %{is_nullable?: false}},
           3 => {{:zk_migration_ready, :boolean}, %{is_nullable?: false}}
         }}
    ]

  def response_schema(unkown_version),
    do: raise("Unknown version #{unkown_version} for message ApiVersions")
end
