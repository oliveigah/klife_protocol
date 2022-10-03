defmodule Klife.Protocol.Messages.RenewDelegationToken do
  alias Klife.Protocol.Deserializer
  alias Klife.Protocol.Serializer
  alias Klife.Protocol.Header

  def get_api_key(), do: 39

  def request_schema(0), do: [hmac: :bytes, renew_period_ms: :int64]
  def request_schema(1), do: [hmac: :bytes, renew_period_ms: :int64]
  def request_schema(2), do: [hmac: :bytes, renew_period_ms: :int64, tag_buffer: %{}]

  def response_schema(0),
    do: [error_code: :int16, expiry_timestamp_ms: :int64, throttle_time_ms: :int32]

  def response_schema(1),
    do: [error_code: :int16, expiry_timestamp_ms: :int64, throttle_time_ms: :int32]

  def response_schema(2),
    do: [
      error_code: :int16,
      expiry_timestamp_ms: :int64,
      throttle_time_ms: :int32,
      tag_buffer: %{}
    ]
end