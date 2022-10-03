defmodule Klife.Protocol.Messages.DescribeAcls do
  alias Klife.Protocol.Deserializer
  alias Klife.Protocol.Serializer
  alias Klife.Protocol.Header

  def get_api_key(), do: 29

  def request_schema(0),
    do: [
      resource_type_filter: :int8,
      resource_name_filter: :string,
      principal_filter: :string,
      host_filter: :string,
      operation: :int8,
      permission_type: :int8
    ]

  def request_schema(1),
    do: [
      resource_type_filter: :int8,
      resource_name_filter: :string,
      pattern_type_filter: :int8,
      principal_filter: :string,
      host_filter: :string,
      operation: :int8,
      permission_type: :int8
    ]

  def request_schema(2),
    do: [
      resource_type_filter: :int8,
      resource_name_filter: :string,
      pattern_type_filter: :int8,
      principal_filter: :string,
      host_filter: :string,
      operation: :int8,
      permission_type: :int8,
      tag_buffer: %{}
    ]

  def request_schema(3),
    do: [
      resource_type_filter: :int8,
      resource_name_filter: :string,
      pattern_type_filter: :int8,
      principal_filter: :string,
      host_filter: :string,
      operation: :int8,
      permission_type: :int8,
      tag_buffer: %{}
    ]

  def response_schema(0),
    do: [
      throttle_time_ms: :int32,
      error_code: :int16,
      error_message: :string,
      resources:
        {:array,
         [
           resource_type: :int8,
           resource_name: :string,
           acls:
             {:array,
              [principal: :string, host: :string, operation: :int8, permission_type: :int8]}
         ]}
    ]

  def response_schema(1),
    do: [
      throttle_time_ms: :int32,
      error_code: :int16,
      error_message: :string,
      resources:
        {:array,
         [
           resource_type: :int8,
           resource_name: :string,
           pattern_type: :int8,
           acls:
             {:array,
              [principal: :string, host: :string, operation: :int8, permission_type: :int8]}
         ]}
    ]

  def response_schema(2),
    do: [
      throttle_time_ms: :int32,
      error_code: :int16,
      error_message: :string,
      resources:
        {:array,
         [
           resource_type: :int8,
           resource_name: :string,
           pattern_type: :int8,
           acls:
             {:array,
              [
                principal: :string,
                host: :string,
                operation: :int8,
                permission_type: :int8,
                tag_buffer: %{}
              ]},
           tag_buffer: %{}
         ]},
      tag_buffer: %{}
    ]

  def response_schema(3),
    do: [
      throttle_time_ms: :int32,
      error_code: :int16,
      error_message: :string,
      resources:
        {:array,
         [
           resource_type: :int8,
           resource_name: :string,
           pattern_type: :int8,
           acls:
             {:array,
              [
                principal: :string,
                host: :string,
                operation: :int8,
                permission_type: :int8,
                tag_buffer: %{}
              ]},
           tag_buffer: %{}
         ]},
      tag_buffer: %{}
    ]
end