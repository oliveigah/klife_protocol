defmodule KlifeProtocol.Header do
  @moduledoc """
  Kafka protocol header
  """

  alias KlifeProtocol.Deserializer
  alias KlifeProtocol.Serializer

  def request_schema(0),
    do: [
      request_api_key: {:int16, %{is_nullable?: false}},
      request_api_version: {:int16, %{is_nullable?: false}},
      correlation_id: {:int32, %{is_nullable?: false}}
    ]

  def request_schema(1),
    do: [
      request_api_key: {:int16, %{is_nullable?: false}},
      request_api_version: {:int16, %{is_nullable?: false}},
      correlation_id: {:int32, %{is_nullable?: false}},
      client_id: {:string, %{is_nullable?: true}}
    ]

  def request_schema(2),
    do: [
      request_api_key: {:int16, %{is_nullable?: false}},
      request_api_version: {:int16, %{is_nullable?: false}},
      correlation_id: {:int32, %{is_nullable?: false}},
      client_id: {:string, %{is_nullable?: true}},
      tag_buffer: {:tag_buffer, []}
    ]

  def response_schema(0), do: [correlation_id: {:int32, %{is_nullable?: false}}]

  def response_schema(1),
    do: [correlation_id: {:int32, %{is_nullable?: false}}, tag_buffer: {:tag_buffer, %{}}]

  @doc """
  Receives a map and serialize it to kafka wire format of the given version.

  Input content fields:
  - request_api_key: The API key of this request. (int16 | versions 0+)
  - request_api_version: The API version of this request. (int16 | versions 0+)
  - correlation_id: The correlation ID of this request. (int32 | versions 0+)
  - client_id: The client ID string. (string | versions 1+)

  """
  def serialize_request(data, version),
    do: Serializer.execute(data, request_schema(version))

  @doc """
  Receive a binary in the kafka wire format and deserialize it into a map and return remaining binary data.

  Response content fields:

  - correlation_id: The correlation ID of this response. (int32 | versions 0+)

  """
  def deserialize_response(data, version),
    do: Deserializer.execute(data, response_schema(version))
end
