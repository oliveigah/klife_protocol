# DO NOT EDIT THIS FILE MANUALLY  
# This module is automatically generated by running mix task generate_file
# every change must be done inside the mix task directly

defmodule KlifeProtocol.Messages.DescribeUserScramCredentials do
  @moduledoc """
  Kafka protocol DescribeUserScramCredentials message

  Request versions summary:   

  Response versions summary:

  """

  alias KlifeProtocol.Deserializer
  alias KlifeProtocol.Serializer
  alias KlifeProtocol.Header

  @api_key 50
  @min_flexible_version_req 0
  @min_flexible_version_res 0

  @doc """
  Content fields:

  - users: The users to describe, or null/empty to describe all users. ([]UserName | versions 0+)
      - name: The user name. (string | versions 0+)

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
  - error_code: The message-level error code, 0 except for user authorization or infrastructure issues. (int16 | versions 0+)
  - error_message: The message-level error message, if any. (string | versions 0+)
  - results: The results for descriptions, one per user. ([]DescribeUserScramCredentialsResult | versions 0+)
      - user: The user name. (string | versions 0+)
      - error_code: The user-level error code. (int16 | versions 0+)
      - error_message: The user-level error message, if any. (string | versions 0+)
      - credential_infos: The mechanism and related information associated with the user's SCRAM credentials. ([]CredentialInfo | versions 0+)
          - mechanism: The SCRAM mechanism. (int8 | versions 0+)
          - iterations: The number of iterations used in the SCRAM credential. (int32 | versions 0+)

  """
  def deserialize_response(data, version) do
    {headers, rest_data} = Header.deserialize_response(data, res_header_version(version))
    {content, <<>>} = Deserializer.execute(rest_data, response_schema(version))

    %{headers: headers, content: content}
  end

  def max_supported_version(), do: 0
  def min_supported_version(), do: 0

  defp req_header_version(msg_version),
    do: if(msg_version >= @min_flexible_version_req, do: 2, else: 1)

  defp res_header_version(msg_version),
    do: if(msg_version >= @min_flexible_version_res, do: 1, else: 0)

  defp request_schema(0),
    do: [
      users:
        {{:compact_array,
          [name: {:compact_string, %{is_nullable?: false}}, tag_buffer: {:tag_buffer, []}]},
         %{is_nullable?: true}},
      tag_buffer: {:tag_buffer, []}
    ]

  defp request_schema(unkown_version),
    do: raise("Unknown version #{unkown_version} for message DescribeUserScramCredentials")

  defp response_schema(0),
    do: [
      throttle_time_ms: {:int32, %{is_nullable?: false}},
      error_code: {:int16, %{is_nullable?: false}},
      error_message: {:compact_string, %{is_nullable?: true}},
      results:
        {{:compact_array,
          [
            user: {:compact_string, %{is_nullable?: false}},
            error_code: {:int16, %{is_nullable?: false}},
            error_message: {:compact_string, %{is_nullable?: true}},
            credential_infos:
              {{:compact_array,
                [
                  mechanism: {:int8, %{is_nullable?: false}},
                  iterations: {:int32, %{is_nullable?: false}},
                  tag_buffer: {:tag_buffer, %{}}
                ]}, %{is_nullable?: false}},
            tag_buffer: {:tag_buffer, %{}}
          ]}, %{is_nullable?: false}},
      tag_buffer: {:tag_buffer, %{}}
    ]

  defp response_schema(unkown_version),
    do: raise("Unknown version #{unkown_version} for message DescribeUserScramCredentials")
end