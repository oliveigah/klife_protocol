defmodule Klife.Protocol.Messages.SaslAuthenticate do
  alias Klife.Protocol.Deserializer
  alias Klife.Protocol.Serializer
  alias Klife.Protocol.Header

  def get_api_key(), do: 36

  def request_schema(0), do: [auth_bytes: :bytes]
  def request_schema(1), do: [auth_bytes: :bytes]
  def request_schema(2), do: [auth_bytes: :bytes, tag_buffer: %{}]

  def response_schema(0), do: [error_code: :int16, error_message: :string, auth_bytes: :bytes]

  def response_schema(1),
    do: [
      error_code: :int16,
      error_message: :string,
      auth_bytes: :bytes,
      session_lifetime_ms: :int64
    ]

  def response_schema(2),
    do: [
      error_code: :int16,
      error_message: :string,
      auth_bytes: :bytes,
      session_lifetime_ms: :int64,
      tag_buffer: %{}
    ]
end