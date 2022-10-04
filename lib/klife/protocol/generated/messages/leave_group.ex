defmodule Klife.Protocol.Messages.LeaveGroup do
  alias Klife.Protocol.Deserializer
  alias Klife.Protocol.Serializer
  alias Klife.Protocol.Header

  @api_key 13
  @min_flexible_version_req 4
  @min_flexible_version_res 4

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

  defp request_schema(0), do: [group_id: :string, member_id: :string]
  defp request_schema(1), do: [group_id: :string]
  defp request_schema(2), do: [group_id: :string, member_id: :string]

  defp request_schema(3),
    do: [group_id: :string, members: {:array, [member_id: :string, group_instance_id: :string]}]

  defp request_schema(4),
    do: [
      group_id: :string,
      members: {:array, [member_id: :string, group_instance_id: :string, tag_buffer: %{}]},
      tag_buffer: %{}
    ]

  defp request_schema(5),
    do: [
      group_id: :string,
      members:
        {:array,
         [member_id: :string, group_instance_id: :string, reason: :string, tag_buffer: %{}]},
      tag_buffer: %{}
    ]

  defp response_schema(0), do: [error_code: :int16]
  defp response_schema(1), do: [throttle_time_ms: :int32, error_code: :int16]
  defp response_schema(2), do: [throttle_time_ms: :int32, error_code: :int16]

  defp response_schema(3),
    do: [
      throttle_time_ms: :int32,
      error_code: :int16,
      members: {:array, [member_id: :string, group_instance_id: :string, error_code: :int16]}
    ]

  defp response_schema(4),
    do: [
      throttle_time_ms: :int32,
      error_code: :int16,
      members:
        {:array,
         [member_id: :string, group_instance_id: :string, error_code: :int16, tag_buffer: %{}]},
      tag_buffer: %{}
    ]

  defp response_schema(5),
    do: [
      throttle_time_ms: :int32,
      error_code: :int16,
      members:
        {:array,
         [member_id: :string, group_instance_id: :string, error_code: :int16, tag_buffer: %{}]},
      tag_buffer: %{}
    ]
end