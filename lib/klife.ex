defmodule Klife do
  alias Klife.Protocol.Messages

  def test do
    {:ok, socket} = :gen_tcp.connect('localhost', 19092, [:binary, active: false, packet: 4])

    msg = Messages.ApiVersions.serialize_request(%{correlation_id: 12345, client_id: "client"}, 0)
    :gen_tcp.send(socket, msg)
    {:ok, received_data} = :gen_tcp.recv(socket, 0, 1000)

    Messages.ApiVersions.deserialize_response(received_data, 0)
    |> IO.inspect(label: "Kafka Response API Versions Request")

    # msg =
    #   Messages.CreateTopics.serialize_request(
    #     %{
    #       correlation_id: 1357,
    #       client_id: "some_crazy_client",
    #       topics: [
    #         %{
    #           name: "my_first_topic_abc",
    #           num_partitions: 3,
    #           replication_factor: 2,
    #           assignments: [],
    #           configs: []
    #         }
    #       ],
    #       timeout_ms: 2000
    #     },
    #     0
    #   )

    # :gen_tcp.send(socket, msg)
    # {:ok, received_data} = :gen_tcp.recv(socket, 0, 1000)

    # Messages.CreateTopics.deserialize_response(received_data, 0)
    # |> IO.inspect(label: "Kafka Response Create Topics Request")

    :gen_tcp.close(socket)
  end
end
