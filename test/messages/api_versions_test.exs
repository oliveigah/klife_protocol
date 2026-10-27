defmodule Messages.ApiVersionsTest do
  use ExUnit.Case, async: true

  alias KlifeProtocol.Messages.ApiVersions
  alias KlifeProtocol.TestSupport.Helpers

  @tag "#{ApiVersions.api_key()}": 5
  test "request and response v5 - cluster and node identity" do
    version = 5

    {:ok, %{content: %{cluster_id: cluster_id}}} =
      Helpers.metadata_request(topic_name: "test_topic_default")

    for {cluster_id, node_id, error_code} <- [
          {cluster_id, 2, 0},
          {"another-cluster", 2, 129},
          {cluster_id, 999, 129}
        ] do
      headers = %{correlation_id: correlation_id} = Helpers.generate_headers()

      content = %{
        client_software_name: "klife",
        client_software_version: "0",
        cluster_id: cluster_id,
        node_id: node_id
      }

      {:ok, result} =
        %{headers: headers, content: content}
        |> ApiVersions.serialize_request(version)
        |> Helpers.send_message_to_broker(2)
        |> ApiVersions.deserialize_response(version)

      assert %{
               headers: %{correlation_id: ^correlation_id},
               content: %{error_code: ^error_code, api_keys: api_keys}
             } = result

      # ApiVersions retains response header v0, including on identity errors.
      assert map_size(result.headers) == 1
      assert is_list(api_keys)

      if error_code == 0 do
        assert Enum.any?(api_keys, &(&1.api_key == 18 and &1.max_version >= version))
      end
    end
  end

  @tag "#{ApiVersions.api_key()}": 0
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

  @tag "#{ApiVersions.api_key()}": 1
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

  @tag "#{ApiVersions.api_key()}": 2
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

  @tag "#{ApiVersions.api_key()}": 3
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

    assert %{
             error_code: 0,
             api_keys: api_keys,
             throttle_time_ms: 0
           } = content

    assert is_list(api_keys) == true

    assert Enum.all?(api_keys, fn e ->
             length(Map.keys(e)) == 3 &&
               match?(%{api_key: _, max_version: _, min_version: _}, e)
           end)
  end
end
