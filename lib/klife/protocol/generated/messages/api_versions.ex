defmodule Klife.Protocol.Messages.ApiVersions do
  alias Klife.Protocol.Deserializer
  alias Klife.Protocol.Serializer
  alias Klife.Protocol.Header

  def get_api_key(), do: 18

  def request_schema(0), do: []
  def request_schema(1), do: []
  def request_schema(2), do: []

  def request_schema(3),
    do: [client_software_name: :string, client_software_version: :string, tag_buffer: %{}]

  def response_schema(0),
    do: [
      error_code: :int16,
      api_keys: {:array, [api_key: :int16, min_version: :int16, max_version: :int16]}
    ]

  def response_schema(1),
    do: [
      error_code: :int16,
      api_keys: {:array, [api_key: :int16, min_version: :int16, max_version: :int16]},
      throttle_time_ms: :int32
    ]

  def response_schema(2),
    do: [
      error_code: :int16,
      api_keys: {:array, [api_key: :int16, min_version: :int16, max_version: :int16]},
      throttle_time_ms: :int32
    ]

  def response_schema(3),
    do: [
      error_code: :int16,
      api_keys:
        {:array, [api_key: :int16, min_version: :int16, max_version: :int16, tag_buffer: %{}]},
      throttle_time_ms: :int32,
      tag_buffer: %{
        0 =>
          {:supported_features,
           {:array, [name: :string, min_version: :int16, max_version: :int16, tag_buffer: %{}]}},
        1 => {:finalized_features_epoch, :int64},
        2 =>
          {:finalized_features,
           {:array,
            [name: :string, max_version_level: :int16, min_version_level: :int16, tag_buffer: %{}]}}
      }
    ]
end