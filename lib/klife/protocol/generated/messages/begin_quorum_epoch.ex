defmodule Klife.Protocol.Messages.BeginQuorumEpoch do
  alias Klife.Protocol.Deserializer
  alias Klife.Protocol.Serializer
  alias Klife.Protocol.Header

  @api_key 53
  @min_flexible_version_req :none
  @min_flexible_version_res :none

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
      cluster_id: :string,
      topics:
        {:array,
         [
           topic_name: :string,
           partitions:
             {:array, [partition_index: :int32, leader_id: :int32, leader_epoch: :int32]}
         ]}
    ]

  defp response_schema(0),
    do: [
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
                leader_epoch: :int32
              ]}
         ]}
    ]
end