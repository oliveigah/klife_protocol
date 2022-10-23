defmodule KlifeProtocol.Messages.DescribeConfigs do
  alias KlifeProtocol.Deserializer
  alias KlifeProtocol.Serializer
  alias KlifeProtocol.Header

  @api_key 32
  @min_flexible_version_req 4
  @min_flexible_version_res 4

  def serialize_request(%{headers: headers, content: content}, version) do
    headers
    |> Map.put(:request_api_key, @api_key)
    |> Map.put(:request_api_version, version)
    |> Header.serialize_request(req_header_version(version))
    |> then(&Serializer.execute(content, request_schema(version), &1))
  end

  def deserialize_response(data, version) do
    {headers, rest_data} = Header.deserialize_response(data, res_header_version(version))
    {content, <<>>} = Deserializer.execute(rest_data, response_schema(version))

    %{headers: headers, content: content}
  end

  defp req_header_version(msg_version),
    do: if(msg_version >= @min_flexible_version_req, do: 2, else: 1)

  defp res_header_version(msg_version),
    do: if(msg_version >= @min_flexible_version_res, do: 1, else: 0)

  defp request_schema(0),
    do: [
      resources:
        {{:array,
          [
            resource_type: {:int8, %{is_nullable?: false}},
            resource_name: {:string, %{is_nullable?: false}},
            configuration_keys: {{:array, :string}, %{is_nullable?: true}}
          ]}, %{is_nullable?: false}}
    ]

  defp request_schema(1),
    do: [
      resources:
        {{:array,
          [
            resource_type: {:int8, %{is_nullable?: false}},
            resource_name: {:string, %{is_nullable?: false}},
            configuration_keys: {{:array, :string}, %{is_nullable?: true}}
          ]}, %{is_nullable?: false}},
      include_synonyms: {:boolean, %{is_nullable?: false}}
    ]

  defp request_schema(2),
    do: [
      resources:
        {{:array,
          [
            resource_type: {:int8, %{is_nullable?: false}},
            resource_name: {:string, %{is_nullable?: false}},
            configuration_keys: {{:array, :string}, %{is_nullable?: true}}
          ]}, %{is_nullable?: false}},
      include_synonyms: {:boolean, %{is_nullable?: false}}
    ]

  defp request_schema(3),
    do: [
      resources:
        {{:array,
          [
            resource_type: {:int8, %{is_nullable?: false}},
            resource_name: {:string, %{is_nullable?: false}},
            configuration_keys: {{:array, :string}, %{is_nullable?: true}}
          ]}, %{is_nullable?: false}},
      include_synonyms: {:boolean, %{is_nullable?: false}},
      include_documentation: {:boolean, %{is_nullable?: false}}
    ]

  defp request_schema(4),
    do: [
      resources:
        {{:compact_array,
          [
            resource_type: {:int8, %{is_nullable?: false}},
            resource_name: {:compact_string, %{is_nullable?: false}},
            configuration_keys: {{:compact_array, :compact_string}, %{is_nullable?: true}},
            tag_buffer: {:tag_buffer, []}
          ]}, %{is_nullable?: false}},
      include_synonyms: {:boolean, %{is_nullable?: false}},
      include_documentation: {:boolean, %{is_nullable?: false}},
      tag_buffer: {:tag_buffer, []}
    ]

  defp response_schema(0),
    do: [
      throttle_time_ms: {:int32, %{is_nullable?: false}},
      results:
        {{:array,
          [
            error_code: {:int16, %{is_nullable?: false}},
            error_message: {:string, %{is_nullable?: true}},
            resource_type: {:int8, %{is_nullable?: false}},
            resource_name: {:string, %{is_nullable?: false}},
            configs:
              {{:array,
                [
                  name: {:string, %{is_nullable?: false}},
                  value: {:string, %{is_nullable?: true}},
                  read_only: {:boolean, %{is_nullable?: false}},
                  is_default: {:boolean, %{is_nullable?: false}},
                  is_sensitive: {:boolean, %{is_nullable?: false}}
                ]}, %{is_nullable?: false}}
          ]}, %{is_nullable?: false}}
    ]

  defp response_schema(1),
    do: [
      throttle_time_ms: {:int32, %{is_nullable?: false}},
      results:
        {{:array,
          [
            error_code: {:int16, %{is_nullable?: false}},
            error_message: {:string, %{is_nullable?: true}},
            resource_type: {:int8, %{is_nullable?: false}},
            resource_name: {:string, %{is_nullable?: false}},
            configs:
              {{:array,
                [
                  name: {:string, %{is_nullable?: false}},
                  value: {:string, %{is_nullable?: true}},
                  read_only: {:boolean, %{is_nullable?: false}},
                  config_source: {:int8, %{is_nullable?: false}},
                  is_sensitive: {:boolean, %{is_nullable?: false}},
                  synonyms:
                    {{:array,
                      [
                        name: {:string, %{is_nullable?: false}},
                        value: {:string, %{is_nullable?: true}},
                        source: {:int8, %{is_nullable?: false}}
                      ]}, %{is_nullable?: false}}
                ]}, %{is_nullable?: false}}
          ]}, %{is_nullable?: false}}
    ]

  defp response_schema(2),
    do: [
      throttle_time_ms: {:int32, %{is_nullable?: false}},
      results:
        {{:array,
          [
            error_code: {:int16, %{is_nullable?: false}},
            error_message: {:string, %{is_nullable?: true}},
            resource_type: {:int8, %{is_nullable?: false}},
            resource_name: {:string, %{is_nullable?: false}},
            configs:
              {{:array,
                [
                  name: {:string, %{is_nullable?: false}},
                  value: {:string, %{is_nullable?: true}},
                  read_only: {:boolean, %{is_nullable?: false}},
                  config_source: {:int8, %{is_nullable?: false}},
                  is_sensitive: {:boolean, %{is_nullable?: false}},
                  synonyms:
                    {{:array,
                      [
                        name: {:string, %{is_nullable?: false}},
                        value: {:string, %{is_nullable?: true}},
                        source: {:int8, %{is_nullable?: false}}
                      ]}, %{is_nullable?: false}}
                ]}, %{is_nullable?: false}}
          ]}, %{is_nullable?: false}}
    ]

  defp response_schema(3),
    do: [
      throttle_time_ms: {:int32, %{is_nullable?: false}},
      results:
        {{:array,
          [
            error_code: {:int16, %{is_nullable?: false}},
            error_message: {:string, %{is_nullable?: true}},
            resource_type: {:int8, %{is_nullable?: false}},
            resource_name: {:string, %{is_nullable?: false}},
            configs:
              {{:array,
                [
                  name: {:string, %{is_nullable?: false}},
                  value: {:string, %{is_nullable?: true}},
                  read_only: {:boolean, %{is_nullable?: false}},
                  config_source: {:int8, %{is_nullable?: false}},
                  is_sensitive: {:boolean, %{is_nullable?: false}},
                  synonyms:
                    {{:array,
                      [
                        name: {:string, %{is_nullable?: false}},
                        value: {:string, %{is_nullable?: true}},
                        source: {:int8, %{is_nullable?: false}}
                      ]}, %{is_nullable?: false}},
                  config_type: {:int8, %{is_nullable?: false}},
                  documentation: {:string, %{is_nullable?: true}}
                ]}, %{is_nullable?: false}}
          ]}, %{is_nullable?: false}}
    ]

  defp response_schema(4),
    do: [
      throttle_time_ms: {:int32, %{is_nullable?: false}},
      results:
        {{:compact_array,
          [
            error_code: {:int16, %{is_nullable?: false}},
            error_message: {:compact_string, %{is_nullable?: true}},
            resource_type: {:int8, %{is_nullable?: false}},
            resource_name: {:compact_string, %{is_nullable?: false}},
            configs:
              {{:compact_array,
                [
                  name: {:compact_string, %{is_nullable?: false}},
                  value: {:compact_string, %{is_nullable?: true}},
                  read_only: {:boolean, %{is_nullable?: false}},
                  config_source: {:int8, %{is_nullable?: false}},
                  is_sensitive: {:boolean, %{is_nullable?: false}},
                  synonyms:
                    {{:compact_array,
                      [
                        name: {:compact_string, %{is_nullable?: false}},
                        value: {:compact_string, %{is_nullable?: true}},
                        source: {:int8, %{is_nullable?: false}},
                        tag_buffer: {:tag_buffer, %{}}
                      ]}, %{is_nullable?: false}},
                  config_type: {:int8, %{is_nullable?: false}},
                  documentation: {:compact_string, %{is_nullable?: true}},
                  tag_buffer: {:tag_buffer, %{}}
                ]}, %{is_nullable?: false}},
            tag_buffer: {:tag_buffer, %{}}
          ]}, %{is_nullable?: false}},
      tag_buffer: {:tag_buffer, %{}}
    ]
end