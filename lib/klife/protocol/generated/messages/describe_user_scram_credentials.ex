defmodule Klife.Protocol.Messages.DescribeUserScramCredentials do
  alias Klife.Protocol.Deserializer
  alias Klife.Protocol.Serializer
  alias Klife.Protocol.Header

  def get_api_key(), do: 50

  def request_schema(0), do: [users: {:array, [name: :string, tag_buffer: %{}]}, tag_buffer: %{}]

  def response_schema(0),
    do: [
      throttle_time_ms: :int32,
      error_code: :int16,
      error_message: :string,
      results:
        {:array,
         [
           user: :string,
           error_code: :int16,
           error_message: :string,
           credential_infos: {:array, [mechanism: :int8, iterations: :int32, tag_buffer: %{}]},
           tag_buffer: %{}
         ]},
      tag_buffer: %{}
    ]
end