defmodule Klife.Protocol.Messages.UnregisterBroker do
  alias Klife.Protocol.Deserializer
  alias Klife.Protocol.Serializer
  alias Klife.Protocol.Header

  def get_api_key(), do: 64

  def request_schema(0), do: [broker_id: :int32, tag_buffer: %{}]

  def response_schema(0),
    do: [throttle_time_ms: :int32, error_code: :int16, error_message: :string, tag_buffer: %{}]
end