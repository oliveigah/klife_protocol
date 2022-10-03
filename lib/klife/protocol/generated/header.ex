defmodule Klife.Protocol.Header do
  alias Klife.Protocol.Deserializer
  alias Klife.Protocol.Serializer

  defp request_schema(0),
    do: [request_api_key: :int16, request_api_version: :int16, correlation_id: :int32]

  defp request_schema(1),
    do: [
      request_api_key: :int16,
      request_api_version: :int16,
      correlation_id: :int32,
      client_id: :string
    ]

  defp request_schema(2),
    do: [
      request_api_key: :int16,
      request_api_version: :int16,
      correlation_id: :int32,
      client_id: :string,
      tag_buffer: %{}
    ]

  defp response_schema(0), do: [correlation_id: :int32]
  defp response_schema(1), do: [correlation_id: :int32, tag_buffer: %{}]

  def deserialize_response(data, version),
    do: Deserializer.execute(data, response_schema(version))

  def serialize_request(data, version),
    do: Serializer.execute(data, request_schema(version))
end