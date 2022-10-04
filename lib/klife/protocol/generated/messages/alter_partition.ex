defmodule Klife.Protocol.Messages.AlterPartition do
  alias Klife.Protocol.Deserializer
  alias Klife.Protocol.Serializer
  alias Klife.Protocol.Header

  @api_key 56
  @min_flexible_version_req 0
  @min_flexible_version_res 0

  def deserialize_response(data, version) do
    with {headers, rest_data} <- Header.deserialize_response(data, res_header_version(version)),
         {content, <<>>} <- Deserializer.execute(rest_data, response_schema(version)) do
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
      broker_id: :int32,
      broker_epoch: :int64,
      topics:
        {:array,
         [
           topic_name: :string,
           partitions:
             {:array,
              [
                partition_index: :int32,
                leader_epoch: :int32,
                new_isr: {:array, :int32},
                partition_epoch: :int32,
                tag_buffer: %{}
              ]},
           tag_buffer: %{}
         ]},
      tag_buffer: %{}
    ]

  defp request_schema(1),
    do: [
      broker_id: :int32,
      broker_epoch: :int64,
      topics:
        {:array,
         [
           topic_name: :string,
           partitions:
             {:array,
              [
                partition_index: :int32,
                leader_epoch: :int32,
                new_isr: {:array, :int32},
                leader_recovery_state: :int8,
                partition_epoch: :int32,
                tag_buffer: %{}
              ]},
           tag_buffer: %{}
         ]},
      tag_buffer: %{}
    ]

  defp request_schema(2),
    do: [
      broker_id: :int32,
      broker_epoch: :int64,
      topics:
        {:array,
         [
           topic_id: :uuid,
           partitions:
             {:array,
              [
                partition_index: :int32,
                leader_epoch: :int32,
                new_isr: {:array, :int32},
                leader_recovery_state: :int8,
                partition_epoch: :int32,
                tag_buffer: %{}
              ]},
           tag_buffer: %{}
         ]},
      tag_buffer: %{}
    ]

  defp response_schema(0),
    do: [
      throttle_time_ms: :int32,
      error_code: :int16,
      topics:
        {:array,
         [
           topic_name: :string,
           partitions:
             {:array,
              [
                partition_index: :int32,
                error_code: :int16,
                leader_id: :int32,
                leader_epoch: :int32,
                isr: {:array, :int32},
                partition_epoch: :int32,
                tag_buffer: %{}
              ]},
           tag_buffer: %{}
         ]},
      tag_buffer: %{}
    ]

  defp response_schema(1),
    do: [
      throttle_time_ms: :int32,
      error_code: :int16,
      topics:
        {:array,
         [
           topic_name: :string,
           partitions:
             {:array,
              [
                partition_index: :int32,
                error_code: :int16,
                leader_id: :int32,
                leader_epoch: :int32,
                isr: {:array, :int32},
                leader_recovery_state: :int8,
                partition_epoch: :int32,
                tag_buffer: %{}
              ]},
           tag_buffer: %{}
         ]},
      tag_buffer: %{}
    ]

  defp response_schema(2),
    do: [
      throttle_time_ms: :int32,
      error_code: :int16,
      topics:
        {:array,
         [
           topic_id: :uuid,
           partitions:
             {:array,
              [
                partition_index: :int32,
                error_code: :int16,
                leader_id: :int32,
                leader_epoch: :int32,
                isr: {:array, :int32},
                leader_recovery_state: :int8,
                partition_epoch: :int32,
                tag_buffer: %{}
              ]},
           tag_buffer: %{}
         ]},
      tag_buffer: %{}
    ]
end