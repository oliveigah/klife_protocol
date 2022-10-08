defmodule KlifeProtocol.Messages.WriteTxnMarkers do
  alias KlifeProtocol.Deserializer
  alias KlifeProtocol.Serializer
  alias KlifeProtocol.Header

  @api_key 27
  @min_flexible_version_req 1
  @min_flexible_version_res 1

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
      markers:
        {:array,
         [
           producer_id: :int64,
           producer_epoch: :int16,
           transaction_result: :boolean,
           topics: {:array, [name: :string, partition_indexes: {:array, :int32}]},
           coordinator_epoch: :int32
         ]}
    ]

  defp request_schema(1),
    do: [
      markers:
        {:compact_array,
         [
           producer_id: :int64,
           producer_epoch: :int16,
           transaction_result: :boolean,
           topics:
             {:compact_array,
              [
                name: :compact_string,
                partition_indexes: {:compact_array, :int32},
                tag_buffer: {:tag_buffer, []}
              ]},
           coordinator_epoch: :int32,
           tag_buffer: {:tag_buffer, []}
         ]},
      tag_buffer: {:tag_buffer, []}
    ]

  defp response_schema(0),
    do: [
      markers:
        {:array,
         [
           producer_id: :int64,
           topics:
             {:array,
              [name: :string, partitions: {:array, [partition_index: :int32, error_code: :int16]}]}
         ]}
    ]

  defp response_schema(1),
    do: [
      markers:
        {:compact_array,
         [
           producer_id: :int64,
           topics:
             {:compact_array,
              [
                name: :compact_string,
                partitions:
                  {:compact_array,
                   [partition_index: :int32, error_code: :int16, tag_buffer: {:tag_buffer, %{}}]},
                tag_buffer: {:tag_buffer, %{}}
              ]},
           tag_buffer: {:tag_buffer, %{}}
         ]},
      tag_buffer: {:tag_buffer, %{}}
    ]
end