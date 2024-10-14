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
    version = 0
    partition_index = 0
    ts = DateTime.to_unix(DateTime.utc_now())

    content = %{
      acks: 1,
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
                producer_id: 1,
                producer_epoch: 1,
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
        :ok = Socket.authenticate(socket, socket_backend, sasl_opts)
        socket
      end)

    Enum.each(sockets, fn socket ->
      {data, version} = get_produce_msg_binary()
      :ok = apply(socket_backend, :send, [socket, data])
      {:ok, rcv_bin} = apply(socket_backend, :recv, [socket, 0, 5000])
      {:ok, _rcv_data} = Produce.deserialize_response(rcv_bin, version)
    end)
  end
end
