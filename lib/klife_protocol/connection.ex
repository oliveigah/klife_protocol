defmodule KlifeProtocol.Connection do
  alias KlifeProtocol.Connection
  defstruct [:socket, :host, :port, :connect_timeout, :read_timeout]

  @default_opts %{
    connect_timeout: :timer.seconds(5),
    read_timeout: :timer.seconds(5)
  }

  def new(url, opts \\ []) do
    %{host: host, port: port} = parse_url(url)
    socket_opts = [:binary, active: false, packet: 4]
    conn_opts = Map.merge(@default_opts, Map.new(opts))

    case :gen_tcp.connect(String.to_charlist(host), port, socket_opts, conn_opts.connect_timeout) do
      {:ok, socket} ->
        conn =
          %Connection{socket: socket, host: host, port: port}
          |> Map.merge(conn_opts)

        {:ok, conn}

      {:error, reason} ->
        {:error, reason}
    end
  end

  def send_data(%Connection{} = conn, msg), do: :gen_tcp.send(conn.socket, msg)

  def read_data(%Connection{} = conn),
    do: :gen_tcp.recv(conn.socket, 0, conn.read_timeout)

  def close(%Connection{} = conn), do: :gen_tcp.close(conn.socket)

  defp parse_url(url) do
    [host, port] = String.split(url, ":")
    %{host: host, port: String.to_integer(port)}
  end
end
