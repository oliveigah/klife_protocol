defmodule KAFE do
  alias KAFE.Protocol.Messages.ApiVersions

  def test do
    {:ok, socket} = :gen_tcp.connect('localhost', 19092, [:binary, active: false, packet: 4])
    msg = ApiVersions.serialize_request(%{correlation_id: 12345, client_id: "client"}, 0)
    :gen_tcp.send(socket, msg)
    {:ok, received_data} = :gen_tcp.recv(socket, 0, 1000)

    ApiVersions.deserialize_response(received_data, 0)
    |> IO.inspect(label: "Kafka Response")

    :gen_tcp.close(socket)
  end
end
