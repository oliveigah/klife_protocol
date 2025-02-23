# DO NOT EDIT THIS FILE MANUALLY
# This module is automatically generated by running mix task generate_file
# every change must be done inside the mix task directly

defmodule KlifeProtocol.Messages.ListGroups do
  @moduledoc """
  Kafka protocol ListGroups message

  Request versions summary:
  - Version 1 and 2 are the same as version 0.
  - Version 3 is the first flexible version.
  - Version 4 adds the StatesFilter field (KIP-518).
  - Version 5 adds the TypesFilter field (KIP-848).

  Response versions summary:
  - Version 1 adds the throttle time.
  - Starting in version 2, on quota violation, brokers send out
  responses before throttling.
  - Version 3 is the first flexible version.
  - Version 4 adds the GroupState field (KIP-518).
  - Version 5 adds the GroupType field (KIP-848).

  """

  alias KlifeProtocol.Deserializer
  alias KlifeProtocol.Serializer
  alias KlifeProtocol.Header

  @api_key 16
  @min_flexible_version_req 3
  @min_flexible_version_res 3

  @doc """
  Receives a map and serialize it to kafka wire format of the given version.

  Input content fields:
  - states_filter: The states of the groups we want to list. If empty, all groups are returned with their state. ([]string | versions 4+)
  - types_filter: The types of the groups we want to list. If empty, all groups are returned with their type. ([]string | versions 5+)

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

  - throttle_time_ms: The duration in milliseconds for which the request was throttled due to a quota violation, or zero if the request did not violate any quota. (int32 | versions 1+)
  - error_code: The error code, or 0 if there was no error. (int16 | versions 0+)
  - groups: Each group in the response. ([]ListedGroup | versions 0+)
      - group_id: The group ID. (string | versions 0+)
      - protocol_type: The group protocol type. (string | versions 0+)
      - group_state: The group state name. (string | versions 4+)
      - group_type: The group type name. (string | versions 5+)

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
  def max_supported_version(), do: 5

  @doc """
  Returns the current min supported version of this message.
  """
  def min_supported_version(), do: 0

  defp req_header_version(msg_version),
    do: if(msg_version >= @min_flexible_version_req, do: 2, else: 1)

  defp res_header_version(msg_version),
    do: if(msg_version >= @min_flexible_version_res, do: 1, else: 0)

  defp request_schema(0), do: []
  defp request_schema(1), do: []
  defp request_schema(2), do: []
  defp request_schema(3), do: [tag_buffer: {:tag_buffer, []}]

  defp request_schema(4),
    do: [
      states_filter: {{:compact_array, :compact_string}, %{is_nullable?: false}},
      tag_buffer: {:tag_buffer, []}
    ]

  defp request_schema(5),
    do: [
      states_filter: {{:compact_array, :compact_string}, %{is_nullable?: false}},
      types_filter: {{:compact_array, :compact_string}, %{is_nullable?: false}},
      tag_buffer: {:tag_buffer, []}
    ]

  defp request_schema(unkown_version),
    do: raise("Unknown version #{unkown_version} for message ListGroups")

  defp response_schema(0),
    do: [
      error_code: {:int16, %{is_nullable?: false}},
      groups:
        {{:array,
          [
            group_id: {:string, %{is_nullable?: false}},
            protocol_type: {:string, %{is_nullable?: false}}
          ]}, %{is_nullable?: false}}
    ]

  defp response_schema(1),
    do: [
      throttle_time_ms: {:int32, %{is_nullable?: false}},
      error_code: {:int16, %{is_nullable?: false}},
      groups:
        {{:array,
          [
            group_id: {:string, %{is_nullable?: false}},
            protocol_type: {:string, %{is_nullable?: false}}
          ]}, %{is_nullable?: false}}
    ]

  defp response_schema(2),
    do: [
      throttle_time_ms: {:int32, %{is_nullable?: false}},
      error_code: {:int16, %{is_nullable?: false}},
      groups:
        {{:array,
          [
            group_id: {:string, %{is_nullable?: false}},
            protocol_type: {:string, %{is_nullable?: false}}
          ]}, %{is_nullable?: false}}
    ]

  defp response_schema(3),
    do: [
      throttle_time_ms: {:int32, %{is_nullable?: false}},
      error_code: {:int16, %{is_nullable?: false}},
      groups:
        {{:compact_array,
          [
            group_id: {:compact_string, %{is_nullable?: false}},
            protocol_type: {:compact_string, %{is_nullable?: false}},
            tag_buffer: {:tag_buffer, %{}}
          ]}, %{is_nullable?: false}},
      tag_buffer: {:tag_buffer, %{}}
    ]

  defp response_schema(4),
    do: [
      throttle_time_ms: {:int32, %{is_nullable?: false}},
      error_code: {:int16, %{is_nullable?: false}},
      groups:
        {{:compact_array,
          [
            group_id: {:compact_string, %{is_nullable?: false}},
            protocol_type: {:compact_string, %{is_nullable?: false}},
            group_state: {:compact_string, %{is_nullable?: false}},
            tag_buffer: {:tag_buffer, %{}}
          ]}, %{is_nullable?: false}},
      tag_buffer: {:tag_buffer, %{}}
    ]

  defp response_schema(5),
    do: [
      throttle_time_ms: {:int32, %{is_nullable?: false}},
      error_code: {:int16, %{is_nullable?: false}},
      groups:
        {{:compact_array,
          [
            group_id: {:compact_string, %{is_nullable?: false}},
            protocol_type: {:compact_string, %{is_nullable?: false}},
            group_state: {:compact_string, %{is_nullable?: false}},
            group_type: {:compact_string, %{is_nullable?: false}},
            tag_buffer: {:tag_buffer, %{}}
          ]}, %{is_nullable?: false}},
      tag_buffer: {:tag_buffer, %{}}
    ]

  defp response_schema(unkown_version),
    do: raise("Unknown version #{unkown_version} for message ListGroups")
end