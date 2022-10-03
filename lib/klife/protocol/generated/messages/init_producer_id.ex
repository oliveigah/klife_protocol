defmodule Klife.Protocol.Messages.InitProducerId do
  alias Klife.Protocol.Deserializer
  alias Klife.Protocol.Serializer
  alias Klife.Protocol.Header

  def get_api_key(), do: 22

  def request_schema(0), do: [transactional_id: :string, transaction_timeout_ms: :int32]
  def request_schema(1), do: [transactional_id: :string, transaction_timeout_ms: :int32]

  def request_schema(2),
    do: [transactional_id: :string, transaction_timeout_ms: :int32, tag_buffer: %{}]

  def request_schema(3),
    do: [
      transactional_id: :string,
      transaction_timeout_ms: :int32,
      producer_id: :int64,
      producer_epoch: :int16,
      tag_buffer: %{}
    ]

  def request_schema(4),
    do: [
      transactional_id: :string,
      transaction_timeout_ms: :int32,
      producer_id: :int64,
      producer_epoch: :int16,
      tag_buffer: %{}
    ]

  def response_schema(0),
    do: [
      throttle_time_ms: :int32,
      error_code: :int16,
      producer_id: :int64,
      producer_epoch: :int16
    ]

  def response_schema(1),
    do: [
      throttle_time_ms: :int32,
      error_code: :int16,
      producer_id: :int64,
      producer_epoch: :int16
    ]

  def response_schema(2),
    do: [
      throttle_time_ms: :int32,
      error_code: :int16,
      producer_id: :int64,
      producer_epoch: :int16,
      tag_buffer: %{}
    ]

  def response_schema(3),
    do: [
      throttle_time_ms: :int32,
      error_code: :int16,
      producer_id: :int64,
      producer_epoch: :int16,
      tag_buffer: %{}
    ]

  def response_schema(4),
    do: [
      throttle_time_ms: :int32,
      error_code: :int16,
      producer_id: :int64,
      producer_epoch: :int16,
      tag_buffer: %{}
    ]
end