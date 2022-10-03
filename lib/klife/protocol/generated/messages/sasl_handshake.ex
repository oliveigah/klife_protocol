defmodule Klife.Protocol.Messages.SaslHandshake do
  alias Klife.Protocol.Deserializer
  alias Klife.Protocol.Serializer
  alias Klife.Protocol.Header

  def get_api_key(), do: 17

  def request_schema(0), do: [mechanism: :string]
  def request_schema(1), do: [mechanism: :string]

  def response_schema(0), do: [error_code: :int16, mechanisms: {:array, :string}]
  def response_schema(1), do: [error_code: :int16, mechanisms: {:array, :string}]
end