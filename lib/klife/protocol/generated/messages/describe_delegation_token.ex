defmodule Klife.Protocol.Messages.DescribeDelegationToken do
  alias Klife.Protocol.Deserializer
  alias Klife.Protocol.Serializer
  alias Klife.Protocol.Header

  @api_key 41
  @min_flexible_version_req 2
  @min_flexible_version_res 2

  def deserialize_response(data, version) do
    with {headers, rest_data} <- Header.deserialize_response(data, res_header_version(version)),
         {content, <<>>} <- Deserializer.execute(rest_data, response_schema(version)) do
      %{headers: headers, content: content}
    end
  end

  def serialize_request(input, version) do
    input
    |> Map.put(:request_api_key, @api_key)
    |> Map.put(:request_api_version, version)
    |> Header.serialize_request(req_header_version(version))
    |> then(&Serializer.execute(input, request_schema(version), &1))
  end

  defp req_header_version(msg_version),
    do: if(msg_version >= @min_flexible_version_req, do: 2, else: 1)

  defp res_header_version(msg_version),
    do: if(msg_version >= @min_flexible_version_res, do: 1, else: 0)

  defp request_schema(0),
    do: [owners: {:array, [principal_type: :string, principal_name: :string]}]

  defp request_schema(1),
    do: [owners: {:array, [principal_type: :string, principal_name: :string]}]

  defp request_schema(2),
    do: [
      owners:
        {:compact_array,
         [
           principal_type: :compact_string,
           principal_name: :compact_string,
           tag_buffer: {:tag_buffer, %{}}
         ]},
      tag_buffer: {:tag_buffer, %{}}
    ]

  defp request_schema(3),
    do: [
      owners:
        {:compact_array,
         [
           principal_type: :compact_string,
           principal_name: :compact_string,
           tag_buffer: {:tag_buffer, %{}}
         ]},
      tag_buffer: {:tag_buffer, %{}}
    ]

  defp response_schema(0),
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

  defp response_schema(1),
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

  defp response_schema(2),
    do: [
      error_code: :int16,
      tokens:
        {:compact_array,
         [
           principal_type: :compact_string,
           principal_name: :compact_string,
           issue_timestamp: :int64,
           expiry_timestamp: :int64,
           max_timestamp: :int64,
           token_id: :compact_string,
           hmac: :compact_bytes,
           renewers:
             {:compact_array,
              [
                principal_type: :compact_string,
                principal_name: :compact_string,
                tag_buffer: {:tag_buffer, %{}}
              ]},
           tag_buffer: {:tag_buffer, %{}}
         ]},
      throttle_time_ms: :int32,
      tag_buffer: {:tag_buffer, %{}}
    ]

  defp response_schema(3),
    do: [
      error_code: :int16,
      tokens:
        {:compact_array,
         [
           principal_type: :compact_string,
           principal_name: :compact_string,
           token_requester_principal_type: :compact_string,
           token_requester_principal_name: :compact_string,
           issue_timestamp: :int64,
           expiry_timestamp: :int64,
           max_timestamp: :int64,
           token_id: :compact_string,
           hmac: :compact_bytes,
           renewers:
             {:compact_array,
              [
                principal_type: :compact_string,
                principal_name: :compact_string,
                tag_buffer: {:tag_buffer, %{}}
              ]},
           tag_buffer: {:tag_buffer, %{}}
         ]},
      throttle_time_ms: :int32,
      tag_buffer: {:tag_buffer, %{}}
    ]
end