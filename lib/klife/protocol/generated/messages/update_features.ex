defmodule Klife.Protocol.Messages.UpdateFeatures do
  alias Klife.Protocol.Deserializer
  alias Klife.Protocol.Serializer
  alias Klife.Protocol.Header

  def get_api_key(), do: 57

  def request_schema(0),
    do: [
      timeout_ms: :int32,
      feature_updates:
        {:array,
         [feature: :string, max_version_level: :int16, allow_downgrade: :boolean, tag_buffer: %{}]},
      tag_buffer: %{}
    ]

  def request_schema(1),
    do: [
      timeout_ms: :int32,
      feature_updates:
        {:array,
         [feature: :string, max_version_level: :int16, upgrade_type: :int8, tag_buffer: %{}]},
      validate_only: :boolean,
      tag_buffer: %{}
    ]

  def response_schema(0),
    do: [
      throttle_time_ms: :int32,
      error_code: :int16,
      error_message: :string,
      results:
        {:array, [feature: :string, error_code: :int16, error_message: :string, tag_buffer: %{}]},
      tag_buffer: %{}
    ]

  def response_schema(1),
    do: [
      throttle_time_ms: :int32,
      error_code: :int16,
      error_message: :string,
      results:
        {:array, [feature: :string, error_code: :int16, error_message: :string, tag_buffer: %{}]},
      tag_buffer: %{}
    ]
end