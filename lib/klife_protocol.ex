defmodule KlifeProtocol do
  alias KlifeProtocol.Messages

  def test do
    {:ok, socket} = :gen_tcp.connect('localhost', 19092, [:binary, active: false, packet: 4])

    api_version_message_v = 3

    msg =
      Messages.ApiVersions.serialize_request(
        %{
          correlation_id: 123_456,
          client_id: "client",
          client_software_name: "client",
          client_software_version: "1"
        },
        api_version_message_v
      )

    :gen_tcp.send(socket, msg)
    {:ok, received_data} = :gen_tcp.recv(socket, 0, 1000)

    Messages.ApiVersions.deserialize_response(received_data, api_version_message_v)
    |> IO.inspect(label: "Kafka Response API Versions Request")

    create_topic_v = 5

    msg =
      Messages.CreateTopics.serialize_request(
        %{
          correlation_id: 1357,
          client_id: "some_crazy_client",
          topics: [
            %{
              name: "my_first_topic_abc_new_1",
              num_partitions: 3,
              replication_factor: 2,
              assignments: [],
              configs: []
            }
          ],
          timeout_ms: 2000,
          validate_only: true
        },
        create_topic_v
      )

    :gen_tcp.send(socket, msg)
    {:ok, received_data} = :gen_tcp.recv(socket, 0, 1000)

    Messages.CreateTopics.deserialize_response(received_data, create_topic_v)
    |> IO.inspect(label: "Kafka Response Create Topics Request")

    :gen_tcp.close(socket)
  end
end
