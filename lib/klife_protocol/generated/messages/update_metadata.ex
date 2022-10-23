defmodule KlifeProtocol.Messages.UpdateMetadata do
  alias KlifeProtocol.Deserializer
  alias KlifeProtocol.Serializer
  alias KlifeProtocol.Header

  @api_key 6
  @min_flexible_version_req 6
  @min_flexible_version_res 6

  def serialize_request(%{headers: headers, content: content}, version) do
    headers
    |> Map.put(:request_api_key, @api_key)
    |> Map.put(:request_api_version, version)
    |> Header.serialize_request(req_header_version(version))
    |> then(&Serializer.execute(content, request_schema(version), &1))
  end

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
      controller_id: {:int32, %{is_nullable?: false}},
      controller_epoch: {:int32, %{is_nullable?: false}},
      ungrouped_partition_states:
        {{:array,
          [
            topic_name: {:string, %{is_nullable?: false}},
            partition_index: {:int32, %{is_nullable?: false}},
            controller_epoch: {:int32, %{is_nullable?: false}},
            leader: {:int32, %{is_nullable?: false}},
            leader_epoch: {:int32, %{is_nullable?: false}},
            isr: {{:array, :int32}, %{is_nullable?: false}},
            zk_version: {:int32, %{is_nullable?: false}},
            replicas: {{:array, :int32}, %{is_nullable?: false}}
          ]}, %{is_nullable?: false}},
      live_brokers:
        {{:array,
          [
            id: {:int32, %{is_nullable?: false}},
            v0_host: {:string, %{is_nullable?: false}},
            v0_port: {:int32, %{is_nullable?: false}}
          ]}, %{is_nullable?: false}}
    ]

  defp request_schema(1),
    do: [
      controller_id: {:int32, %{is_nullable?: false}},
      controller_epoch: {:int32, %{is_nullable?: false}},
      ungrouped_partition_states:
        {{:array,
          [
            topic_name: {:string, %{is_nullable?: false}},
            partition_index: {:int32, %{is_nullable?: false}},
            controller_epoch: {:int32, %{is_nullable?: false}},
            leader: {:int32, %{is_nullable?: false}},
            leader_epoch: {:int32, %{is_nullable?: false}},
            isr: {{:array, :int32}, %{is_nullable?: false}},
            zk_version: {:int32, %{is_nullable?: false}},
            replicas: {{:array, :int32}, %{is_nullable?: false}}
          ]}, %{is_nullable?: false}},
      live_brokers:
        {{:array,
          [
            id: {:int32, %{is_nullable?: false}},
            endpoints:
              {{:array,
                [
                  port: {:int32, %{is_nullable?: false}},
                  host: {:string, %{is_nullable?: false}},
                  security_protocol: {:int16, %{is_nullable?: false}}
                ]}, %{is_nullable?: false}}
          ]}, %{is_nullable?: false}}
    ]

  defp request_schema(2),
    do: [
      controller_id: {:int32, %{is_nullable?: false}},
      controller_epoch: {:int32, %{is_nullable?: false}},
      ungrouped_partition_states:
        {{:array,
          [
            topic_name: {:string, %{is_nullable?: false}},
            partition_index: {:int32, %{is_nullable?: false}},
            controller_epoch: {:int32, %{is_nullable?: false}},
            leader: {:int32, %{is_nullable?: false}},
            leader_epoch: {:int32, %{is_nullable?: false}},
            isr: {{:array, :int32}, %{is_nullable?: false}},
            zk_version: {:int32, %{is_nullable?: false}},
            replicas: {{:array, :int32}, %{is_nullable?: false}}
          ]}, %{is_nullable?: false}},
      live_brokers:
        {{:array,
          [
            id: {:int32, %{is_nullable?: false}},
            endpoints:
              {{:array,
                [
                  port: {:int32, %{is_nullable?: false}},
                  host: {:string, %{is_nullable?: false}},
                  security_protocol: {:int16, %{is_nullable?: false}}
                ]}, %{is_nullable?: false}},
            rack: {:string, %{is_nullable?: true}}
          ]}, %{is_nullable?: false}}
    ]

  defp request_schema(3),
    do: [
      controller_id: {:int32, %{is_nullable?: false}},
      controller_epoch: {:int32, %{is_nullable?: false}},
      ungrouped_partition_states:
        {{:array,
          [
            topic_name: {:string, %{is_nullable?: false}},
            partition_index: {:int32, %{is_nullable?: false}},
            controller_epoch: {:int32, %{is_nullable?: false}},
            leader: {:int32, %{is_nullable?: false}},
            leader_epoch: {:int32, %{is_nullable?: false}},
            isr: {{:array, :int32}, %{is_nullable?: false}},
            zk_version: {:int32, %{is_nullable?: false}},
            replicas: {{:array, :int32}, %{is_nullable?: false}}
          ]}, %{is_nullable?: false}},
      live_brokers:
        {{:array,
          [
            id: {:int32, %{is_nullable?: false}},
            endpoints:
              {{:array,
                [
                  port: {:int32, %{is_nullable?: false}},
                  host: {:string, %{is_nullable?: false}},
                  listener: {:string, %{is_nullable?: false}},
                  security_protocol: {:int16, %{is_nullable?: false}}
                ]}, %{is_nullable?: false}},
            rack: {:string, %{is_nullable?: true}}
          ]}, %{is_nullable?: false}}
    ]

  defp request_schema(4),
    do: [
      controller_id: {:int32, %{is_nullable?: false}},
      controller_epoch: {:int32, %{is_nullable?: false}},
      ungrouped_partition_states:
        {{:array,
          [
            topic_name: {:string, %{is_nullable?: false}},
            partition_index: {:int32, %{is_nullable?: false}},
            controller_epoch: {:int32, %{is_nullable?: false}},
            leader: {:int32, %{is_nullable?: false}},
            leader_epoch: {:int32, %{is_nullable?: false}},
            isr: {{:array, :int32}, %{is_nullable?: false}},
            zk_version: {:int32, %{is_nullable?: false}},
            replicas: {{:array, :int32}, %{is_nullable?: false}},
            offline_replicas: {{:array, :int32}, %{is_nullable?: false}}
          ]}, %{is_nullable?: false}},
      live_brokers:
        {{:array,
          [
            id: {:int32, %{is_nullable?: false}},
            endpoints:
              {{:array,
                [
                  port: {:int32, %{is_nullable?: false}},
                  host: {:string, %{is_nullable?: false}},
                  listener: {:string, %{is_nullable?: false}},
                  security_protocol: {:int16, %{is_nullable?: false}}
                ]}, %{is_nullable?: false}},
            rack: {:string, %{is_nullable?: true}}
          ]}, %{is_nullable?: false}}
    ]

  defp request_schema(5),
    do: [
      controller_id: {:int32, %{is_nullable?: false}},
      controller_epoch: {:int32, %{is_nullable?: false}},
      broker_epoch: {:int64, %{is_nullable?: false}},
      topic_states:
        {{:array,
          [
            topic_name: {:string, %{is_nullable?: false}},
            partition_states:
              {{:array,
                [
                  partition_index: {:int32, %{is_nullable?: false}},
                  controller_epoch: {:int32, %{is_nullable?: false}},
                  leader: {:int32, %{is_nullable?: false}},
                  leader_epoch: {:int32, %{is_nullable?: false}},
                  isr: {{:array, :int32}, %{is_nullable?: false}},
                  zk_version: {:int32, %{is_nullable?: false}},
                  replicas: {{:array, :int32}, %{is_nullable?: false}},
                  offline_replicas: {{:array, :int32}, %{is_nullable?: false}}
                ]}, %{is_nullable?: false}}
          ]}, %{is_nullable?: false}},
      live_brokers:
        {{:array,
          [
            id: {:int32, %{is_nullable?: false}},
            endpoints:
              {{:array,
                [
                  port: {:int32, %{is_nullable?: false}},
                  host: {:string, %{is_nullable?: false}},
                  listener: {:string, %{is_nullable?: false}},
                  security_protocol: {:int16, %{is_nullable?: false}}
                ]}, %{is_nullable?: false}},
            rack: {:string, %{is_nullable?: true}}
          ]}, %{is_nullable?: false}}
    ]

  defp request_schema(6),
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
                  controller_epoch: {:int32, %{is_nullable?: false}},
                  leader: {:int32, %{is_nullable?: false}},
                  leader_epoch: {:int32, %{is_nullable?: false}},
                  isr: {{:compact_array, :int32}, %{is_nullable?: false}},
                  zk_version: {:int32, %{is_nullable?: false}},
                  replicas: {{:compact_array, :int32}, %{is_nullable?: false}},
                  offline_replicas: {{:compact_array, :int32}, %{is_nullable?: false}},
                  tag_buffer: {:tag_buffer, []}
                ]}, %{is_nullable?: false}},
            tag_buffer: {:tag_buffer, []}
          ]}, %{is_nullable?: false}},
      live_brokers:
        {{:compact_array,
          [
            id: {:int32, %{is_nullable?: false}},
            endpoints:
              {{:compact_array,
                [
                  port: {:int32, %{is_nullable?: false}},
                  host: {:compact_string, %{is_nullable?: false}},
                  listener: {:compact_string, %{is_nullable?: false}},
                  security_protocol: {:int16, %{is_nullable?: false}},
                  tag_buffer: {:tag_buffer, []}
                ]}, %{is_nullable?: false}},
            rack: {:compact_string, %{is_nullable?: true}},
            tag_buffer: {:tag_buffer, []}
          ]}, %{is_nullable?: false}},
      tag_buffer: {:tag_buffer, []}
    ]

  defp request_schema(7),
    do: [
      controller_id: {:int32, %{is_nullable?: false}},
      controller_epoch: {:int32, %{is_nullable?: false}},
      broker_epoch: {:int64, %{is_nullable?: false}},
      topic_states:
        {{:compact_array,
          [
            topic_name: {:compact_string, %{is_nullable?: false}},
            topic_id: {:uuid, %{is_nullable?: false}},
            partition_states:
              {{:compact_array,
                [
                  partition_index: {:int32, %{is_nullable?: false}},
                  controller_epoch: {:int32, %{is_nullable?: false}},
                  leader: {:int32, %{is_nullable?: false}},
                  leader_epoch: {:int32, %{is_nullable?: false}},
                  isr: {{:compact_array, :int32}, %{is_nullable?: false}},
                  zk_version: {:int32, %{is_nullable?: false}},
                  replicas: {{:compact_array, :int32}, %{is_nullable?: false}},
                  offline_replicas: {{:compact_array, :int32}, %{is_nullable?: false}},
                  tag_buffer: {:tag_buffer, []}
                ]}, %{is_nullable?: false}},
            tag_buffer: {:tag_buffer, []}
          ]}, %{is_nullable?: false}},
      live_brokers:
        {{:compact_array,
          [
            id: {:int32, %{is_nullable?: false}},
            endpoints:
              {{:compact_array,
                [
                  port: {:int32, %{is_nullable?: false}},
                  host: {:compact_string, %{is_nullable?: false}},
                  listener: {:compact_string, %{is_nullable?: false}},
                  security_protocol: {:int16, %{is_nullable?: false}},
                  tag_buffer: {:tag_buffer, []}
                ]}, %{is_nullable?: false}},
            rack: {:compact_string, %{is_nullable?: true}},
            tag_buffer: {:tag_buffer, []}
          ]}, %{is_nullable?: false}},
      tag_buffer: {:tag_buffer, []}
    ]

  defp response_schema(0), do: [error_code: {:int16, %{is_nullable?: false}}]
  defp response_schema(1), do: [error_code: {:int16, %{is_nullable?: false}}]
  defp response_schema(2), do: [error_code: {:int16, %{is_nullable?: false}}]
  defp response_schema(3), do: [error_code: {:int16, %{is_nullable?: false}}]
  defp response_schema(4), do: [error_code: {:int16, %{is_nullable?: false}}]
  defp response_schema(5), do: [error_code: {:int16, %{is_nullable?: false}}]

  defp response_schema(6),
    do: [error_code: {:int16, %{is_nullable?: false}}, tag_buffer: {:tag_buffer, %{}}]

  defp response_schema(7),
    do: [error_code: {:int16, %{is_nullable?: false}}, tag_buffer: {:tag_buffer, %{}}]
end