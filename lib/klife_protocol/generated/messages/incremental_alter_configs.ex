defmodule KlifeProtocol.Messages.IncrementalAlterConfigs do
  alias KlifeProtocol.Deserializer
  alias KlifeProtocol.Serializer
  alias KlifeProtocol.Header

  @api_key 44
  @min_flexible_version_req 1
  @min_flexible_version_res 1

  def deserialize_response(data, version) do
    with {headers, rest_data} <- Header.deserialize_response(data, res_header_version(version)),
         {content, _} <- Deserializer.execute(rest_data, response_schema(version)) do
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
    do: [
      resources:
        {:array,
         [
           resource_type: :int8,
           resource_name: :string,
           configs: {:array, [name: :string, config_operation: :int8, value: :string]}
         ]},
      validate_only: :boolean
    ]

  defp request_schema(1),
    do: [
      resources:
        {:compact_array,
         [
           resource_type: :int8,
           resource_name: :compact_string,
           configs:
             {:compact_array,
              [
                name: :compact_string,
                config_operation: :int8,
                value: :compact_string,
                tag_buffer: {:tag_buffer, []}
              ]},
           tag_buffer: {:tag_buffer, []}
         ]},
      validate_only: :boolean,
      tag_buffer: {:tag_buffer, []}
    ]

  defp response_schema(0),
    do: [
      throttle_time_ms: :int32,
      responses:
        {:array,
         [
           error_code: :int16,
           error_message: :string,
           resource_type: :int8,
           resource_name: :string
         ]}
    ]

  defp response_schema(1),
    do: [
      throttle_time_ms: :int32,
      responses:
        {:compact_array,
         [
           error_code: :int16,
           error_message: :compact_string,
           resource_type: :int8,
           resource_name: :compact_string,
           tag_buffer: {:tag_buffer, %{}}
         ]},
      tag_buffer: {:tag_buffer, %{}}
    ]
end