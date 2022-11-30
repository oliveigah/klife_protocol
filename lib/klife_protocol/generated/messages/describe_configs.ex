# DO NOT EDIT THIS FILE MANUALLY  
# This module is automatically generated by running mix task generate_file
# every change must be done inside the mix task directly

defmodule KlifeProtocol.Messages.DescribeConfigs do
  @moduledoc """
  Kafka protocol DescribeConfigs message

  Request versions summary:   
  - Version 1 adds IncludeSynonyms.
  Version 2 is the same as version 1.
  Version 4 enables flexible versions.

  Response versions summary:
  - Version 1 adds ConfigSource and the synonyms.
  Starting in version 2, on quota violation, brokers send out responses before throttling.
  Version 4 enables flexible versions.

  """

  alias KlifeProtocol.Deserializer
  alias KlifeProtocol.Serializer
  alias KlifeProtocol.Header

  @api_key 32
  @min_flexible_version_req 4
  @min_flexible_version_res 4

  @doc """
  Content fields:

  - resources: The resources whose configurations we want to describe. ([]DescribeConfigsResource | versions 0+)
      - resource_type: The resource type. (int8 | versions 0+)
      - resource_name: The resource name. (string | versions 0+)
      - configuration_keys: The configuration keys to list, or null to list all configuration keys. ([]string | versions 0+)
  - include_synonyms: True if we should include all synonyms. (bool | versions 1+)
  - include_documentation: True if we should include configuration documentation. (bool | versions 3+)

  """
  def serialize_request(%{headers: headers, content: content}, version) do
    headers
    |> Map.put(:request_api_key, @api_key)
    |> Map.put(:request_api_version, version)
    |> Header.serialize_request(req_header_version(version))
    |> then(&Serializer.execute(content, request_schema(version), &1))
  end

  @doc """
  Content fields:

  - throttle_time_ms: The duration in milliseconds for which the request was throttled due to a quota violation, or zero if the request did not violate any quota. (int32 | versions 0+)
  - results: The results for each resource. ([]DescribeConfigsResult | versions 0+)
      - error_code: The error code, or 0 if we were able to successfully describe the configurations. (int16 | versions 0+)
      - error_message: The error message, or null if we were able to successfully describe the configurations. (string | versions 0+)
      - resource_type: The resource type. (int8 | versions 0+)
      - resource_name: The resource name. (string | versions 0+)
      - configs: Each listed configuration. ([]DescribeConfigsResourceResult | versions 0+)
          - name: The configuration name. (string | versions 0+)
          - value: The configuration value. (string | versions 0+)
          - read_only: True if the configuration is read-only. (bool | versions 0+)
          - is_default: True if the configuration is not set. (bool | versions 0)
          - config_source: The configuration source. (int8 | versions 1+)
          - is_sensitive: True if this configuration is sensitive. (bool | versions 0+)
          - synonyms: The synonyms for this configuration key. ([]DescribeConfigsSynonym | versions 1+)
              - name: The synonym name. (string | versions 1+)
              - value: The synonym value. (string | versions 1+)
              - source: The synonym source. (int8 | versions 1+)
          - config_type: The configuration data type. Type can be one of the following values - BOOLEAN, STRING, INT, SHORT, LONG, DOUBLE, LIST, CLASS, PASSWORD (int8 | versions 3+)
          - documentation: The configuration documentation. (string | versions 3+)

  """
  def deserialize_response(data, version) do
    {headers, rest_data} = Header.deserialize_response(data, res_header_version(version))
    {content, <<>>} = Deserializer.execute(rest_data, response_schema(version))

    %{headers: headers, content: content}
  end

  def max_supported_version(), do: 4
  def min_supported_version(), do: 0

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