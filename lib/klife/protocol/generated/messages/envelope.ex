defmodule Klife.Protocol.Messages.Envelope do
  alias Klife.Protocol.Deserializer
  alias Klife.Protocol.Serializer
  alias Klife.Protocol.Header

  def get_api_key(), do: 58

  def request_schema(0),
    do: [
      request_data: :bytes,
      request_principal: :bytes,
      client_host_address: :bytes,
      tag_buffer: %{}
    ]

  def response_schema(0), do: [response_data: :bytes, error_code: :int16, tag_buffer: %{}]
end