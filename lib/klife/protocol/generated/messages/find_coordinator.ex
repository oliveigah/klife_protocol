defmodule Klife.Protocol.Messages.FindCoordinator do
  alias Klife.Protocol.Deserializer
  alias Klife.Protocol.Serializer
  alias Klife.Protocol.Header

  @api_key 10
  @min_flexible_version_req 3
  @min_flexible_version_res 3

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

  defp request_schema(0), do: [key: :string]
  defp request_schema(1), do: [key_type: :int8]
  defp request_schema(2), do: [key_type: :int8]

  defp request_schema(3),
    do: [key: :compact_string, key_type: :int8, tag_buffer: {:tag_buffer, %{}}]

  defp request_schema(4),
    do: [
      key_type: :int8,
      coordinator_keys: {:compact_array, :compact_string},
      tag_buffer: {:tag_buffer, %{}}
    ]

  defp response_schema(0), do: [error_code: :int16, node_id: :int32, host: :string, port: :int32]
  defp response_schema(1), do: [throttle_time_ms: :int32, error_message: :string]
  defp response_schema(2), do: [throttle_time_ms: :int32]

  defp response_schema(3),
    do: [
      throttle_time_ms: :int32,
      error_code: :int16,
      error_message: :compact_string,
      node_id: :int32,
      host: :compact_string,
      port: :int32,
      tag_buffer: {:tag_buffer, %{}}
    ]

  defp response_schema(4),
    do: [
      throttle_time_ms: :int32,
      coordinators:
        {:compact_array,
         [
           key: :compact_string,
           node_id: :int32,
           host: :compact_string,
           port: :int32,
           error_code: :int16,
           error_message: :compact_string,
           tag_buffer: {:tag_buffer, %{}}
         ]},
      tag_buffer: {:tag_buffer, %{}}
    ]
end