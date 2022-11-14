defmodule KlifeProtocol do
  alias KlifeProtocol.Messages
  alias KlifeProtocol.Connection

  def test do
    {:ok, conn} = Connection.new("localhost:19092")

    api_version_v = 3

    api_version_input = %{
      headers: %{
        correlation_id: 1029,
        client_id: nil
      },
      content: %{
        client_software_name: "name",
        client_software_version: "1"
      }
    }

    send_msg_with_log(Messages.ApiVersions, api_version_input, api_version_v, conn)

    create_topic_v = 0

    create_topics_input = %{
      headers: %{correlation_id: 1234, client_id: "some_crazy_client"},
      content: %{
        topics: [
          %{
            name: "produce_topic_test",
            num_partitions: 3,
            replication_factor: 2,
            assignments: [],
            configs: []
          }
        ],
        timeout_ms: 2000,
        validate_only: false
      }
    }

    send_msg_with_log(Messages.CreateTopics, create_topics_input, create_topic_v, conn)

    produce_v = 8

    ts = DateTime.to_unix(DateTime.utc_now())

    produce_input = %{
      headers: %{correlation_id: 4321, client_id: "some_crazy_client"},
      content: %{
        acks: 1,
        timeout_ms: 2000,
        topic_data: [
          %{
            name: "produce_topic_test",
            partition_data: [
              %{
                index: 1,
                records: %{
                  base_offset: 1,
                  partition_leader_epoch: -1,
                  magic: 2,
                  attributes: 0,
                  last_offset_delta: 0,
                  base_timestamp: ts,
                  max_timestamp: ts,
                  producer_id: 1,
                  producer_epoch: 1,
                  base_sequence: 0,
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
    }

    send_msg_with_log(Messages.Produce, produce_input, produce_v, conn)

    Connection.close(conn)
  end

  defp send_msg_with_log(message_mod, input, v, conn) do
    msg = message_mod.serialize_request(input, v)

    Connection.send_data(conn, msg)

    {:ok, received_data} = Connection.read_data(conn)

    message_mod.deserialize_response(received_data, v)
    |> IO.inspect(label: "Kafka Response to #{message_mod} Request")
  end
end
