defmodule Klife.Protocol.Messages.ApiVersions do
  alias Klife.Protocol.Deserializer
  alias Klife.Protocol.Serializer
  alias Klife.Protocol.Header

  @api_key 18

  def deserialize_response(data, version) do
    with {headers, rest_data} <- Header.deserialize_response(data, 1),
         {content, <<>>} <- Deserializer.execute(rest_data, get_response_schema(version)) do
      %{headers: headers, content: content}
    end
  end

  def serialize_request(input, version) do
    input
    |> Map.put(:request_api_key, @api_key)
    |> Map.put(:request_api_version, version)
    |> Header.serialize_request(2)
    |> then(&Serializer.execute(input, get_request_schema(version), &1))
  end

  defp get_request_schema(0), do: []
  defp get_request_schema(1), do: []
  defp get_request_schema(2), do: []

  defp get_request_schema(3),
    do: [
      client_software_name: :string,
      client_software_version: :string
    ]

  defp get_response_schema(0),
    do: [
      error_code: :int16,
      api_keys: {:array, [api_key: :int16, min_version: :int16, max_version: :int16]}
    ]

  defp get_response_schema(1),
    do: [
      error_code: :int16,
      api_keys: {:array, [api_key: :int16, min_version: :int16, max_version: :int16]},
      throttle_time_ms: :int32
    ]

  defp get_response_schema(2),
    do: [
      error_code: :int16,
      api_keys: {:array, [api_key: :int16, min_version: :int16, max_version: :int16]},
      throttle_time_ms: :int32
    ]
end
