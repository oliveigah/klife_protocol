defmodule Klife.Protocol.Messages.Vote do
  alias Klife.Protocol.Deserializer
  alias Klife.Protocol.Serializer
  alias Klife.Protocol.Header

  @api_key 52
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
      cluster_id: :compact_string,
      topics:
        {:compact_array,
         [
           topic_name: :compact_string,
           partitions:
             {:compact_array,
              [
                partition_index: :int32,
                candidate_epoch: :int32,
                candidate_id: :int32,
                last_offset_epoch: :int32,
                last_offset: :int64,
                tag_buffer: {:tag_buffer, %{}}
              ]},
           tag_buffer: {:tag_buffer, %{}}
         ]},
      tag_buffer: {:tag_buffer, %{}}
    ]

  defp response_schema(0),
    do: [
      error_code: :int16,
      topics:
        {:compact_array,
         [
           topic_name: :compact_string,
           partitions:
             {:compact_array,
              [
                partition_index: :int32,
                error_code: :int16,
                leader_id: :int32,
                leader_epoch: :int32,
                vote_granted: :boolean,
                tag_buffer: {:tag_buffer, %{}}
              ]},
           tag_buffer: {:tag_buffer, %{}}
         ]},
      tag_buffer: {:tag_buffer, %{}}
    ]
end