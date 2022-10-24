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

  Response versions summary:
  - Starting in version 1, on quota violation brokers send out responses before throttling.
  - Version 2 adds the support for new error code PRODUCER_FENCED.
  - Version 3 enables flexible versions.

  """

  alias KlifeProtocol.Deserializer
  alias KlifeProtocol.Serializer
  alias KlifeProtocol.Header

  @api_key 25
  @min_flexible_version_req 3
  @min_flexible_version_res 3

  @doc """
  Content fields:

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
  Content fields:

  - throttle_time_ms: Duration in milliseconds for which the request was throttled due to a quota violation, or zero if the request did not violate any quota. (int32 | versions 0+)
  - error_code: The response error code, or 0 if there was no error. (int16 | versions 0+)

  """
  def deserialize_response(data, version) do
    {headers, rest_data} = Header.deserialize_response(data, res_header_version(version))
    {content, <<>>} = Deserializer.execute(rest_data, response_schema(version))

    %{headers: headers, content: content}
  end

  defp req_header_version(msg_version),
    do: if(msg_version >= @min_flexible_version_req, do: 2, else: 1)

  defp res_header_version(msg_version),
    do: if(msg_version >= @min_flexible_version_res, do: 1, else: 0)

  defp request_schema(0),
    do: [
      transactional_id: {:string, %{is_nullable?: false}},
      producer_id: {:int64, %{is_nullable?: false}},
      producer_epoch: {:int16, %{is_nullable?: false}},
      group_id: {:string, %{is_nullable?: false}}
    ]

  defp request_schema(1),
    do: [
      transactional_id: {:string, %{is_nullable?: false}},
      producer_id: {:int64, %{is_nullable?: false}},
      producer_epoch: {:int16, %{is_nullable?: false}},
      group_id: {:string, %{is_nullable?: false}}
    ]

  defp request_schema(2),
    do: [
      transactional_id: {:string, %{is_nullable?: false}},
      producer_id: {:int64, %{is_nullable?: false}},
      producer_epoch: {:int16, %{is_nullable?: false}},
      group_id: {:string, %{is_nullable?: false}}
    ]

  defp request_schema(3),
    do: [
      transactional_id: {:compact_string, %{is_nullable?: false}},
      producer_id: {:int64, %{is_nullable?: false}},
      producer_epoch: {:int16, %{is_nullable?: false}},
      group_id: {:compact_string, %{is_nullable?: false}},
      tag_buffer: {:tag_buffer, []}
    ]

  defp response_schema(0),
    do: [
      throttle_time_ms: {:int32, %{is_nullable?: false}},
      error_code: {:int16, %{is_nullable?: false}}
    ]

  defp response_schema(1),
    do: [
      throttle_time_ms: {:int32, %{is_nullable?: false}},
      error_code: {:int16, %{is_nullable?: false}}
    ]

  defp response_schema(2),
    do: [
      throttle_time_ms: {:int32, %{is_nullable?: false}},
      error_code: {:int16, %{is_nullable?: false}}
    ]

  defp response_schema(3),
    do: [
      throttle_time_ms: {:int32, %{is_nullable?: false}},
      error_code: {:int16, %{is_nullable?: false}},
      tag_buffer: {:tag_buffer, %{}}
    ]
end