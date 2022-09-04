defmodule KAFE.Protocol.Messages.ApiVersions do
  alias KAFE.Protocol.Deserializer
  alias KAFE.Protocol.Serializer
  alias KAFE.Protocol.Header

  @api_key 18

  def deserialize_response(data, version) do
    with {headers, rest_data} <- Header.deserialize_response(data, version),
         {content, <<>>} <- Deserializer.execute(rest_data, get_response_schema(version)) do
      %{headers: headers, content: content}
    end
  end

  def serialize_request(input, version) do
    input
    |> Map.put(:request_api_key, @api_key)
    |> Map.put(:request_api_version, version)
    |> Header.serialize_request(version)
    |> then(&Serializer.execute(input, get_request_schema(version), &1))
  end

  defp get_request_schema(0), do: []

  defp get_response_schema(0),
    do: [
      error_code: :int16,
      api_keys: {:array, [api_key: :int16, min_version: :int16, max_version: :int16]}
    ]
end
