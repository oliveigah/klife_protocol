defmodule Klife.Protocol.Messages.DeleteAcls do
  alias Klife.Protocol.Deserializer
  alias Klife.Protocol.Serializer
  alias Klife.Protocol.Header

  @api_key 31
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
    do: [
      filters:
        {:array,
         [
           resource_type_filter: :int8,
           resource_name_filter: :string,
           principal_filter: :string,
           host_filter: :string,
           operation: :int8,
           permission_type: :int8
         ]}
    ]

  defp request_schema(1),
    do: [
      filters:
        {:array,
         [
           resource_type_filter: :int8,
           resource_name_filter: :string,
           pattern_type_filter: :int8,
           principal_filter: :string,
           host_filter: :string,
           operation: :int8,
           permission_type: :int8
         ]}
    ]

  defp request_schema(2),
    do: [
      filters:
        {:array,
         [
           resource_type_filter: :int8,
           resource_name_filter: :string,
           pattern_type_filter: :int8,
           principal_filter: :string,
           host_filter: :string,
           operation: :int8,
           permission_type: :int8,
           tag_buffer: %{}
         ]},
      tag_buffer: %{}
    ]

  defp request_schema(3),
    do: [
      filters:
        {:array,
         [
           resource_type_filter: :int8,
           resource_name_filter: :string,
           pattern_type_filter: :int8,
           principal_filter: :string,
           host_filter: :string,
           operation: :int8,
           permission_type: :int8,
           tag_buffer: %{}
         ]},
      tag_buffer: %{}
    ]

  defp response_schema(0),
    do: [
      throttle_time_ms: :int32,
      filter_results:
        {:array,
         [
           error_code: :int16,
           error_message: :string,
           matching_acls:
             {:array,
              [
                error_code: :int16,
                error_message: :string,
                resource_type: :int8,
                resource_name: :string,
                principal: :string,
                host: :string,
                operation: :int8,
                permission_type: :int8
              ]}
         ]}
    ]

  defp response_schema(1),
    do: [
      throttle_time_ms: :int32,
      filter_results:
        {:array,
         [
           error_code: :int16,
           error_message: :string,
           matching_acls:
             {:array,
              [
                error_code: :int16,
                error_message: :string,
                resource_type: :int8,
                resource_name: :string,
                pattern_type: :int8,
                principal: :string,
                host: :string,
                operation: :int8,
                permission_type: :int8
              ]}
         ]}
    ]

  defp response_schema(2),
    do: [
      throttle_time_ms: :int32,
      filter_results:
        {:array,
         [
           error_code: :int16,
           error_message: :string,
           matching_acls:
             {:array,
              [
                error_code: :int16,
                error_message: :string,
                resource_type: :int8,
                resource_name: :string,
                pattern_type: :int8,
                principal: :string,
                host: :string,
                operation: :int8,
                permission_type: :int8,
                tag_buffer: %{}
              ]},
           tag_buffer: %{}
         ]},
      tag_buffer: %{}
    ]

  defp response_schema(3),
    do: [
      throttle_time_ms: :int32,
      filter_results:
        {:array,
         [
           error_code: :int16,
           error_message: :string,
           matching_acls:
             {:array,
              [
                error_code: :int16,
                error_message: :string,
                resource_type: :int8,
                resource_name: :string,
                pattern_type: :int8,
                principal: :string,
                host: :string,
                operation: :int8,
                permission_type: :int8,
                tag_buffer: %{}
              ]},
           tag_buffer: %{}
         ]},
      tag_buffer: %{}
    ]
end