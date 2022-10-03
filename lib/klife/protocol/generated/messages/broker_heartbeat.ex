defmodule Klife.Protocol.Messages.BrokerHeartbeat do
  alias Klife.Protocol.Deserializer
  alias Klife.Protocol.Serializer
  alias Klife.Protocol.Header

  def get_api_key(), do: 63

  def request_schema(0),
    do: [
      broker_id: :int32,
      broker_epoch: :int64,
      current_metadata_offset: :int64,
      want_fence: :boolean,
      want_shut_down: :boolean,
      tag_buffer: %{}
    ]

  def response_schema(0),
    do: [
      throttle_time_ms: :int32,
      error_code: :int16,
      is_caught_up: :boolean,
      is_fenced: :boolean,
      should_shut_down: :boolean,
      tag_buffer: %{}
    ]
end