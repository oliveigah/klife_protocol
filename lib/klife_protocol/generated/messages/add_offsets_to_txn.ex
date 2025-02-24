# DO NOT EDIT THIS FILE MANUALLY
# This module is automatically generated by running mix task generate_file
# every change must be done inside the mix task directly

defmodule KlifeProtocol.Messages.AddOffsetsToTxn do
  @moduledoc """
  Kafka protocol AddOffsetsToTxn message

  Request versions summary:
  - Version 1 is the same as version 0.
  - Version 2 adds the support for new error code PRODUCER_FENCED.
  - Version 3 enables flexible versions.
  - Version 4 adds support for new error code TRANSACTION_ABORTABLE (KIP-890).

  Response versions summary:
  - Starting in version 1, on quota violation brokers send out responses before throttling.
  - Version 2 adds the support for new error code PRODUCER_FENCED.
  - Version 3 enables flexible versions.
  - Version 4 adds support for new error code TRANSACTION_ABORTABLE (KIP-890).

  """

  alias KlifeProtocol.Deserializer
  alias KlifeProtocol.Serializer
  alias KlifeProtocol.Header

  @api_key 25
  @min_flexible_version_req 3
  @min_flexible_version_res 3

  @doc """
  Receives a map and serialize it to kafka wire format of the given version.

  Input content fields:
  - transactional_id: The transactional id corresponding to the transaction. (string | versions 0+)
  - producer_id: Current producer id in use by the transactional id. (int64 | versions 0+)
  - producer_epoch: Current epoch associated with the producer id. (int16 | versions 0+)
  - group_id: The unique group identifier. (string | versions 0+)

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
  - error_code: The response error code, or 0 if there was no error. (int16 | versions 0+)

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
      transactional_id: {:string, %{is_nullable?: false}},
      producer_id: {:int64, %{is_nullable?: false}},
      producer_epoch: {:int16, %{is_nullable?: false}},
      group_id: {:string, %{is_nullable?: false}}
    ]

  def request_schema(1),
    do: [
      transactional_id: {:string, %{is_nullable?: false}},
      producer_id: {:int64, %{is_nullable?: false}},
      producer_epoch: {:int16, %{is_nullable?: false}},
      group_id: {:string, %{is_nullable?: false}}
    ]

  def request_schema(2),
    do: [
      transactional_id: {:string, %{is_nullable?: false}},
      producer_id: {:int64, %{is_nullable?: false}},
      producer_epoch: {:int16, %{is_nullable?: false}},
      group_id: {:string, %{is_nullable?: false}}
    ]

  def request_schema(3),
    do: [
      transactional_id: {:compact_string, %{is_nullable?: false}},
      producer_id: {:int64, %{is_nullable?: false}},
      producer_epoch: {:int16, %{is_nullable?: false}},
      group_id: {:compact_string, %{is_nullable?: false}},
      tag_buffer: {:tag_buffer, []}
    ]

  def request_schema(4),
    do: [
      transactional_id: {:compact_string, %{is_nullable?: false}},
      producer_id: {:int64, %{is_nullable?: false}},
      producer_epoch: {:int16, %{is_nullable?: false}},
      group_id: {:compact_string, %{is_nullable?: false}},
      tag_buffer: {:tag_buffer, []}
    ]

  def request_schema(unkown_version),
    do: raise("Unknown version #{unkown_version} for message AddOffsetsToTxn")

  def response_schema(0),
    do: [
      throttle_time_ms: {:int32, %{is_nullable?: false}},
      error_code: {:int16, %{is_nullable?: false}}
    ]

  def response_schema(1),
    do: [
      throttle_time_ms: {:int32, %{is_nullable?: false}},
      error_code: {:int16, %{is_nullable?: false}}
    ]

  def response_schema(2),
    do: [
      throttle_time_ms: {:int32, %{is_nullable?: false}},
      error_code: {:int16, %{is_nullable?: false}}
    ]

  def response_schema(3),
    do: [
      throttle_time_ms: {:int32, %{is_nullable?: false}},
      error_code: {:int16, %{is_nullable?: false}},
      tag_buffer: {:tag_buffer, %{}}
    ]

  def response_schema(4),
    do: [
      throttle_time_ms: {:int32, %{is_nullable?: false}},
      error_code: {:int16, %{is_nullable?: false}},
      tag_buffer: {:tag_buffer, %{}}
    ]

  def response_schema(unkown_version),
    do: raise("Unknown version #{unkown_version} for message AddOffsetsToTxn")
end
