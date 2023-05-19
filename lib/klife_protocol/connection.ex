defmodule KlifeProtocol.Connection do
  alias KlifeProtocol.Connection
  defstruct [:socket, :host, :port, :connect_timeout, :read_timeout, :ssl]

  @default_opts %{
    connect_timeout: :timer.seconds(5),
    read_timeout: :timer.seconds(5),
    ssl: false
  }

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
