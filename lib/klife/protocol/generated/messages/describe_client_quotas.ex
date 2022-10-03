defmodule Klife.Protocol.Messages.DescribeClientQuotas do
  alias Klife.Protocol.Deserializer
  alias Klife.Protocol.Serializer
  alias Klife.Protocol.Header

  def get_api_key(), do: 48

  def request_schema(0),
    do: [
      components: {:array, [entity_type: :string, match_type: :int8, match: :string]},
      strict: :boolean
    ]

  def request_schema(1),
    do: [
      components:
        {:array, [entity_type: :string, match_type: :int8, match: :string, tag_buffer: %{}]},
      strict: :boolean,
      tag_buffer: %{}
    ]

  def response_schema(0),
    do: [
      throttle_time_ms: :int32,
      error_code: :int16,
      error_message: :string,
      entries:
        {:array,
         [
           entity: {:array, [entity_type: :string, entity_name: :string]},
           values: {:array, [key: :string, value: :float64]}
         ]}
    ]

  def response_schema(1),
    do: [
      throttle_time_ms: :int32,
      error_code: :int16,
      error_message: :string,
      entries:
        {:array,
         [
           entity: {:array, [entity_type: :string, entity_name: :string, tag_buffer: %{}]},
           values: {:array, [key: :string, value: :float64, tag_buffer: %{}]},
           tag_buffer: %{}
         ]},
      tag_buffer: %{}
    ]
end