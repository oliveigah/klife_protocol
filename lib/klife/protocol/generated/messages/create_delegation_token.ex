defmodule Klife.Protocol.Messages.CreateDelegationToken do
  alias Klife.Protocol.Deserializer
  alias Klife.Protocol.Serializer
  alias Klife.Protocol.Header

  def get_api_key(), do: 38

  def request_schema(0),
    do: [
      renewers: {:array, [principal_type: :string, principal_name: :string]},
      max_lifetime_ms: :int64
    ]

  def request_schema(1),
    do: [
      renewers: {:array, [principal_type: :string, principal_name: :string]},
      max_lifetime_ms: :int64
    ]

  def request_schema(2),
    do: [
      renewers: {:array, [principal_type: :string, principal_name: :string, tag_buffer: %{}]},
      max_lifetime_ms: :int64,
      tag_buffer: %{}
    ]

  def request_schema(3),
    do: [
      owner_principal_type: :string,
      owner_principal_name: :string,
      renewers: {:array, [principal_type: :string, principal_name: :string, tag_buffer: %{}]},
      max_lifetime_ms: :int64,
      tag_buffer: %{}
    ]

  def response_schema(0),
    do: [
      error_code: :int16,
      principal_type: :string,
      principal_name: :string,
      issue_timestamp_ms: :int64,
      expiry_timestamp_ms: :int64,
      max_timestamp_ms: :int64,
      token_id: :string,
      hmac: :bytes,
      throttle_time_ms: :int32
    ]

  def response_schema(1),
    do: [
      error_code: :int16,
      principal_type: :string,
      principal_name: :string,
      issue_timestamp_ms: :int64,
      expiry_timestamp_ms: :int64,
      max_timestamp_ms: :int64,
      token_id: :string,
      hmac: :bytes,
      throttle_time_ms: :int32
    ]

  def response_schema(2),
    do: [
      error_code: :int16,
      principal_type: :string,
      principal_name: :string,
      issue_timestamp_ms: :int64,
      expiry_timestamp_ms: :int64,
      max_timestamp_ms: :int64,
      token_id: :string,
      hmac: :bytes,
      throttle_time_ms: :int32,
      tag_buffer: %{}
    ]

  def response_schema(3),
    do: [
      error_code: :int16,
      principal_type: :string,
      principal_name: :string,
      token_requester_principal_type: :string,
      token_requester_principal_name: :string,
      issue_timestamp_ms: :int64,
      expiry_timestamp_ms: :int64,
      max_timestamp_ms: :int64,
      token_id: :string,
      hmac: :bytes,
      throttle_time_ms: :int32,
      tag_buffer: %{}
    ]
end