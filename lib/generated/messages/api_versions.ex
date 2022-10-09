defmodule KlifeProtocol.Messages.ApiVersions do
  alias KlifeProtocol.Deserializer
  alias KlifeProtocol.Serializer
  alias KlifeProtocol.Header

  @api_key 18
  @min_flexible_version_req 3

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

  defp res_header_version(_msg_version), do: 0

  defp request_schema(0), do: []
  defp request_schema(1), do: []
  defp request_schema(2), do: []

  defp request_schema(3),
    do: [
      client_software_name: {:compact_string, %{is_nullable?: false}},
      client_software_version: {:compact_string, %{is_nullable?: false}},
      tag_buffer: {:tag_buffer, []}
    ]

  defp response_schema(0),
    do: [
      error_code: {:int16, %{is_nullable?: false}},
      api_keys:
        {{:array,
          [
            api_key: {:int16, %{is_nullable?: false}},
            min_version: {:int16, %{is_nullable?: false}},
            max_version: {:int16, %{is_nullable?: false}}
          ]}, %{is_nullable?: false}}
    ]

  defp response_schema(1),
    do: [
      error_code: {:int16, %{is_nullable?: false}},
      api_keys:
        {{:array,
          [
            api_key: {:int16, %{is_nullable?: false}},
            min_version: {:int16, %{is_nullable?: false}},
            max_version: {:int16, %{is_nullable?: false}}
          ]}, %{is_nullable?: false}},
      throttle_time_ms: {:int32, %{is_nullable?: false}}
    ]

  defp response_schema(2),
    do: [
      error_code: {:int16, %{is_nullable?: false}},
      api_keys:
        {{:array,
          [
            api_key: {:int16, %{is_nullable?: false}},
            min_version: {:int16, %{is_nullable?: false}},
            max_version: {:int16, %{is_nullable?: false}}
          ]}, %{is_nullable?: false}},
      throttle_time_ms: {:int32, %{is_nullable?: false}}
    ]

  defp response_schema(3),
    do: [
      error_code: {:int16, %{is_nullable?: false}},
      api_keys:
        {{:compact_array,
          [
            api_key: {:int16, %{is_nullable?: false}},
            min_version: {:int16, %{is_nullable?: false}},
            max_version: {:int16, %{is_nullable?: false}},
            tag_buffer: {:tag_buffer, %{}}
          ]}, %{is_nullable?: false}},
      throttle_time_ms: {:int32, %{is_nullable?: false}},
      tag_buffer:
        {:tag_buffer,
         %{
           0 =>
             {{:supported_features,
               {:compact_array,
                [
                  name: {:compact_string, %{is_nullable?: false}},
                  min_version: {:int16, %{is_nullable?: false}},
                  max_version: {:int16, %{is_nullable?: false}},
                  tag_buffer: {:tag_buffer, %{}}
                ]}}, %{is_nullable?: false}},
           1 => {{:finalized_features_epoch, :int64}, %{is_nullable?: false}},
           2 =>
             {{:finalized_features,
               {:compact_array,
                [
                  name: {:compact_string, %{is_nullable?: false}},
                  max_version_level: {:int16, %{is_nullable?: false}},
                  min_version_level: {:int16, %{is_nullable?: false}},
                  tag_buffer: {:tag_buffer, %{}}
                ]}}, %{is_nullable?: false}}
         }}
    ]
end
