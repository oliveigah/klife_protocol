defmodule Klife.Protocol.Messages.DescribeGroups do
  alias Klife.Protocol.Deserializer
  alias Klife.Protocol.Serializer
  alias Klife.Protocol.Header

  def get_api_key(), do: 15

  def request_schema(0), do: [groups: {:array, :string}]
  def request_schema(1), do: [groups: {:array, :string}]
  def request_schema(2), do: [groups: {:array, :string}]
  def request_schema(3), do: [groups: {:array, :string}, include_authorized_operations: :boolean]
  def request_schema(4), do: [groups: {:array, :string}, include_authorized_operations: :boolean]

  def request_schema(5),
    do: [groups: {:array, :string}, include_authorized_operations: :boolean, tag_buffer: %{}]

  def response_schema(0),
    do: [
      groups:
        {:array,
         [
           error_code: :int16,
           group_id: :string,
           group_state: :string,
           protocol_type: :string,
           protocol_data: :string,
           members:
             {:array,
              [
                member_id: :string,
                client_id: :string,
                client_host: :string,
                member_metadata: :bytes,
                member_assignment: :bytes
              ]}
         ]}
    ]

  def response_schema(1),
    do: [
      throttle_time_ms: :int32,
      groups:
        {:array,
         [
           error_code: :int16,
           group_id: :string,
           group_state: :string,
           protocol_type: :string,
           protocol_data: :string,
           members:
             {:array,
              [
                member_id: :string,
                client_id: :string,
                client_host: :string,
                member_metadata: :bytes,
                member_assignment: :bytes
              ]}
         ]}
    ]

  def response_schema(2),
    do: [
      throttle_time_ms: :int32,
      groups:
        {:array,
         [
           error_code: :int16,
           group_id: :string,
           group_state: :string,
           protocol_type: :string,
           protocol_data: :string,
           members:
             {:array,
              [
                member_id: :string,
                client_id: :string,
                client_host: :string,
                member_metadata: :bytes,
                member_assignment: :bytes
              ]}
         ]}
    ]

  def response_schema(3),
    do: [
      throttle_time_ms: :int32,
      groups:
        {:array,
         [
           error_code: :int16,
           group_id: :string,
           group_state: :string,
           protocol_type: :string,
           protocol_data: :string,
           members:
             {:array,
              [
                member_id: :string,
                client_id: :string,
                client_host: :string,
                member_metadata: :bytes,
                member_assignment: :bytes
              ]},
           authorized_operations: :int32
         ]}
    ]

  def response_schema(4),
    do: [
      throttle_time_ms: :int32,
      groups:
        {:array,
         [
           error_code: :int16,
           group_id: :string,
           group_state: :string,
           protocol_type: :string,
           protocol_data: :string,
           members:
             {:array,
              [
                member_id: :string,
                group_instance_id: :string,
                client_id: :string,
                client_host: :string,
                member_metadata: :bytes,
                member_assignment: :bytes
              ]},
           authorized_operations: :int32
         ]}
    ]

  def response_schema(5),
    do: [
      throttle_time_ms: :int32,
      groups:
        {:array,
         [
           error_code: :int16,
           group_id: :string,
           group_state: :string,
           protocol_type: :string,
           protocol_data: :string,
           members:
             {:array,
              [
                member_id: :string,
                group_instance_id: :string,
                client_id: :string,
                client_host: :string,
                member_metadata: :bytes,
                member_assignment: :bytes,
                tag_buffer: %{}
              ]},
           authorized_operations: :int32,
           tag_buffer: %{}
         ]},
      tag_buffer: %{}
    ]
end