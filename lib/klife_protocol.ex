defmodule KlifeProtocol do
  alias KlifeProtocol.Messages
  alias KlifeProtocol.Connection

  def test do
    {:ok, conn} = Connection.new("localhost:19092")

    # api_version_message_v = 3

    # Enum.map(1..5, fn i ->
    #   msg =
    #     Messages.ApiVersions.serialize_request(
    #       %{
    #         headers: %{
    #           correlation_id: i,
    #           client_id: nil
    #         },
    #         content: %{
    #           client_software_name: "name",
    #           client_software_version: "1"
    #         }
    #       },
    #       api_version_message_v
    #     )

    #   Connection.send_data(conn, msg)
    # end)

    # Enum.map(1..5, fn i ->
    #   {:ok, received_data} = Connection.read_data(conn)

    #   Messages.ApiVersions.deserialize_response(received_data, api_version_message_v)
    #   |> IO.inspect(label: "Kafka Response API Versions Request #{i}")
    # end)

    metadata_v = 0

    msg =
      Messages.Metadata.serialize_request(
        %{
          headers: %{
            correlation_id: 123,
            client_id: nil
          },
          content: %{
            topics: [%{name: "some_topic"}, %{name: "some_craaazy_topic_2"}],
            allow_auto_topic_creation: true,
            include_cluster_authorized_operations: true,
            include_topic_authorized_operations: true
          }
        },
        metadata_v
      )

    Connection.send_data(conn, msg)

    {:ok, received_data} = Connection.read_data(conn)

    Messages.Metadata.deserialize_response(received_data, metadata_v)
    |> IO.inspect(label: "Kafka Response Metadata Request")

    # create_topic_v = 5

    # msg =
    #   Messages.CreateTopics.serialize_request(
    #     %{
    #       headers: %{correlation_id: 1357, client_id: "some_crazy_client"},
    #       content: %{
    #         topics: [
    #           %{
    #             name: "my_first_topic_abc_new_2",
    #             num_partitions: 3,
    #             replication_factor: 2,
    #             assignments: [],
    #             configs: []
    #           }
    #         ],
    #         timeout_ms: 2000,
    #         validate_only: true
    #       }
    #     },
    #     create_topic_v
    #   )

    # Connection.send_data(conn, msg)
    # {:ok, received_data} = Connection.read_data(conn)

    # Messages.CreateTopics.deserialize_response(received_data, create_topic_v)
    # |> IO.inspect(label: "Kafka Response Create Topics Request")

    Connection.close(conn)
  end
end
