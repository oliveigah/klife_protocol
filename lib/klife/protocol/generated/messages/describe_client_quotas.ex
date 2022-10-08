defmodule Klife.Protocol.Messages.DescribeClientQuotas do
  alias Klife.Protocol.Deserializer
  alias Klife.Protocol.Serializer
  alias Klife.Protocol.Header

  @api_key 48
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
      components: {:array, [entity_type: :string, match_type: :int8, match: :string]},
      strict: :boolean
    ]

  defp request_schema(1),
    do: [
      components:
        {:compact_array,
         [
           entity_type: :compact_string,
           match_type: :int8,
           match: :compact_string,
           tag_buffer: {:tag_buffer, %{}}
         ]},
      strict: :boolean,
      tag_buffer: {:tag_buffer, %{}}
    ]

  defp response_schema(0),
    do: [
      throttle_time_ms: :int32,
      error_code: :int16,
      error_message: :string,
      entries:
        {:array,
         [
           entity: {:array, [entity_type: :string, entity_name: :string]},
           values: {:array, [key: :string, value: :float64]}
         ]}
    ]

  defp response_schema(1),
    do: [
      throttle_time_ms: :int32,
      error_code: :int16,
      error_message: :compact_string,
      entries:
        {:compact_array,
         [
           entity:
             {:compact_array,
              [
                entity_type: :compact_string,
                entity_name: :compact_string,
                tag_buffer: {:tag_buffer, %{}}
              ]},
           values:
             {:compact_array,
              [key: :compact_string, value: :float64, tag_buffer: {:tag_buffer, %{}}]},
           tag_buffer: {:tag_buffer, %{}}
         ]},
      tag_buffer: {:tag_buffer, %{}}
    ]
end