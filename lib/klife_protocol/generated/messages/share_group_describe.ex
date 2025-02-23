# DO NOT EDIT THIS FILE MANUALLY
# This module is automatically generated by running mix task generate_file
# every change must be done inside the mix task directly

defmodule KlifeProtocol.Messages.ShareGroupDescribe do
  @moduledoc """
  Kafka protocol ShareGroupDescribe message

  Request versions summary:

  Response versions summary:

  """

  alias KlifeProtocol.Deserializer
  alias KlifeProtocol.Serializer
  alias KlifeProtocol.Header

  @api_key 77
  @min_flexible_version_req 0
  @min_flexible_version_res 0

  @doc """
  Receives a map and serialize it to kafka wire format of the given version.

  Input content fields:
  - group_ids: The ids of the groups to describe ([]string | versions 0+)
  - include_authorized_operations: Whether to include authorized operations. (bool | versions 0+)

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
  - groups: Each described group. ([]DescribedGroup | versions 0+)
      - error_code: The describe error, or 0 if there was no error. (int16 | versions 0+)
      - error_message: The top-level error message, or null if there was no error. (string | versions 0+)
      - group_id: The group ID string. (string | versions 0+)
      - group_state: The group state string, or the empty string. (string | versions 0+)
      - group_epoch: The group epoch. (int32 | versions 0+)
      - assignment_epoch: The assignment epoch. (int32 | versions 0+)
      - assignor_name: The selected assignor. (string | versions 0+)
      - members: The members. ([]Member | versions 0+)
          - member_id: The member ID. (string | versions 0+)
          - rack_id: The member rack ID. (string | versions 0+)
          - member_epoch: The current member epoch. (int32 | versions 0+)
          - client_id: The client ID. (string | versions 0+)
          - client_host: The client host. (string | versions 0+)
          - subscribed_topic_names: The subscribed topic names. ([]string | versions 0+)
          - assignment: The current assignment. (Assignment | versions 0+)
      - authorized_operations: 32-bit bitfield to represent authorized operations for this group. (int32 | versions 0+)

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

  defp request_schema(0),
    do: [
      group_ids: {{:compact_array, :compact_string}, %{is_nullable?: false}},
      include_authorized_operations: {:boolean, %{is_nullable?: false}},
      tag_buffer: {:tag_buffer, []}
    ]

  defp request_schema(unkown_version),
    do: raise("Unknown version #{unkown_version} for message ShareGroupDescribe")

  defp response_schema(0),
    do: [
      throttle_time_ms: {:int32, %{is_nullable?: false}},
      groups:
        {{:compact_array,
          [
            error_code: {:int16, %{is_nullable?: false}},
            error_message: {:compact_string, %{is_nullable?: true}},
            group_id: {:compact_string, %{is_nullable?: false}},
            group_state: {:compact_string, %{is_nullable?: false}},
            group_epoch: {:int32, %{is_nullable?: false}},
            assignment_epoch: {:int32, %{is_nullable?: false}},
            assignor_name: {:compact_string, %{is_nullable?: false}},
            members:
              {{:compact_array,
                [
                  member_id: {:compact_string, %{is_nullable?: false}},
                  rack_id: {:compact_string, %{is_nullable?: true}},
                  member_epoch: {:int32, %{is_nullable?: false}},
                  client_id: {:compact_string, %{is_nullable?: false}},
                  client_host: {:compact_string, %{is_nullable?: false}},
                  subscribed_topic_names:
                    {{:compact_array, :compact_string}, %{is_nullable?: false}},
                  assignment:
                    {{:object,
                      [
                        topic_partitions:
                          {{:compact_array,
                            [
                              topic_id: {:uuid, %{is_nullable?: false}},
                              topic_name: {:compact_string, %{is_nullable?: false}},
                              partitions: {{:compact_array, :int32}, %{is_nullable?: false}},
                              tag_buffer: {:tag_buffer, %{}}
                            ]}, %{is_nullable?: false}},
                        tag_buffer: {:tag_buffer, %{}}
                      ]}, %{is_nullable?: false}},
                  tag_buffer: {:tag_buffer, %{}}
                ]}, %{is_nullable?: false}},
            authorized_operations: {:int32, %{is_nullable?: false}},
            tag_buffer: {:tag_buffer, %{}}
          ]}, %{is_nullable?: false}},
      tag_buffer: {:tag_buffer, %{}}
    ]

  defp response_schema(unkown_version),
    do: raise("Unknown version #{unkown_version} for message ShareGroupDescribe")
end