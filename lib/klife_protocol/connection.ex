defmodule KlifeProtocol.Connection do
  @moduledoc """
  Simple wrapper of `:gen_tcp` and `:ssl` erlang modules.

  Set socket opts that are needed to proper communicate with kafka broker (mainly `packet: 4`).

  Since it is a simple wrapper, clients may choose to set up their on
  connection or just initialize them with this module and extracting the
  `socket` attribute and using it directly with `:gen_tcp` and `:ssl` modules.
  """
  alias KlifeProtocol.Connection
  defstruct [:socket, :host, :port, :connect_timeout, :read_timeout, :ssl]

  @default_opts %{
    connect_timeout: :timer.seconds(5),
    read_timeout: :timer.seconds(5),
    ssl: false,
    ssl_opts: %{}
  }

  @doc """
  Initialize a connection.

  Options:

  - connect_timeout: Timeout to initialze the connection. (default 5 seconds)
  - read_timeout: Timeout to read messages from socket. (default 5 seconds)
  - ssl: Define the backend to use, `:gen_tcp` when false and `:ssl` when true (default false)
  - ssl_opts: only used when ssl: true, this option will be forwareded to `:ssl.connect/4` as its 3rd argument
  """
  def new(url, opts \\ []) do
    %{host: host, port: port} = parse_url(url)
    socket_opts = [:binary, active: false, packet: 4]
    conn_opts = Map.merge(@default_opts, Map.new(opts))

    init_connection(String.to_charlist(host), port, socket_opts, conn_opts)
  end

  defp init_connection(host, port, socket_opts, %{ssl: false} = conn_opts) do
    case :gen_tcp.connect(host, port, socket_opts, conn_opts.connect_timeout) do
      {:ok, socket} ->
        filtered_conn_opts = Map.take(conn_opts, Map.keys(%Connection{}))

        conn =
          %Connection{socket: socket, host: host, port: port}
          |> Map.merge(filtered_conn_opts)

        {:ok, conn}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp init_connection(host, port, socket_opts, %{ssl: true} = conn_opts) do
    ssl_opts = Map.get(conn_opts, :ssl_opts, [])

    case :ssl.connect(host, port, socket_opts ++ ssl_opts, conn_opts.connect_timeout) do
      {:ok, socket} ->
        filtered_conn_opts = Map.take(conn_opts, Map.keys(%Connection{}))

        conn =
          %Connection{socket: socket, host: host, port: port}
          |> Map.merge(filtered_conn_opts)

        {:ok, conn}

      {:error, reason} ->
        {:error, reason}
    end
  end

  def send_data(%Connection{ssl: false} = conn, msg), do: :gen_tcp.send(conn.socket, msg)
  def send_data(%Connection{ssl: true} = conn, msg), do: :ssl.send(conn.socket, msg)

  def read_data(%Connection{ssl: false} = conn),
    do: :gen_tcp.recv(conn.socket, 0, conn.read_timeout)

  def read_data(%Connection{ssl: true} = conn),
    do: :ssl.recv(conn.socket, 0, conn.read_timeout)

  def close(%Connection{ssl: false} = conn), do: :gen_tcp.close(conn.socket)
  def close(%Connection{ssl: true} = conn), do: :ssl.close(conn.socket)

  defp parse_url(url) do
    [host, port] = String.split(url, ":")
    %{host: host, port: String.to_integer(port)}
  end
end
