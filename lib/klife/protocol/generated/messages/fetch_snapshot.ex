defmodule Klife.Protocol.Messages.FetchSnapshot do
  alias Klife.Protocol.Deserializer
  alias Klife.Protocol.Serializer
  alias Klife.Protocol.Header

  @api_key 59
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
      replica_id: :int32,
      max_bytes: :int32,
      topics:
        {:compact_array,
         [
           name: :compact_string,
           partitions:
             {:compact_array,
              [
                partition: :int32,
                current_leader_epoch: :int32,
                snapshot_id:
                  {:object, [end_offset: :int64, epoch: :int32, tag_buffer: {:tag_buffer, %{}}]},
                position: :int64,
                tag_buffer: {:tag_buffer, %{}}
              ]},
           tag_buffer: {:tag_buffer, %{}}
         ]},
      tag_buffer: {:tag_buffer, %{cluster_id: {0, :compact_string}}}
    ]

  defp response_schema(0),
    do: [
      throttle_time_ms: :int32,
      error_code: :int16,
      topics:
        {:compact_array,
         [
           name: :compact_string,
           partitions:
             {:compact_array,
              [
                index: :int32,
                error_code: :int16,
                snapshot_id:
                  {:object, [end_offset: :int64, epoch: :int32, tag_buffer: {:tag_buffer, %{}}]},
                size: :int64,
                position: :int64,
                unaligned_records: :records,
                tag_buffer:
                  {:tag_buffer,
                   %{
                     0 =>
                       {:current_leader,
                        {:object,
                         [leader_id: :int32, leader_epoch: :int32, tag_buffer: {:tag_buffer, %{}}]}}
                   }}
              ]},
           tag_buffer: {:tag_buffer, %{}}
         ]},
      tag_buffer: {:tag_buffer, %{}}
    ]
end