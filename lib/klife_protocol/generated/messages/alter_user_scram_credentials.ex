# DO NOT EDIT THIS FILE MANUALLY  
# This module is automatically generated by running mix task generate_file
# every change must be done inside the mix task directly

defmodule KlifeProtocol.Messages.AlterUserScramCredentials do
  @moduledoc """
  Kafka protocol AlterUserScramCredentials message

  Request versions summary:   

  Response versions summary:

  """

  alias KlifeProtocol.Deserializer
  alias KlifeProtocol.Serializer
  alias KlifeProtocol.Header

  @api_key 51
  @min_flexible_version_req 0
  @min_flexible_version_res 0

  @doc """
  Content fields:

  - deletions: The SCRAM credentials to remove. ([]ScramCredentialDeletion | versions 0+)
      - name: The user name. (string | versions 0+)
      - mechanism: The SCRAM mechanism. (int8 | versions 0+)
  - upsertions: The SCRAM credentials to update/insert. ([]ScramCredentialUpsertion | versions 0+)
      - name: The user name. (string | versions 0+)
      - mechanism: The SCRAM mechanism. (int8 | versions 0+)
      - iterations: The number of iterations. (int32 | versions 0+)
      - salt: A random salt generated by the client. (bytes | versions 0+)
      - salted_password: The salted password. (bytes | versions 0+)

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
  - results: The results for deletions and alterations, one per affected user. ([]AlterUserScramCredentialsResult | versions 0+)
      - user: The user name. (string | versions 0+)
      - error_code: The error code. (int16 | versions 0+)
      - error_message: The error message, if any. (string | versions 0+)

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
      deletions:
        {{:compact_array,
          [
            name: {:compact_string, %{is_nullable?: false}},
            mechanism: {:int8, %{is_nullable?: false}},
            tag_buffer: {:tag_buffer, []}
          ]}, %{is_nullable?: false}},
      upsertions:
        {{:compact_array,
          [
            name: {:compact_string, %{is_nullable?: false}},
            mechanism: {:int8, %{is_nullable?: false}},
            iterations: {:int32, %{is_nullable?: false}},
            salt: {:compact_bytes, %{is_nullable?: false}},
            salted_password: {:compact_bytes, %{is_nullable?: false}},
            tag_buffer: {:tag_buffer, []}
          ]}, %{is_nullable?: false}},
      tag_buffer: {:tag_buffer, []}
    ]

  defp request_schema(unkown_version),
    do: raise("Unknown version #{unkown_version} for message AlterUserScramCredentials")

  defp response_schema(0),
    do: [
      throttle_time_ms: {:int32, %{is_nullable?: false}},
      results:
        {{:compact_array,
          [
            user: {:compact_string, %{is_nullable?: false}},
            error_code: {:int16, %{is_nullable?: false}},
            error_message: {:compact_string, %{is_nullable?: true}},
            tag_buffer: {:tag_buffer, %{}}
          ]}, %{is_nullable?: false}},
      tag_buffer: {:tag_buffer, %{}}
    ]

  defp response_schema(unkown_version),
    do: raise("Unknown version #{unkown_version} for message AlterUserScramCredentials")
end