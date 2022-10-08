defmodule Klife.Protocol.Messages.LeaderAndIsr do
  alias Klife.Protocol.Deserializer
  alias Klife.Protocol.Serializer
  alias Klife.Protocol.Header

  @api_key 4
  @min_flexible_version_req 4
  @min_flexible_version_res 4

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
    do: [
      controller_id: :int32,
      controller_epoch: :int32,
      ungrouped_partition_states:
        {:array,
         [
           topic_name: :string,
           partition_index: :int32,
           controller_epoch: :int32,
           leader: :int32,
           leader_epoch: :int32,
           isr: {:array, :int32},
           partition_epoch: :int32,
           replicas: {:array, :int32}
         ]},
      live_leaders: {:array, [broker_id: :int32, host_name: :string, port: :int32]}
    ]

  defp request_schema(1),
    do: [
      controller_id: :int32,
      controller_epoch: :int32,
      ungrouped_partition_states:
        {:array,
         [
           topic_name: :string,
           partition_index: :int32,
           controller_epoch: :int32,
           leader: :int32,
           leader_epoch: :int32,
           isr: {:array, :int32},
           partition_epoch: :int32,
           replicas: {:array, :int32},
           is_new: :boolean
         ]},
      live_leaders: {:array, [broker_id: :int32, host_name: :string, port: :int32]}
    ]

  defp request_schema(2),
    do: [
      controller_id: :int32,
      controller_epoch: :int32,
      broker_epoch: :int64,
      topic_states:
        {:array,
         [
           topic_name: :string,
           partition_states:
             {:array,
              [
                partition_index: :int32,
                controller_epoch: :int32,
                leader: :int32,
                leader_epoch: :int32,
                isr: {:array, :int32},
                partition_epoch: :int32,
                replicas: {:array, :int32},
                is_new: :boolean
              ]}
         ]},
      live_leaders: {:array, [broker_id: :int32, host_name: :string, port: :int32]}
    ]

  defp request_schema(3),
    do: [
      controller_id: :int32,
      controller_epoch: :int32,
      broker_epoch: :int64,
      topic_states:
        {:array,
         [
           topic_name: :string,
           partition_states:
             {:array,
              [
                partition_index: :int32,
                controller_epoch: :int32,
                leader: :int32,
                leader_epoch: :int32,
                isr: {:array, :int32},
                partition_epoch: :int32,
                replicas: {:array, :int32},
                adding_replicas: {:array, :int32},
                removing_replicas: {:array, :int32},
                is_new: :boolean
              ]}
         ]},
      live_leaders: {:array, [broker_id: :int32, host_name: :string, port: :int32]}
    ]

  defp request_schema(4),
    do: [
      controller_id: :int32,
      controller_epoch: :int32,
      broker_epoch: :int64,
      topic_states:
        {:compact_array,
         [
           topic_name: :compact_string,
           partition_states:
             {:compact_array,
              [
                partition_index: :int32,
                controller_epoch: :int32,
                leader: :int32,
                leader_epoch: :int32,
                isr: {:compact_array, :int32},
                partition_epoch: :int32,
                replicas: {:compact_array, :int32},
                adding_replicas: {:compact_array, :int32},
                removing_replicas: {:compact_array, :int32},
                is_new: :boolean,
                tag_buffer: {:tag_buffer, []}
              ]},
           tag_buffer: {:tag_buffer, []}
         ]},
      live_leaders:
        {:compact_array,
         [
           broker_id: :int32,
           host_name: :compact_string,
           port: :int32,
           tag_buffer: {:tag_buffer, []}
         ]},
      tag_buffer: {:tag_buffer, []}
    ]

  defp request_schema(5),
    do: [
      controller_id: :int32,
      controller_epoch: :int32,
      broker_epoch: :int64,
      type: :int8,
      topic_states:
        {:compact_array,
         [
           topic_name: :compact_string,
           topic_id: :uuid,
           partition_states:
             {:compact_array,
              [
                partition_index: :int32,
                controller_epoch: :int32,
                leader: :int32,
                leader_epoch: :int32,
                isr: {:compact_array, :int32},
                partition_epoch: :int32,
                replicas: {:compact_array, :int32},
                adding_replicas: {:compact_array, :int32},
                removing_replicas: {:compact_array, :int32},
                is_new: :boolean,
                tag_buffer: {:tag_buffer, []}
              ]},
           tag_buffer: {:tag_buffer, []}
         ]},
      live_leaders:
        {:compact_array,
         [
           broker_id: :int32,
           host_name: :compact_string,
           port: :int32,
           tag_buffer: {:tag_buffer, []}
         ]},
      tag_buffer: {:tag_buffer, []}
    ]

  defp request_schema(6),
    do: [
      controller_id: :int32,
      controller_epoch: :int32,
      broker_epoch: :int64,
      type: :int8,
      topic_states:
        {:compact_array,
         [
           topic_name: :compact_string,
           topic_id: :uuid,
           partition_states:
             {:compact_array,
              [
                partition_index: :int32,
                controller_epoch: :int32,
                leader: :int32,
                leader_epoch: :int32,
                isr: {:compact_array, :int32},
                partition_epoch: :int32,
                replicas: {:compact_array, :int32},
                adding_replicas: {:compact_array, :int32},
                removing_replicas: {:compact_array, :int32},
                is_new: :boolean,
                leader_recovery_state: :int8,
                tag_buffer: {:tag_buffer, []}
              ]},
           tag_buffer: {:tag_buffer, []}
         ]},
      live_leaders:
        {:compact_array,
         [
           broker_id: :int32,
           host_name: :compact_string,
           port: :int32,
           tag_buffer: {:tag_buffer, []}
         ]},
      tag_buffer: {:tag_buffer, []}
    ]

  defp response_schema(0),
    do: [
      error_code: :int16,
      partition_errors:
        {:array, [topic_name: :string, partition_index: :int32, error_code: :int16]}
    ]

  defp response_schema(1), do: [error_code: :int16]
  defp response_schema(2), do: [error_code: :int16]
  defp response_schema(3), do: [error_code: :int16]

  defp response_schema(4),
    do: [
      error_code: :int16,
      partition_errors:
        {:compact_array,
         [
           topic_name: :compact_string,
           partition_index: :int32,
           error_code: :int16,
           tag_buffer: {:tag_buffer, %{}}
         ]},
      tag_buffer: {:tag_buffer, %{}}
    ]

  defp response_schema(5),
    do: [
      error_code: :int16,
      topics:
        {:compact_array,
         [
           topic_id: :uuid,
           partition_errors:
             {:compact_array,
              [partition_index: :int32, error_code: :int16, tag_buffer: {:tag_buffer, %{}}]},
           tag_buffer: {:tag_buffer, %{}}
         ]},
      tag_buffer: {:tag_buffer, %{}}
    ]

  defp response_schema(6),
    do: [
      error_code: :int16,
      topics:
        {:compact_array,
         [
           topic_id: :uuid,
           partition_errors:
             {:compact_array,
              [partition_index: :int32, error_code: :int16, tag_buffer: {:tag_buffer, %{}}]},
           tag_buffer: {:tag_buffer, %{}}
         ]},
      tag_buffer: {:tag_buffer, %{}}
    ]
end