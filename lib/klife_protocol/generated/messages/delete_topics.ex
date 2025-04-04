# DO NOT EDIT THIS FILE MANUALLY
# This module is automatically generated by running mix task generate_file
# every change must be done inside the mix task directly

defmodule KlifeProtocol.Messages.DeleteTopics do
  @moduledoc """
  Kafka protocol DeleteTopics message

  Request versions summary:
  - Version 0 was removed in Apache Kafka 4.0, Version 1 is the new baseline.
  Versions 0, 1, 2, and 3 are the same.
  - Version 4 is the first flexible version.
  - Version 5 adds ErrorMessage in the response and may return a THROTTLING_QUOTA_EXCEEDED error
  in the response if the topics deletion is throttled (KIP-599).
  - Version 6 reorganizes topics, adds topic IDs and allows topic names to be null.

  Response versions summary:
  - Version 0 was removed in Apache Kafka 4.0, Version 1 is the new baseline.
  - Version 1 adds the throttle time.
  - Starting in version 2, on quota violation, brokers send out responses before throttling.
  - Starting in version 3, a TOPIC_DELETION_DISABLED error code may be returned.
  - Version 4 is the first flexible version.
  - Version 5 adds ErrorMessage in the response and may return a THROTTLING_QUOTA_EXCEEDED error
  in the response if the topics deletion is throttled (KIP-599).
  - Version 6 adds topic ID to responses. An UNSUPPORTED_VERSION error code will be returned when attempting to
  delete using topic IDs when IBP < 2.8. UNKNOWN_TOPIC_ID error code will be returned when IBP is at least 2.8, but
  the topic ID was not found.

  """

  alias KlifeProtocol.Deserializer
  alias KlifeProtocol.Serializer
  alias KlifeProtocol.Header

  @api_key 20
  @min_flexible_version_req 4
  @min_flexible_version_res 4

  @doc """
  Receives a map and serialize it to kafka wire format of the given version.

  Input content fields:
  - topics: The name or topic ID of the topic. ([]DeleteTopicState | versions 6+)
      - name: The topic name. (string | versions 6+)
      - topic_id: The unique topic ID. (uuid | versions 6+)
  - topic_names: The names of the topics to delete. ([]string | versions 0-5)
  - timeout_ms: The length of time in milliseconds to wait for the deletions to complete. (int32 | versions 0+)

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
  - responses: The results for each topic we tried to delete. ([]DeletableTopicResult | versions 0+)
      - name: The topic name. (string | versions 0+)
      - topic_id: The unique topic ID. (uuid | versions 6+)
      - error_code: The deletion error, or 0 if the deletion succeeded. (int16 | versions 0+)
      - error_message: The error message, or null if there was no error. (string | versions 5+)

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
  def max_supported_version(), do: 6

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
      topic_names: {{:array, :string}, %{is_nullable?: false}},
      timeout_ms: {:int32, %{is_nullable?: false}}
    ]

  def request_schema(1),
    do: [
      topic_names: {{:array, :string}, %{is_nullable?: false}},
      timeout_ms: {:int32, %{is_nullable?: false}}
    ]

  def request_schema(2),
    do: [
      topic_names: {{:array, :string}, %{is_nullable?: false}},
      timeout_ms: {:int32, %{is_nullable?: false}}
    ]

  def request_schema(3),
    do: [
      topic_names: {{:array, :string}, %{is_nullable?: false}},
      timeout_ms: {:int32, %{is_nullable?: false}}
    ]

  def request_schema(4),
    do: [
      topic_names: {{:compact_array, :compact_string}, %{is_nullable?: false}},
      timeout_ms: {:int32, %{is_nullable?: false}},
      tag_buffer: {:tag_buffer, []}
    ]

  def request_schema(5),
    do: [
      topic_names: {{:compact_array, :compact_string}, %{is_nullable?: false}},
      timeout_ms: {:int32, %{is_nullable?: false}},
      tag_buffer: {:tag_buffer, []}
    ]

  def request_schema(6),
    do: [
      topics:
        {{:compact_array,
          [
            name: {:compact_string, %{is_nullable?: true}},
            topic_id: {:uuid, %{is_nullable?: false}},
            tag_buffer: {:tag_buffer, []}
          ]}, %{is_nullable?: false}},
      timeout_ms: {:int32, %{is_nullable?: false}},
      tag_buffer: {:tag_buffer, []}
    ]

  def request_schema(unkown_version),
    do: raise("Unknown version #{unkown_version} for message DeleteTopics")

  def response_schema(0),
    do: [
      responses:
        {{:array,
          [name: {:string, %{is_nullable?: false}}, error_code: {:int16, %{is_nullable?: false}}]},
         %{is_nullable?: false}}
    ]

  def response_schema(1),
    do: [
      throttle_time_ms: {:int32, %{is_nullable?: false}},
      responses:
        {{:array,
          [name: {:string, %{is_nullable?: false}}, error_code: {:int16, %{is_nullable?: false}}]},
         %{is_nullable?: false}}
    ]

  def response_schema(2),
    do: [
      throttle_time_ms: {:int32, %{is_nullable?: false}},
      responses:
        {{:array,
          [name: {:string, %{is_nullable?: false}}, error_code: {:int16, %{is_nullable?: false}}]},
         %{is_nullable?: false}}
    ]

  def response_schema(3),
    do: [
      throttle_time_ms: {:int32, %{is_nullable?: false}},
      responses:
        {{:array,
          [name: {:string, %{is_nullable?: false}}, error_code: {:int16, %{is_nullable?: false}}]},
         %{is_nullable?: false}}
    ]

  def response_schema(4),
    do: [
      throttle_time_ms: {:int32, %{is_nullable?: false}},
      responses:
        {{:compact_array,
          [
            name: {:compact_string, %{is_nullable?: false}},
            error_code: {:int16, %{is_nullable?: false}},
            tag_buffer: {:tag_buffer, %{}}
          ]}, %{is_nullable?: false}},
      tag_buffer: {:tag_buffer, %{}}
    ]

  def response_schema(5),
    do: [
      throttle_time_ms: {:int32, %{is_nullable?: false}},
      responses:
        {{:compact_array,
          [
            name: {:compact_string, %{is_nullable?: false}},
            error_code: {:int16, %{is_nullable?: false}},
            error_message: {:compact_string, %{is_nullable?: true}},
            tag_buffer: {:tag_buffer, %{}}
          ]}, %{is_nullable?: false}},
      tag_buffer: {:tag_buffer, %{}}
    ]

  def response_schema(6),
    do: [
      throttle_time_ms: {:int32, %{is_nullable?: false}},
      responses:
        {{:compact_array,
          [
            name: {:compact_string, %{is_nullable?: true}},
            topic_id: {:uuid, %{is_nullable?: false}},
            error_code: {:int16, %{is_nullable?: false}},
            error_message: {:compact_string, %{is_nullable?: true}},
            tag_buffer: {:tag_buffer, %{}}
          ]}, %{is_nullable?: false}},
      tag_buffer: {:tag_buffer, %{}}
    ]

  def response_schema(unkown_version),
    do: raise("Unknown version #{unkown_version} for message DeleteTopics")
end
