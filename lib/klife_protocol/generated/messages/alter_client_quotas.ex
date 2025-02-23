# DO NOT EDIT THIS FILE MANUALLY
# This module is automatically generated by running mix task generate_file
# every change must be done inside the mix task directly

defmodule KlifeProtocol.Messages.AlterClientQuotas do
  @moduledoc """
  Kafka protocol AlterClientQuotas message

  Request versions summary:

  Response versions summary:
  - Version 1 enables flexible versions.

  """

  alias KlifeProtocol.Deserializer
  alias KlifeProtocol.Serializer
  alias KlifeProtocol.Header

  @api_key 49
  @min_flexible_version_req 1
  @min_flexible_version_res 1

  @doc """
  Receives a map and serialize it to kafka wire format of the given version.

  Input content fields:
  - entries: The quota configuration entries to alter. ([]EntryData | versions 0+)
      - entity: The quota entity to alter. ([]EntityData | versions 0+)
          - entity_type: The entity type. (string | versions 0+)
          - entity_name: The name of the entity, or null if the default. (string | versions 0+)
      - ops: An individual quota configuration entry to alter. ([]OpData | versions 0+)
          - key: The quota configuration key. (string | versions 0+)
          - value: The value to set, otherwise ignored if the value is to be removed. (float64 | versions 0+)
          - remove: Whether the quota configuration value should be removed, otherwise set. (bool | versions 0+)
  - validate_only: Whether the alteration should be validated, but not performed. (bool | versions 0+)

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

  - throttle_time_ms: The duration in milliseconds for which the request was throttled due to a quota violation, or zero if the request did not violate any quota. (int32 | versions 0+)
  - entries: The quota configuration entries to alter. ([]EntryData | versions 0+)
      - error_code: The error code, or `0` if the quota alteration succeeded. (int16 | versions 0+)
      - error_message: The error message, or `null` if the quota alteration succeeded. (string | versions 0+)
      - entity: The quota entity to alter. ([]EntityData | versions 0+)
          - entity_type: The entity type. (string | versions 0+)
          - entity_name: The name of the entity, or null if the default. (string | versions 0+)

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
      entries:
        {{:array,
          [
            entity:
              {{:array,
                [
                  entity_type: {:string, %{is_nullable?: false}},
                  entity_name: {:string, %{is_nullable?: true}}
                ]}, %{is_nullable?: false}},
            ops:
              {{:array,
                [
                  key: {:string, %{is_nullable?: false}},
                  value: {:float64, %{is_nullable?: false}},
                  remove: {:boolean, %{is_nullable?: false}}
                ]}, %{is_nullable?: false}}
          ]}, %{is_nullable?: false}},
      validate_only: {:boolean, %{is_nullable?: false}}
    ]

  defp request_schema(1),
    do: [
      entries:
        {{:compact_array,
          [
            entity:
              {{:compact_array,
                [
                  entity_type: {:compact_string, %{is_nullable?: false}},
                  entity_name: {:compact_string, %{is_nullable?: true}},
                  tag_buffer: {:tag_buffer, []}
                ]}, %{is_nullable?: false}},
            ops:
              {{:compact_array,
                [
                  key: {:compact_string, %{is_nullable?: false}},
                  value: {:float64, %{is_nullable?: false}},
                  remove: {:boolean, %{is_nullable?: false}},
                  tag_buffer: {:tag_buffer, []}
                ]}, %{is_nullable?: false}},
            tag_buffer: {:tag_buffer, []}
          ]}, %{is_nullable?: false}},
      validate_only: {:boolean, %{is_nullable?: false}},
      tag_buffer: {:tag_buffer, []}
    ]

  defp request_schema(unkown_version),
    do: raise("Unknown version #{unkown_version} for message AlterClientQuotas")

  defp response_schema(0),
    do: [
      throttle_time_ms: {:int32, %{is_nullable?: false}},
      entries:
        {{:array,
          [
            error_code: {:int16, %{is_nullable?: false}},
            error_message: {:string, %{is_nullable?: true}},
            entity:
              {{:array,
                [
                  entity_type: {:string, %{is_nullable?: false}},
                  entity_name: {:string, %{is_nullable?: true}}
                ]}, %{is_nullable?: false}}
          ]}, %{is_nullable?: false}}
    ]

  defp response_schema(1),
    do: [
      throttle_time_ms: {:int32, %{is_nullable?: false}},
      entries:
        {{:compact_array,
          [
            error_code: {:int16, %{is_nullable?: false}},
            error_message: {:compact_string, %{is_nullable?: true}},
            entity:
              {{:compact_array,
                [
                  entity_type: {:compact_string, %{is_nullable?: false}},
                  entity_name: {:compact_string, %{is_nullable?: true}},
                  tag_buffer: {:tag_buffer, %{}}
                ]}, %{is_nullable?: false}},
            tag_buffer: {:tag_buffer, %{}}
          ]}, %{is_nullable?: false}},
      tag_buffer: {:tag_buffer, %{}}
    ]

  defp response_schema(unkown_version),
    do: raise("Unknown version #{unkown_version} for message AlterClientQuotas")
end