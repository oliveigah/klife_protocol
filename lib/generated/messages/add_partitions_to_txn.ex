defmodule KlifeProtocol.Messages.AddPartitionsToTxn do
  alias KlifeProtocol.Deserializer
  alias KlifeProtocol.Serializer
  alias KlifeProtocol.Header

  @api_key 24
  @min_flexible_version_req 3
  @min_flexible_version_res 3

  def serialize_request(input, version) do
    input
    |> Map.put(:request_api_key, @api_key)
    |> Map.put(:request_api_version, version)
    |> Header.serialize_request(req_header_version(version))
    |> then(&Serializer.execute(input, request_schema(version), &1))
  end

  def deserialize_response(data, version) do
    with {headers, rest_data} <- Header.deserialize_response(data, res_header_version(version)),
         {content, <<>>} <- Deserializer.execute(rest_data, response_schema(version)) do
      %{headers: headers, content: content}
    end
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
      topics:
        {{:array,
          [
            name: {:string, %{is_nullable?: false}},
            partitions: {{:array, :int32}, %{is_nullable?: false}}
          ]}, %{is_nullable?: false}}
    ]

  defp request_schema(1),
    do: [
      transactional_id: {:string, %{is_nullable?: false}},
      producer_id: {:int64, %{is_nullable?: false}},
      producer_epoch: {:int16, %{is_nullable?: false}},
      topics:
        {{:array,
          [
            name: {:string, %{is_nullable?: false}},
            partitions: {{:array, :int32}, %{is_nullable?: false}}
          ]}, %{is_nullable?: false}}
    ]

  defp request_schema(2),
    do: [
      transactional_id: {:string, %{is_nullable?: false}},
      producer_id: {:int64, %{is_nullable?: false}},
      producer_epoch: {:int16, %{is_nullable?: false}},
      topics:
        {{:array,
          [
            name: {:string, %{is_nullable?: false}},
            partitions: {{:array, :int32}, %{is_nullable?: false}}
          ]}, %{is_nullable?: false}}
    ]

  defp request_schema(3),
    do: [
      transactional_id: {:compact_string, %{is_nullable?: false}},
      producer_id: {:int64, %{is_nullable?: false}},
      producer_epoch: {:int16, %{is_nullable?: false}},
      topics:
        {{:compact_array,
          [
            name: {:compact_string, %{is_nullable?: false}},
            partitions: {{:compact_array, :int32}, %{is_nullable?: false}},
            tag_buffer: {:tag_buffer, []}
          ]}, %{is_nullable?: false}},
      tag_buffer: {:tag_buffer, []}
    ]

  defp response_schema(0),
    do: [
      throttle_time_ms: {:int32, %{is_nullable?: false}},
      results:
        {{:array,
          [
            name: {:string, %{is_nullable?: false}},
            results:
              {{:array,
                [
                  partition_index: {:int32, %{is_nullable?: false}},
                  error_code: {:int16, %{is_nullable?: false}}
                ]}, %{is_nullable?: false}}
          ]}, %{is_nullable?: false}}
    ]

  defp response_schema(1),
    do: [
      throttle_time_ms: {:int32, %{is_nullable?: false}},
      results:
        {{:array,
          [
            name: {:string, %{is_nullable?: false}},
            results:
              {{:array,
                [
                  partition_index: {:int32, %{is_nullable?: false}},
                  error_code: {:int16, %{is_nullable?: false}}
                ]}, %{is_nullable?: false}}
          ]}, %{is_nullable?: false}}
    ]

  defp response_schema(2),
    do: [
      throttle_time_ms: {:int32, %{is_nullable?: false}},
      results:
        {{:array,
          [
            name: {:string, %{is_nullable?: false}},
            results:
              {{:array,
                [
                  partition_index: {:int32, %{is_nullable?: false}},
                  error_code: {:int16, %{is_nullable?: false}}
                ]}, %{is_nullable?: false}}
          ]}, %{is_nullable?: false}}
    ]

  defp response_schema(3),
    do: [
      throttle_time_ms: {:int32, %{is_nullable?: false}},
      results:
        {{:compact_array,
          [
            name: {:compact_string, %{is_nullable?: false}},
            results:
              {{:compact_array,
                [
                  partition_index: {:int32, %{is_nullable?: false}},
                  error_code: {:int16, %{is_nullable?: false}},
                  tag_buffer: {:tag_buffer, %{}}
                ]}, %{is_nullable?: false}},
            tag_buffer: {:tag_buffer, %{}}
          ]}, %{is_nullable?: false}},
      tag_buffer: {:tag_buffer, %{}}
    ]
end