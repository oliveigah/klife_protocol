defmodule Klife.Protocol.Messages.DescribeConfigs do
  alias Klife.Protocol.Deserializer
  alias Klife.Protocol.Serializer
  alias Klife.Protocol.Header

  @api_key 32
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

  defp request_schema(0),
    do: [
      resources:
        {:array,
         [resource_type: :int8, resource_name: :string, configuration_keys: {:array, :string}]}
    ]

  defp request_schema(1),
    do: [
      resources:
        {:array,
         [resource_type: :int8, resource_name: :string, configuration_keys: {:array, :string}]},
      include_synonyms: :boolean
    ]

  defp request_schema(2),
    do: [
      resources:
        {:array,
         [resource_type: :int8, resource_name: :string, configuration_keys: {:array, :string}]},
      include_synonyms: :boolean
    ]

  defp request_schema(3),
    do: [
      resources:
        {:array,
         [resource_type: :int8, resource_name: :string, configuration_keys: {:array, :string}]},
      include_synonyms: :boolean,
      include_documentation: :boolean
    ]

  defp request_schema(4),
    do: [
      resources:
        {:array,
         [
           resource_type: :int8,
           resource_name: :string,
           configuration_keys: {:array, :string},
           tag_buffer: %{}
         ]},
      include_synonyms: :boolean,
      include_documentation: :boolean,
      tag_buffer: %{}
    ]

  defp response_schema(0),
    do: [
      throttle_time_ms: :int32,
      results:
        {:array,
         [
           error_code: :int16,
           error_message: :string,
           resource_type: :int8,
           resource_name: :string,
           configs:
             {:array,
              [
                name: :string,
                value: :string,
                read_only: :boolean,
                is_default: :boolean,
                is_sensitive: :boolean
              ]}
         ]}
    ]

  defp response_schema(1),
    do: [
      throttle_time_ms: :int32,
      results:
        {:array,
         [
           error_code: :int16,
           error_message: :string,
           resource_type: :int8,
           resource_name: :string,
           configs:
             {:array,
              [
                name: :string,
                value: :string,
                read_only: :boolean,
                config_source: :int8,
                is_sensitive: :boolean,
                synonyms: {:array, [name: :string, value: :string, source: :int8]}
              ]}
         ]}
    ]

  defp response_schema(2),
    do: [
      throttle_time_ms: :int32,
      results:
        {:array,
         [
           error_code: :int16,
           error_message: :string,
           resource_type: :int8,
           resource_name: :string,
           configs:
             {:array,
              [
                name: :string,
                value: :string,
                read_only: :boolean,
                config_source: :int8,
                is_sensitive: :boolean,
                synonyms: {:array, [name: :string, value: :string, source: :int8]}
              ]}
         ]}
    ]

  defp response_schema(3),
    do: [
      throttle_time_ms: :int32,
      results:
        {:array,
         [
           error_code: :int16,
           error_message: :string,
           resource_type: :int8,
           resource_name: :string,
           configs:
             {:array,
              [
                name: :string,
                value: :string,
                read_only: :boolean,
                config_source: :int8,
                is_sensitive: :boolean,
                synonyms: {:array, [name: :string, value: :string, source: :int8]},
                config_type: :int8,
                documentation: :string
              ]}
         ]}
    ]

  defp response_schema(4),
    do: [
      throttle_time_ms: :int32,
      results:
        {:array,
         [
           error_code: :int16,
           error_message: :string,
           resource_type: :int8,
           resource_name: :string,
           configs:
             {:array,
              [
                name: :string,
                value: :string,
                read_only: :boolean,
                config_source: :int8,
                is_sensitive: :boolean,
                synonyms:
                  {:array, [name: :string, value: :string, source: :int8, tag_buffer: %{}]},
                config_type: :int8,
                documentation: :string,
                tag_buffer: %{}
              ]},
           tag_buffer: %{}
         ]},
      tag_buffer: %{}
    ]
end