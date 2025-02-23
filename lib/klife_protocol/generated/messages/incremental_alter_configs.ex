# DO NOT EDIT THIS FILE MANUALLY
# This module is automatically generated by running mix task generate_file
# every change must be done inside the mix task directly

defmodule KlifeProtocol.Messages.IncrementalAlterConfigs do
  @moduledoc """
  Kafka protocol IncrementalAlterConfigs message

  Request versions summary:
  - Version 1 is the first flexible version.

  Response versions summary:
  - Version 1 is the first flexible version.

  """

  alias KlifeProtocol.Deserializer
  alias KlifeProtocol.Serializer
  alias KlifeProtocol.Header

  @api_key 44
  @min_flexible_version_req 1
  @min_flexible_version_res 1

  @doc """
  Receives a map and serialize it to kafka wire format of the given version.

  Input content fields:
  - resources: The incremental updates for each resource. ([]AlterConfigsResource | versions 0+)
      - resource_type: The resource type. (int8 | versions 0+)
      - resource_name: The resource name. (string | versions 0+)
      - configs: The configurations. ([]AlterableConfig | versions 0+)
          - name: The configuration key name. (string | versions 0+)
          - config_operation: The type (Set, Delete, Append, Subtract) of operation. (int8 | versions 0+)
          - value: The value to set for the configuration key. (string | versions 0+)
  - validate_only: True if we should validate the request, but not change the configurations. (bool | versions 0+)

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
  - responses: The responses for each resource. ([]AlterConfigsResourceResponse | versions 0+)
      - error_code: The resource error code. (int16 | versions 0+)
      - error_message: The resource error message, or null if there was no error. (string | versions 0+)
      - resource_type: The resource type. (int8 | versions 0+)
      - resource_name: The resource name. (string | versions 0+)

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
  def max_supported_version(), do: 1

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
      resources:
        {{:array,
          [
            resource_type: {:int8, %{is_nullable?: false}},
            resource_name: {:string, %{is_nullable?: false}},
            configs:
              {{:array,
                [
                  name: {:string, %{is_nullable?: false}},
                  config_operation: {:int8, %{is_nullable?: false}},
                  value: {:string, %{is_nullable?: true}}
                ]}, %{is_nullable?: false}}
          ]}, %{is_nullable?: false}},
      validate_only: {:boolean, %{is_nullable?: false}}
    ]

  defp request_schema(1),
    do: [
      resources:
        {{:compact_array,
          [
            resource_type: {:int8, %{is_nullable?: false}},
            resource_name: {:compact_string, %{is_nullable?: false}},
            configs:
              {{:compact_array,
                [
                  name: {:compact_string, %{is_nullable?: false}},
                  config_operation: {:int8, %{is_nullable?: false}},
                  value: {:compact_string, %{is_nullable?: true}},
                  tag_buffer: {:tag_buffer, []}
                ]}, %{is_nullable?: false}},
            tag_buffer: {:tag_buffer, []}
          ]}, %{is_nullable?: false}},
      validate_only: {:boolean, %{is_nullable?: false}},
      tag_buffer: {:tag_buffer, []}
    ]

  defp request_schema(unkown_version),
    do: raise("Unknown version #{unkown_version} for message IncrementalAlterConfigs")

  defp response_schema(0),
    do: [
      throttle_time_ms: {:int32, %{is_nullable?: false}},
      responses:
        {{:array,
          [
            error_code: {:int16, %{is_nullable?: false}},
            error_message: {:string, %{is_nullable?: true}},
            resource_type: {:int8, %{is_nullable?: false}},
            resource_name: {:string, %{is_nullable?: false}}
          ]}, %{is_nullable?: false}}
    ]

  defp response_schema(1),
    do: [
      throttle_time_ms: {:int32, %{is_nullable?: false}},
      responses:
        {{:compact_array,
          [
            error_code: {:int16, %{is_nullable?: false}},
            error_message: {:compact_string, %{is_nullable?: true}},
            resource_type: {:int8, %{is_nullable?: false}},
            resource_name: {:compact_string, %{is_nullable?: false}},
            tag_buffer: {:tag_buffer, %{}}
          ]}, %{is_nullable?: false}},
      tag_buffer: {:tag_buffer, %{}}
    ]

  defp response_schema(unkown_version),
    do: raise("Unknown version #{unkown_version} for message IncrementalAlterConfigs")
end