defmodule Klife.Protocol.Header do
  alias Klife.Protocol.Deserializer
  alias Klife.Protocol.Serializer

  defp get_request_schema(0),
    do: [
      request_api_key: :int16,
      request_api_version: :int16,
      correlation_id: :int32,
      client_id: :string
    ]

  defp get_request_schema(1),
    do: [
      request_api_key: :int16,
      request_api_version: :int16,
      correlation_id: :int32,
      client_id: :string
    ]

  defp get_request_schema(2),
    do: [
      request_api_key: :int16,
      request_api_version: :int16,
      correlation_id: :int32,
      client_id: :string,
      tags: {:tag_buffer, %{1 => :int32, 2 => :string}}
    ]

  defp get_response_schema(0),
    do: [
      correlation_id: :int32
    ]

  defp get_response_schema(1),
    do: [
      correlation_id: :int32,
      tags: {:tag_buffer, %{1 => :int32, 2 => :string}}
    ]

  def deserialize_response(data, version) do
    Deserializer.execute(data, get_response_schema(version))
  end

  def serialize_request(data, version) do
    Serializer.execute(data, get_request_schema(version))
  end
end
