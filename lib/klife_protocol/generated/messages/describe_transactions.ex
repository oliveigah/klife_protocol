# DO NOT EDIT THIS FILE MANUALLY
# This module is automatically generated by running mix task generate_file
# every change must be done inside the mix task directly

defmodule KlifeProtocol.Messages.DescribeTransactions do
  @moduledoc """
  Kafka protocol DescribeTransactions message

  Request versions summary:

  Response versions summary:

  """

  alias KlifeProtocol.Deserializer
  alias KlifeProtocol.Serializer
  alias KlifeProtocol.Header

  @api_key 65
  @min_flexible_version_req 0
  @min_flexible_version_res 0

  @doc """
  Receives a map and serialize it to kafka wire format of the given version.

  Input content fields:
  - transactional_ids: Array of transactionalIds to include in describe results. If empty, then no results will be returned. ([]string | versions 0+)

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
  - transaction_states:  ([]TransactionState | versions 0+)
      - error_code:  (int16 | versions 0+)
      - transactional_id:  (string | versions 0+)
      - transaction_state:  (string | versions 0+)
      - transaction_timeout_ms:  (int32 | versions 0+)
      - transaction_start_time_ms:  (int64 | versions 0+)
      - producer_id:  (int64 | versions 0+)
      - producer_epoch:  (int16 | versions 0+)
      - topics: The set of partitions included in the current transaction (if active). When a transaction is preparing to commit or abort, this will include only partitions which do not have markers. ([]TopicData | versions 0+)
          - topic:  (string | versions 0+)
          - partitions:  ([]int32 | versions 0+)

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
      transactional_ids: {{:compact_array, :compact_string}, %{is_nullable?: false}},
      tag_buffer: {:tag_buffer, []}
    ]

  def request_schema(unkown_version),
    do: raise("Unknown version #{unkown_version} for message DescribeTransactions")

  def response_schema(0),
    do: [
      throttle_time_ms: {:int32, %{is_nullable?: false}},
      transaction_states:
        {{:compact_array,
          [
            error_code: {:int16, %{is_nullable?: false}},
            transactional_id: {:compact_string, %{is_nullable?: false}},
            transaction_state: {:compact_string, %{is_nullable?: false}},
            transaction_timeout_ms: {:int32, %{is_nullable?: false}},
            transaction_start_time_ms: {:int64, %{is_nullable?: false}},
            producer_id: {:int64, %{is_nullable?: false}},
            producer_epoch: {:int16, %{is_nullable?: false}},
            topics:
              {{:compact_array,
                [
                  topic: {:compact_string, %{is_nullable?: false}},
                  partitions: {{:compact_array, :int32}, %{is_nullable?: false}},
                  tag_buffer: {:tag_buffer, %{}}
                ]}, %{is_nullable?: false}},
            tag_buffer: {:tag_buffer, %{}}
          ]}, %{is_nullable?: false}},
      tag_buffer: {:tag_buffer, %{}}
    ]

  def response_schema(unkown_version),
    do: raise("Unknown version #{unkown_version} for message DescribeTransactions")
end
