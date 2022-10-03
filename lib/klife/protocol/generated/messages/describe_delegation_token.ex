defmodule Klife.Protocol.Messages.DescribeDelegationToken do
  alias Klife.Protocol.Deserializer
  alias Klife.Protocol.Serializer
  alias Klife.Protocol.Header

  def get_api_key(), do: 41

  def request_schema(0),
    do: [owners: {:array, [principal_type: :string, principal_name: :string]}]

  def request_schema(1),
    do: [owners: {:array, [principal_type: :string, principal_name: :string]}]

  def request_schema(2),
    do: [
      owners: {:array, [principal_type: :string, principal_name: :string, tag_buffer: %{}]},
      tag_buffer: %{}
    ]

  def request_schema(3),
    do: [
      owners: {:array, [principal_type: :string, principal_name: :string, tag_buffer: %{}]},
      tag_buffer: %{}
    ]

  def response_schema(0),
    do: [
      error_code: :int16,
      tokens:
        {:array,
         [
           principal_type: :string,
           principal_name: :string,
           issue_timestamp: :int64,
           expiry_timestamp: :int64,
           max_timestamp: :int64,
           token_id: :string,
           hmac: :bytes,
           renewers: {:array, [principal_type: :string, principal_name: :string]}
         ]},
      throttle_time_ms: :int32
    ]

  def response_schema(1),
    do: [
      error_code: :int16,
      tokens:
        {:array,
         [
           principal_type: :string,
           principal_name: :string,
           issue_timestamp: :int64,
           expiry_timestamp: :int64,
           max_timestamp: :int64,
           token_id: :string,
           hmac: :bytes,
           renewers: {:array, [principal_type: :string, principal_name: :string]}
         ]},
      throttle_time_ms: :int32
    ]

  def response_schema(2),
    do: [
      error_code: :int16,
      tokens:
        {:array,
         [
           principal_type: :string,
           principal_name: :string,
           issue_timestamp: :int64,
           expiry_timestamp: :int64,
           max_timestamp: :int64,
           token_id: :string,
           hmac: :bytes,
           renewers:
             {:array, [principal_type: :string, principal_name: :string, tag_buffer: %{}]},
           tag_buffer: %{}
         ]},
      throttle_time_ms: :int32,
      tag_buffer: %{}
    ]

  def response_schema(3),
    do: [
      error_code: :int16,
      tokens:
        {:array,
         [
           principal_type: :string,
           principal_name: :string,
           token_requester_principal_type: :string,
           token_requester_principal_name: :string,
           issue_timestamp: :int64,
           expiry_timestamp: :int64,
           max_timestamp: :int64,
           token_id: :string,
           hmac: :bytes,
           renewers:
             {:array, [principal_type: :string, principal_name: :string, tag_buffer: %{}]},
           tag_buffer: %{}
         ]},
      throttle_time_ms: :int32,
      tag_buffer: %{}
    ]
end