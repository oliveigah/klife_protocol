# DO NOT EDIT THIS FILE MANUALLY  
# This module is automatically generated by running mix task generate_file
# every change must be done inside the mix task directly

defmodule KlifeProtocol.Messages.InitProducerId do
  @moduledoc """
  Kafka protocol InitProducerId message

  Request versions summary:   
  - Version 1 is the same as version 0.
  - Version 2 is the first flexible version.
  - Version 3 adds ProducerId and ProducerEpoch, allowing producers to try to resume after an INVALID_PRODUCER_EPOCH error
  - Version 4 adds the support for new error code PRODUCER_FENCED.

  Response versions summary:
  - Starting in version 1, on quota violation, brokers send out responses before throttling.
  - Version 2 is the first flexible version.
  - Version 3 is the same as version 2.
  - Version 4 adds the support for new error code PRODUCER_FENCED.

  """

  alias KlifeProtocol.Deserializer
  alias KlifeProtocol.Serializer
  alias KlifeProtocol.Header

  @api_key 22
  @min_flexible_version_req 2
  @min_flexible_version_res 2

  @doc """
  Content fields:

  - transactional_id: The transactional id, or null if the producer is not transactional. (string | versions 0+)
  - transaction_timeout_ms: The time in ms to wait before aborting idle transactions sent by this producer. This is only relevant if a TransactionalId has been defined. (int32 | versions 0+)
  - producer_id: The producer id. This is used to disambiguate requests if a transactional id is reused following its expiration. (int64 | versions 3+)
  - producer_epoch: The producer's current epoch. This will be checked against the producer epoch on the broker, and the request will return an error if they do not match. (int16 | versions 3+)

  """
  def serialize_request(%{headers: headers, content: content}, version) do
    headers
    |> Map.put(:request_api_key, @api_key)
    |> Map.put(:request_api_version, version)
    |> Header.serialize_request(req_header_version(version))
    |> then(&Serializer.execute(content, request_schema(version), &1))
  end

  @doc """
  Content fields:

  - throttle_time_ms: The duration in milliseconds for which the request was throttled due to a quota violation, or zero if the request did not violate any quota. (int32 | versions 0+)
  - error_code: The error code, or 0 if there was no error. (int16 | versions 0+)
  - producer_id: The current producer id. (int64 | versions 0+)
  - producer_epoch: The current epoch associated with the producer id. (int16 | versions 0+)

  """
  def deserialize_response(data, version) do
    {headers, rest_data} = Header.deserialize_response(data, res_header_version(version))
    {content, <<>>} = Deserializer.execute(rest_data, response_schema(version))

    %{headers: headers, content: content}
  end

  def max_supported_version(), do: 4
  def min_supported_version(), do: 0

  defp req_header_version(msg_version),
    do: if(msg_version >= @min_flexible_version_req, do: 2, else: 1)

  defp res_header_version(msg_version),
    do: if(msg_version >= @min_flexible_version_res, do: 1, else: 0)

  defp request_schema(0),
    do: [
      transactional_id: {:string, %{is_nullable?: true}},
      transaction_timeout_ms: {:int32, %{is_nullable?: false}}
    ]

  defp request_schema(1),
    do: [
      transactional_id: {:string, %{is_nullable?: true}},
      transaction_timeout_ms: {:int32, %{is_nullable?: false}}
    ]

  defp request_schema(2),
    do: [
      transactional_id: {:compact_string, %{is_nullable?: true}},
      transaction_timeout_ms: {:int32, %{is_nullable?: false}},
      tag_buffer: {:tag_buffer, []}
    ]

  defp request_schema(3),
    do: [
      transactional_id: {:compact_string, %{is_nullable?: true}},
      transaction_timeout_ms: {:int32, %{is_nullable?: false}},
      producer_id: {:int64, %{is_nullable?: false}},
      producer_epoch: {:int16, %{is_nullable?: false}},
      tag_buffer: {:tag_buffer, []}
    ]

  defp request_schema(4),
    do: [
      transactional_id: {:compact_string, %{is_nullable?: true}},
      transaction_timeout_ms: {:int32, %{is_nullable?: false}},
      producer_id: {:int64, %{is_nullable?: false}},
      producer_epoch: {:int16, %{is_nullable?: false}},
      tag_buffer: {:tag_buffer, []}
    ]

  defp request_schema(unkown_version),
    do: raise("Unknown version #{unkown_version} for message InitProducerId")

  defp response_schema(0),
    do: [
      throttle_time_ms: {:int32, %{is_nullable?: false}},
      error_code: {:int16, %{is_nullable?: false}},
      producer_id: {:int64, %{is_nullable?: false}},
      producer_epoch: {:int16, %{is_nullable?: false}}
    ]

  defp response_schema(1),
    do: [
      throttle_time_ms: {:int32, %{is_nullable?: false}},
      error_code: {:int16, %{is_nullable?: false}},
      producer_id: {:int64, %{is_nullable?: false}},
      producer_epoch: {:int16, %{is_nullable?: false}}
    ]

  defp response_schema(2),
    do: [
      throttle_time_ms: {:int32, %{is_nullable?: false}},
      error_code: {:int16, %{is_nullable?: false}},
      producer_id: {:int64, %{is_nullable?: false}},
      producer_epoch: {:int16, %{is_nullable?: false}},
      tag_buffer: {:tag_buffer, %{}}
    ]

  defp response_schema(3),
    do: [
      throttle_time_ms: {:int32, %{is_nullable?: false}},
      error_code: {:int16, %{is_nullable?: false}},
      producer_id: {:int64, %{is_nullable?: false}},
      producer_epoch: {:int16, %{is_nullable?: false}},
      tag_buffer: {:tag_buffer, %{}}
    ]

  defp response_schema(4),
    do: [
      throttle_time_ms: {:int32, %{is_nullable?: false}},
      error_code: {:int16, %{is_nullable?: false}},
      producer_id: {:int64, %{is_nullable?: false}},
      producer_epoch: {:int16, %{is_nullable?: false}},
      tag_buffer: {:tag_buffer, %{}}
    ]

  defp response_schema(unkown_version),
    do: raise("Unknown version #{unkown_version} for message InitProducerId")
end