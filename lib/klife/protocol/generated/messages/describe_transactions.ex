defmodule Klife.Protocol.Messages.DescribeTransactions do
  alias Klife.Protocol.Deserializer
  alias Klife.Protocol.Serializer
  alias Klife.Protocol.Header

  @api_key 65
  @min_flexible_version_req 0
  @min_flexible_version_res 0

  def deserialize_response(data, version) do
    with {headers, rest_data} <- Header.deserialize_response(data, res_header_version(version)),
         {content, _} <- Deserializer.execute(rest_data, response_schema(version)) do
      %{headers: headers, content: content}
    end
  end

  def serialize_request(input, version) do
    input
    |> Map.put(:request_api_key, @api_key)
    |> Map.put(:request_api_version, version)
    |> Header.serialize_request(req_header_version(version))
    |> then(&Serializer.execute(input, request_schema(version), &1))
  end

  defp req_header_version(msg_version),
    do: if(msg_version >= @min_flexible_version_req, do: 2, else: 1)

  defp res_header_version(msg_version),
    do: if(msg_version >= @min_flexible_version_res, do: 1, else: 0)

  defp request_schema(0),
    do: [transactional_ids: {:compact_array, :compact_string}, tag_buffer: {:tag_buffer, %{}}]

  defp response_schema(0),
    do: [
      throttle_time_ms: :int32,
      transaction_states:
        {:compact_array,
         [
           error_code: :int16,
           transactional_id: :compact_string,
           transaction_state: :compact_string,
           transaction_timeout_ms: :int32,
           transaction_start_time_ms: :int64,
           producer_id: :int64,
           producer_epoch: :int16,
           topics:
             {:compact_array,
              [
                topic: :compact_string,
                partitions: {:compact_array, :int32},
                tag_buffer: {:tag_buffer, %{}}
              ]},
           tag_buffer: {:tag_buffer, %{}}
         ]},
      tag_buffer: {:tag_buffer, %{}}
    ]
end