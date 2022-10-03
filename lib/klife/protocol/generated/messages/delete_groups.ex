defmodule Klife.Protocol.Messages.DeleteGroups do
  alias Klife.Protocol.Deserializer
  alias Klife.Protocol.Serializer
  alias Klife.Protocol.Header

  def get_api_key(), do: 42

  def request_schema(0), do: [groups_names: {:array, :string}]
  def request_schema(1), do: [groups_names: {:array, :string}]
  def request_schema(2), do: [groups_names: {:array, :string}, tag_buffer: %{}]

  def response_schema(0),
    do: [throttle_time_ms: :int32, results: {:array, [group_id: :string, error_code: :int16]}]

  def response_schema(1),
    do: [throttle_time_ms: :int32, results: {:array, [group_id: :string, error_code: :int16]}]

  def response_schema(2),
    do: [
      throttle_time_ms: :int32,
      results: {:array, [group_id: :string, error_code: :int16, tag_buffer: %{}]},
      tag_buffer: %{}
    ]
end