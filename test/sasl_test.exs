defmodule KlifeProtocol.SaslTest do
  use ExUnit.Case, async: false

  alias KlifeProtocol.Socket
  alias KlifeProtocol.TestSupport.Helpers

  alias KlifeProtocol.Messages.Produce

  @brokers_sasl [
    kafka1: "localhost:19094",
    kafka2: "localhost:29094",
    kafka3: "localhost:39094"
  ]

  defp get_produce_msg_binary() do
    topic_name = "test_topic_default"
    version = 9
    partition_index = 0
    ts = DateTime.to_unix(DateTime.utc_now())

    content = %{
      transactional_id: nil,
      acks: -1,
      timeout_ms: 1000,
      topic_data: [
        %{
          name: topic_name,
          partition_data: [
            %{
              index: partition_index,
              records: %{
                base_offset: 0,
                partition_leader_epoch: -1,
                magic: 2,
                attributes: 0,
                last_offset_delta: 0,
                base_timestamp: ts,
                max_timestamp: ts,
                producer_id: -1,
                producer_epoch: -1,
                base_sequence: 1,
                records: [
                  %{
                    attributes: 0,
                    timestamp_delta: 0,
                    offset_delta: 0,
                    key: "some_key",
                    value: "some_value",
                    headers: [
                      %{key: "header_key", value: "header_value"}
                    ]
                  }
                ]
              }
            }
          ]
        }
      ]
    }

    resp =
      Produce.serialize_request(%{headers: Helpers.generate_headers(), content: content}, version)

    {resp, version}
  end

  @tag core: true
  test "fail if do not pass sasl opts" do
    ssl_opts = [
      verify: :verify_peer,
      cacertfile: Path.relative("test/compose_files/ssl/ca.crt")
    ]

    socket_backend = :ssl
    opts = [backend: socket_backend, active: false] ++ ssl_opts

    sockets =
      Enum.map(@brokers_sasl, fn {_broker, hostname} ->
        [host, port] = String.split(hostname, ":")
        {:ok, socket} = Socket.connect(host, String.to_integer(port), opts)
        socket
      end)

    Enum.each(sockets, fn socket ->
      {data, _version} = get_produce_msg_binary()
      :ok = apply(socket_backend, :send, [socket, data])
      assert {:error, :closed} = apply(socket_backend, :recv, [socket, 0, 5000])
    end)
  end

  @tag core: true
  test "success with plain sasl opts" do
    ssl_opts = [
      verify: :verify_peer,
      cacertfile: Path.relative("test/compose_files/ssl/ca.crt")
    ]

    sasl_opts = [
      mechanism: "PLAIN",
      auth_vsn: 2,
      handshake_vsn: 1,
      mechanism_opts: [
        username: "klifeusr",
        password: "klifepwd"
      ]
    ]

    socket_backend = :ssl
    opts = [backend: socket_backend, active: false, sasl_opts: sasl_opts] ++ ssl_opts

    sockets =
      Enum.map(@brokers_sasl, fn {_broker, hostname} ->
        [host, port] = String.split(hostname, ":")
        {:ok, socket} = Socket.connect(host, String.to_integer(port), opts)
        socket
      end)

    Enum.each(sockets, fn socket ->
      {data, version} = get_produce_msg_binary()
      :ok = apply(socket_backend, :send, [socket, data])
      {:ok, rcv_bin} = apply(socket_backend, :recv, [socket, 0, 5000])
      {:ok, _rcv_data} = Produce.deserialize_response(rcv_bin, version)
    end)
  end

  @tag core: true
  test "success with plain sasl opts 2 step auth" do
    ssl_opts = [
      verify: :verify_peer,
      cacertfile: Path.relative("test/compose_files/ssl/ca.crt")
    ]

    sasl_opts = [
      mechanism: "PLAIN",
      auth_vsn: 2,
      handshake_vsn: 1,
      mechanism_opts: [
        username: "klifeusr",
        password: "klifepwd"
      ]
    ]

    socket_backend = :ssl
    opts = [backend: socket_backend, active: false] ++ ssl_opts

    sockets =
      Enum.map(@brokers_sasl, fn {_broker, hostname} ->
        [host, port] = String.split(hostname, ":")
        {:ok, socket} = Socket.connect(host, String.to_integer(port), opts)
        # PLAIN credentials never expire and the brokers don't set connections.max.reauth.ms
        {:ok, %{session_lifetime_ms: 0}} = Socket.authenticate(socket, socket_backend, sasl_opts)
        socket
      end)

    Enum.each(sockets, fn socket ->
      {data, version} = get_produce_msg_binary()
      :ok = apply(socket_backend, :send, [socket, data])
      {:ok, rcv_bin} = apply(socket_backend, :recv, [socket, 0, 5000])
      {:ok, _rcv_data} = Produce.deserialize_response(rcv_bin, version)
    end)
  end

  @tag core: true
  test "success with scram sasl opts" do
    ssl_opts = [
      verify: :verify_peer,
      cacertfile: Path.relative("test/compose_files/ssl/ca.crt")
    ]

    socket_backend = :ssl

    for mechanism <- ["SCRAM-SHA-256", "SCRAM-SHA-512"], {_broker, hostname} <- @brokers_sasl do
      sasl_opts = [
        mechanism: mechanism,
        auth_vsn: 2,
        handshake_vsn: 1,
        mechanism_opts: [
          username: "klifeusr",
          password: "klifepwd"
        ]
      ]

      opts = [backend: socket_backend, active: false] ++ ssl_opts
      [host, port] = String.split(hostname, ":")
      {:ok, socket} = Socket.connect(host, String.to_integer(port), opts)

      # The brokers end SCRAM sessions after an hour (connections.max.reauth.ms), and
      # only the final SCRAM message carries it: the first one says 0
      {:ok, %{session_lifetime_ms: 3_600_000}} =
        Socket.authenticate(socket, socket_backend, sasl_opts)

      {data, version} = get_produce_msg_binary()
      :ok = apply(socket_backend, :send, [socket, data])
      {:ok, rcv_bin} = apply(socket_backend, :recv, [socket, 0, 5000])
      {:ok, _rcv_data} = Produce.deserialize_response(rcv_bin, version)
    end
  end

  @tag core: true
  test "fail with wrong scram password" do
    ssl_opts = [
      verify: :verify_peer,
      cacertfile: Path.relative("test/compose_files/ssl/ca.crt")
    ]

    sasl_opts = [
      mechanism: "SCRAM-SHA-512",
      auth_vsn: 2,
      handshake_vsn: 1,
      mechanism_opts: [
        username: "klifeusr",
        password: "wrongpwd"
      ]
    ]

    opts = [backend: :ssl, active: false, sasl_opts: sasl_opts] ++ ssl_opts
    [host, port] = String.split(@brokers_sasl[:kafka1], ":")

    assert_raise RuntimeError, ~r/ErrorCode: 58/, fn ->
      Socket.connect(host, String.to_integer(port), opts)
    end
  end

  # Brokers without a configured validator accept unsecured JWTs ("alg": "none"),
  # which is all a test needs: the client side does not depend on how tokens are signed
  def unsecured_jwt(expires_in_seconds) do
    exp = System.os_time(:second) + expires_in_seconds
    header = Base.url_encode64(~s({"alg":"none"}), padding: false)
    claims = Base.url_encode64(~s({"sub":"klifeusr","exp":#{exp}}), padding: false)
    "#{header}.#{claims}."
  end

  @tag core: true
  test "success with oauthbearer sasl opts" do
    ssl_opts = [
      verify: :verify_peer,
      cacertfile: Path.relative("test/compose_files/ssl/ca.crt")
    ]

    sasl_opts = [
      mechanism: "OAUTHBEARER",
      auth_vsn: 2,
      handshake_vsn: 1,
      mechanism_opts: [
        token_mfa: {__MODULE__, :unsecured_jwt, [60]},
        extensions: %{"traceId" => "klife"}
      ]
    ]

    socket_backend = :ssl
    opts = [backend: socket_backend, active: false, sasl_opts: sasl_opts] ++ ssl_opts

    for {_broker, hostname} <- @brokers_sasl do
      [host, port] = String.split(hostname, ":")
      {:ok, socket} = Socket.connect(host, String.to_integer(port), opts)

      {data, version} = get_produce_msg_binary()
      :ok = apply(socket_backend, :send, [socket, data])
      {:ok, rcv_bin} = apply(socket_backend, :recv, [socket, 0, 5000])
      {:ok, _rcv_data} = Produce.deserialize_response(rcv_bin, version)
    end
  end

  @tag core: true
  test "fail with expired oauthbearer token" do
    ssl_opts = [
      verify: :verify_peer,
      cacertfile: Path.relative("test/compose_files/ssl/ca.crt")
    ]

    sasl_opts = [
      mechanism: "OAUTHBEARER",
      auth_vsn: 2,
      handshake_vsn: 1,
      mechanism_opts: [
        token_mfa: {__MODULE__, :unsecured_jwt, [-60]}
      ]
    ]

    opts = [backend: :ssl, active: false, sasl_opts: sasl_opts] ++ ssl_opts
    [host, port] = String.split(@brokers_sasl[:kafka1], ":")

    assert_raise RuntimeError, ~r/ErrorCode: 58.*invalid_token/s, fn ->
      Socket.connect(host, String.to_integer(port), opts)
    end
  end

  @tag core: true
  test "oauthbearer session lasts until the token expires and re-authentication extends it" do
    ssl_opts = [
      verify: :verify_peer,
      cacertfile: Path.relative("test/compose_files/ssl/ca.crt")
    ]

    sasl_opts = fn expires_in_seconds ->
      [
        mechanism: "OAUTHBEARER",
        auth_vsn: 2,
        handshake_vsn: 1,
        mechanism_opts: [token_mfa: {__MODULE__, :unsecured_jwt, [expires_in_seconds]}]
      ]
    end

    socket_backend = :ssl
    opts = [backend: socket_backend, active: false] ++ ssl_opts
    [host, port] = String.split(@brokers_sasl[:kafka1], ":")
    {:ok, socket} = Socket.connect(host, String.to_integer(port), opts)

    {:ok, %{session_lifetime_ms: short}} =
      Socket.authenticate(socket, socket_backend, sasl_opts.(2))

    assert short in 1..2000

    {:ok, %{session_lifetime_ms: long}} =
      Socket.authenticate(socket, socket_backend, sasl_opts.(60))

    assert long > 50_000

    # Past the first token's expiry: without the re-authentication, the broker would
    # close the connection on this request
    Process.sleep(short + 500)
    {data, version} = get_produce_msg_binary()
    :ok = apply(socket_backend, :send, [socket, data])
    {:ok, rcv_bin} = apply(socket_backend, :recv, [socket, 0, 5000])
    {:ok, _rcv_data} = Produce.deserialize_response(rcv_bin, version)
  end
end
