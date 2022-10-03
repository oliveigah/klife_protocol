defmodule Klife.Protocol.Messages.ListTransactions do
  alias Klife.Protocol.Deserializer
  alias Klife.Protocol.Serializer
  alias Klife.Protocol.Header

  def get_api_key(), do: 66

  def request_schema(0),
    do: [state_filters: {:array, :string}, producer_id_filters: {:array, :int64}, tag_buffer: %{}]

  def response_schema(0),
    do: [
      throttle_time_ms: :int32,
      error_code: :int16,
      unknown_state_filters: {:array, :string},
      transaction_states:
        {:array,
         [
           transactional_id: :string,
           producer_id: :int64,
           transaction_state: :string,
           tag_buffer: %{}
         ]},
      tag_buffer: %{}
    ]
end