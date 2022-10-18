defmodule KlifeProtocol.Messages.StopReplica do
  alias KlifeProtocol.Deserializer
  alias KlifeProtocol.Serializer
  alias KlifeProtocol.Header

  @api_key 5
  @min_flexible_version_req 2
  @min_flexible_version_res 2

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
      controller_id: {:int32, %{is_nullable?: false}},
      controller_epoch: {:int32, %{is_nullable?: false}},
      delete_partitions: {:boolean, %{is_nullable?: false}},
      ungrouped_partitions:
        {{:array,
          [
            topic_name: {:string, %{is_nullable?: false}},
            partition_index: {:int32, %{is_nullable?: false}}
          ]}, %{is_nullable?: false}}
    ]

  defp request_schema(1),
    do: [
      controller_id: {:int32, %{is_nullable?: false}},
      controller_epoch: {:int32, %{is_nullable?: false}},
      broker_epoch: {:int64, %{is_nullable?: false}},
      delete_partitions: {:boolean, %{is_nullable?: false}},
      topics:
        {{:array,
          [
            name: {:string, %{is_nullable?: false}},
            partition_indexes: {{:array, :int32}, %{is_nullable?: false}}
          ]}, %{is_nullable?: false}}
    ]

  defp request_schema(2),
    do: [
      controller_id: {:int32, %{is_nullable?: false}},
      controller_epoch: {:int32, %{is_nullable?: false}},
      broker_epoch: {:int64, %{is_nullable?: false}},
      delete_partitions: {:boolean, %{is_nullable?: false}},
      topics:
        {{:compact_array,
          [
            name: {:compact_string, %{is_nullable?: false}},
            partition_indexes: {{:compact_array, :int32}, %{is_nullable?: false}},
            tag_buffer: {:tag_buffer, []}
          ]}, %{is_nullable?: false}},
      tag_buffer: {:tag_buffer, []}
    ]

  defp request_schema(3),
    do: [
      controller_id: {:int32, %{is_nullable?: false}},
      controller_epoch: {:int32, %{is_nullable?: false}},
      broker_epoch: {:int64, %{is_nullable?: false}},
      topic_states:
        {{:compact_array,
          [
            topic_name: {:compact_string, %{is_nullable?: false}},
            partition_states:
              {{:compact_array,
                [
                  partition_index: {:int32, %{is_nullable?: false}},
                  leader_epoch: {:int32, %{is_nullable?: false}},
                  delete_partition: {:boolean, %{is_nullable?: false}},
                  tag_buffer: {:tag_buffer, []}
                ]}, %{is_nullable?: false}},
            tag_buffer: {:tag_buffer, []}
          ]}, %{is_nullable?: false}},
      tag_buffer: {:tag_buffer, []}
    ]

  defp response_schema(0),
    do: [
      error_code: {:int16, %{is_nullable?: false}},
      partition_errors:
        {{:array,
          [
            topic_name: {:string, %{is_nullable?: false}},
            partition_index: {:int32, %{is_nullable?: false}},
            error_code: {:int16, %{is_nullable?: false}}
          ]}, %{is_nullable?: false}}
    ]

  defp response_schema(1),
    do: [
      error_code: {:int16, %{is_nullable?: false}},
      partition_errors:
        {{:array,
          [
            topic_name: {:string, %{is_nullable?: false}},
            partition_index: {:int32, %{is_nullable?: false}},
            error_code: {:int16, %{is_nullable?: false}}
          ]}, %{is_nullable?: false}}
    ]

  defp response_schema(2),
    do: [
      error_code: {:int16, %{is_nullable?: false}},
      partition_errors:
        {{:compact_array,
          [
            topic_name: {:compact_string, %{is_nullable?: false}},
            partition_index: {:int32, %{is_nullable?: false}},
            error_code: {:int16, %{is_nullable?: false}},
            tag_buffer: {:tag_buffer, %{}}
          ]}, %{is_nullable?: false}},
      tag_buffer: {:tag_buffer, %{}}
    ]

  defp response_schema(3),
    do: [
      error_code: {:int16, %{is_nullable?: false}},
      partition_errors:
        {{:compact_array,
          [
            topic_name: {:compact_string, %{is_nullable?: false}},
            partition_index: {:int32, %{is_nullable?: false}},
            error_code: {:int16, %{is_nullable?: false}},
            tag_buffer: {:tag_buffer, %{}}
          ]}, %{is_nullable?: false}},
      tag_buffer: {:tag_buffer, %{}}
    ]
end