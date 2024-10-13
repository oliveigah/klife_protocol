defmodule Messages.ApiVersionsTest do
  use ExUnit.Case, async: true

  alias KlifeProtocol.Messages.ApiVersions
  alias KlifeProtocol.TestSupport.Helpers

  test "request and response v0" do
    version = 0
    headers = %{correlation_id: correlation_id} = Helpers.generate_headers()

    {:ok, result} =
      %{headers: headers, content: %{}}
      |> ApiVersions.serialize_request(version)
      |> Helpers.send_message_to_broker()
      |> ApiVersions.deserialize_response(version)

    assert %{
             headers: headers,
             content: content
           } = result

    assert length(Map.keys(headers)) == 1
    assert %{correlation_id: ^correlation_id} = headers

    assert length(Map.keys(content)) == 2
    assert %{error_code: 0, api_keys: api_keys} = content

    assert is_list(api_keys) == true

    assert Enum.all?(api_keys, fn e ->
             length(Map.keys(e)) == 3 &&
               match?(%{api_key: _, max_version: _, min_version: _}, e)
           end)
  end

  test "request and response v1" do
    version = 1
    headers = %{correlation_id: correlation_id} = Helpers.generate_headers()

    {:ok, result} =
      %{headers: headers, content: %{}}
      |> ApiVersions.serialize_request(version)
      |> Helpers.send_message_to_broker()
      |> ApiVersions.deserialize_response(version)

    assert %{
             headers: headers,
             content: content
           } = result

    assert length(Map.keys(headers)) == 1
    assert %{correlation_id: ^correlation_id} = headers

    assert length(Map.keys(content)) == 3

    assert %{error_code: 0, api_keys: api_keys, throttle_time_ms: 0} = content

    assert is_list(api_keys) == true

    assert Enum.all?(api_keys, fn e ->
             length(Map.keys(e)) == 3 &&
               match?(%{api_key: _, max_version: _, min_version: _}, e)
           end)
  end

  test "request and response v2" do
    version = 2
    headers = %{correlation_id: correlation_id} = Helpers.generate_headers()

    {:ok, result} =
      %{headers: headers, content: %{}}
      |> ApiVersions.serialize_request(version)
      |> Helpers.send_message_to_broker()
      |> ApiVersions.deserialize_response(version)

    assert %{
             headers: headers,
             content: content
           } = result

    assert length(Map.keys(headers)) == 1
    assert %{correlation_id: ^correlation_id} = headers

    assert length(Map.keys(content)) == 3

    assert %{error_code: 0, api_keys: api_keys, throttle_time_ms: 0} = content

    assert is_list(api_keys) == true

    assert Enum.all?(api_keys, fn e ->
             length(Map.keys(e)) == 3 &&
               match?(%{api_key: _, max_version: _, min_version: _}, e)
           end)
  end

  test "request and response v3" do
    version = 3

    headers = %{correlation_id: correlation_id} = Helpers.generate_headers()

    content = %{
      client_software_name: "klife",
      client_software_version: "0"
    }

    {:ok, result} =
      %{headers: headers, content: content}
      |> ApiVersions.serialize_request(version)
      |> Helpers.send_message_to_broker()
      |> ApiVersions.deserialize_response(version)

    assert %{
             headers: headers,
             content: content
           } = result

    assert length(Map.keys(headers)) == 1
    assert %{correlation_id: ^correlation_id} = headers

    assert length(Map.keys(content)) == 4

    assert %{
             error_code: 0,
             api_keys: api_keys,
             throttle_time_ms: 0,
             finalized_features_epoch: 0
           } = content

    assert is_list(api_keys) == true

    assert Enum.all?(api_keys, fn e ->
             length(Map.keys(e)) == 3 &&
               match?(%{api_key: _, max_version: _, min_version: _}, e)
           end)
  end
end
