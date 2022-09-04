defmodule KAFE.Protocol.Messages.CreateTopics do
  alias KAFE.Protocol.Serializer
  alias KAFE.Protocol.Deserializer

  alias KAFE.Protocol.Header

  @api_key 19

  defp get_request_schema(0),
    do: [
      topics: {
        :array,
        [
          name: :string,
          num_partitions: :int32,
          replication_factor: :int16,
          assignments: {
            :array,
            [partition_index: :int32, brokers_ids: {:array, :int32}]
          },
          configs: {
            :array,
            [name: :string, value: :string]
          }
        ]
      },
      timeout_ms: :int32
    ]

  defp get_response_schema(0),
    do: [
      topics: {
        :array,
        [
          name: :string,
          error_code: :int16
        ]
      }
    ]

  def serialize_request(input, version) do
    input
    |> Map.put(:request_api_key, @api_key)
    |> Map.put(:request_api_version, version)
    |> Header.serialize_request(version)
    |> then(&Serializer.execute(input, get_request_schema(version), &1))
  end

  def deserialize_response(data, version) do
    with {headers, rest_data} <- Header.deserialize_response(data, version),
         {content, <<>>} <- Deserializer.execute(rest_data, get_response_schema(version)) do
      %{headers: headers, content: content}
    end
  end
end
