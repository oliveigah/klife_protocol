defmodule Klife.Protocol.Messages.AlterUserScramCredentials do
  alias Klife.Protocol.Deserializer
  alias Klife.Protocol.Serializer
  alias Klife.Protocol.Header

  def get_api_key(), do: 51

  def request_schema(0),
    do: [
      deletions: {:array, [name: :string, mechanism: :int8, tag_buffer: %{}]},
      upsertions:
        {:array,
         [
           name: :string,
           mechanism: :int8,
           iterations: :int32,
           salt: :bytes,
           salted_password: :bytes,
           tag_buffer: %{}
         ]},
      tag_buffer: %{}
    ]

  def response_schema(0),
    do: [
      throttle_time_ms: :int32,
      results:
        {:array, [user: :string, error_code: :int16, error_message: :string, tag_buffer: %{}]},
      tag_buffer: %{}
    ]
end