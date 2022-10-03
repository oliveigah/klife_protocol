defmodule Klife.Protocol.Messages.DescribeConfigs do
  alias Klife.Protocol.Deserializer
  alias Klife.Protocol.Serializer
  alias Klife.Protocol.Header

  def get_api_key(), do: 32

  def request_schema(0),
    do: [
      resources:
        {:array,
         [resource_type: :int8, resource_name: :string, configuration_keys: {:array, :string}]}
    ]

  def request_schema(1),
    do: [
      resources:
        {:array,
         [resource_type: :int8, resource_name: :string, configuration_keys: {:array, :string}]},
      include_synonyms: :boolean
    ]

  def request_schema(2),
    do: [
      resources:
        {:array,
         [resource_type: :int8, resource_name: :string, configuration_keys: {:array, :string}]},
      include_synonyms: :boolean
    ]

  def request_schema(3),
    do: [
      resources:
        {:array,
         [resource_type: :int8, resource_name: :string, configuration_keys: {:array, :string}]},
      include_synonyms: :boolean,
      include_documentation: :boolean
    ]

  def request_schema(4),
    do: [
      resources:
        {:array,
         [
           resource_type: :int8,
           resource_name: :string,
           configuration_keys: {:array, :string},
           tag_buffer: %{}
         ]},
      include_synonyms: :boolean,
      include_documentation: :boolean,
      tag_buffer: %{}
    ]

  def response_schema(0),
    do: [
      throttle_time_ms: :int32,
      results:
        {:array,
         [
           error_code: :int16,
           error_message: :string,
           resource_type: :int8,
           resource_name: :string,
           configs:
             {:array,
              [
                name: :string,
                value: :string,
                read_only: :boolean,
                is_default: :boolean,
                is_sensitive: :boolean
              ]}
         ]}
    ]

  def response_schema(1),
    do: [
      throttle_time_ms: :int32,
      results:
        {:array,
         [
           error_code: :int16,
           error_message: :string,
           resource_type: :int8,
           resource_name: :string,
           configs:
             {:array,
              [
                name: :string,
                value: :string,
                read_only: :boolean,
                config_source: :int8,
                is_sensitive: :boolean,
                synonyms: {:array, [name: :string, value: :string, source: :int8]}
              ]}
         ]}
    ]

  def response_schema(2),
    do: [
      throttle_time_ms: :int32,
      results:
        {:array,
         [
           error_code: :int16,
           error_message: :string,
           resource_type: :int8,
           resource_name: :string,
           configs:
             {:array,
              [
                name: :string,
                value: :string,
                read_only: :boolean,
                config_source: :int8,
                is_sensitive: :boolean,
                synonyms: {:array, [name: :string, value: :string, source: :int8]}
              ]}
         ]}
    ]

  def response_schema(3),
    do: [
      throttle_time_ms: :int32,
      results:
        {:array,
         [
           error_code: :int16,
           error_message: :string,
           resource_type: :int8,
           resource_name: :string,
           configs:
             {:array,
              [
                name: :string,
                value: :string,
                read_only: :boolean,
                config_source: :int8,
                is_sensitive: :boolean,
                synonyms: {:array, [name: :string, value: :string, source: :int8]},
                config_type: :int8,
                documentation: :string
              ]}
         ]}
    ]

  def response_schema(4),
    do: [
      throttle_time_ms: :int32,
      results:
        {:array,
         [
           error_code: :int16,
           error_message: :string,
           resource_type: :int8,
           resource_name: :string,
           configs:
             {:array,
              [
                name: :string,
                value: :string,
                read_only: :boolean,
                config_source: :int8,
                is_sensitive: :boolean,
                synonyms:
                  {:array, [name: :string, value: :string, source: :int8, tag_buffer: %{}]},
                config_type: :int8,
                documentation: :string,
                tag_buffer: %{}
              ]},
           tag_buffer: %{}
         ]},
      tag_buffer: %{}
    ]
end