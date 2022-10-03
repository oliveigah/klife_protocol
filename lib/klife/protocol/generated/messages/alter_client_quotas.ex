defmodule Klife.Protocol.Messages.AlterClientQuotas do
  alias Klife.Protocol.Deserializer
  alias Klife.Protocol.Serializer
  alias Klife.Protocol.Header

  def get_api_key(), do: 49

  def request_schema(0),
    do: [
      entries:
        {:array,
         [
           entity: {:array, [entity_type: :string, entity_name: :string]},
           ops: {:array, [key: :string, value: :float64, remove: :boolean]}
         ]},
      validate_only: :boolean
    ]

  def request_schema(1),
    do: [
      entries:
        {:array,
         [
           entity: {:array, [entity_type: :string, entity_name: :string, tag_buffer: %{}]},
           ops: {:array, [key: :string, value: :float64, remove: :boolean, tag_buffer: %{}]},
           tag_buffer: %{}
         ]},
      validate_only: :boolean,
      tag_buffer: %{}
    ]

  def response_schema(0),
    do: [
      throttle_time_ms: :int32,
      entries:
        {:array,
         [
           error_code: :int16,
           error_message: :string,
           entity: {:array, [entity_type: :string, entity_name: :string]}
         ]}
    ]

  def response_schema(1),
    do: [
      throttle_time_ms: :int32,
      entries:
        {:array,
         [
           error_code: :int16,
           error_message: :string,
           entity: {:array, [entity_type: :string, entity_name: :string, tag_buffer: %{}]},
           tag_buffer: %{}
         ]},
      tag_buffer: %{}
    ]
end