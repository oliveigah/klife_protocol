defmodule Messages.ApiVersionsTest do
  use ExUnit.Case

  alias KlifeProtocol.Connection
  alias KlifeProtocol.Messages.ApiVersions
  alias KlifeProtocol.TestSupport.ConnectionHelper

  setup_all do
    %{brokers_connections: ConnectionHelper.start_connections()}
  end

  test "request and response v0", %{brokers_connections: conns} do
    {_, conn} = Enum.random(conns)

    version = 0
    correlation_id = Enum.random(1..100_000)

    headers = %{
      correlation_id: correlation_id,
      client_id: "klife_client_id"
    }

    content = %{}

    msg = ApiVersions.serialize_request(%{headers: headers, content: content}, version)

    assert :ok = Connection.send_data(conn, msg)

    {:ok, received_data} = Connection.read_data(conn)

    assert %{
             headers: headers,
             content: content
           } = ApiVersions.deserialize_response(received_data, version)

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

  test "request and response v1", %{brokers_connections: conns} do
    {_, conn} = Enum.random(conns)

    version = 1
    correlation_id = Enum.random(1..100_000)

    headers = %{
      correlation_id: correlation_id,
      client_id: "klife_client_id"
    }

    content = %{}

    msg = ApiVersions.serialize_request(%{headers: headers, content: content}, version)

    assert :ok = Connection.send_data(conn, msg)

    {:ok, received_data} = Connection.read_data(conn)

    assert %{
             headers: headers,
             content: content
           } = ApiVersions.deserialize_response(received_data, version)

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

  test "request and response v2", %{brokers_connections: conns} do
    {_, conn} = Enum.random(conns)

    version = 2
    correlation_id = Enum.random(1..100_000)

    headers = %{
      correlation_id: correlation_id,
      client_id: "klife_client_id"
    }

    content = %{}

    msg = ApiVersions.serialize_request(%{headers: headers, content: content}, version)

    assert :ok = Connection.send_data(conn, msg)

    {:ok, received_data} = Connection.read_data(conn)

    assert %{
             headers: headers,
             content: content
           } = ApiVersions.deserialize_response(received_data, version)

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

  test "request and response v3", %{brokers_connections: conns} do
    {_, conn} = Enum.random(conns)

    version = 3
    correlation_id = Enum.random(1..100_000)

    headers = %{
      correlation_id: correlation_id,
      client_id: "klife_client_id"
    }

    content = %{
      client_software_name: "klife",
      client_software_version: "0"
    }

    msg = ApiVersions.serialize_request(%{headers: headers, content: content}, version)

    assert :ok = Connection.send_data(conn, msg)

    {:ok, received_data} = Connection.read_data(conn)

    assert %{
             headers: headers,
             content: content
           } = ApiVersions.deserialize_response(received_data, version)

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
