defmodule KlifeProtocol.Header do
  alias KlifeProtocol.Deserializer
  alias KlifeProtocol.Serializer

  defp request_schema(0),
    do: [
      request_api_key: {:int16, %{is_nullable?: false}},
      request_api_version: {:int16, %{is_nullable?: false}},
      correlation_id: {:int32, %{is_nullable?: false}}
    ]

  defp request_schema(1),
    do: [
      request_api_key: {:int16, %{is_nullable?: false}},
      request_api_version: {:int16, %{is_nullable?: false}},
      correlation_id: {:int32, %{is_nullable?: false}},
      client_id: {:string, %{is_nullable?: true}}
    ]

  defp request_schema(2),
    do: [
      request_api_key: {:int16, %{is_nullable?: false}},
      request_api_version: {:int16, %{is_nullable?: false}},
      correlation_id: {:int32, %{is_nullable?: false}},
      client_id: {:string, %{is_nullable?: true}},
      tag_buffer: {:tag_buffer, []}
    ]

  defp response_schema(0), do: [correlation_id: {:int32, %{is_nullable?: false}}]

  defp response_schema(1),
    do: [correlation_id: {:int32, %{is_nullable?: false}}, tag_buffer: {:tag_buffer, %{}}]

  def deserialize_response(data, version),
    do: Deserializer.execute(data, response_schema(version))

  def serialize_request(data, version),
    do: Serializer.execute(data, request_schema(version))
end