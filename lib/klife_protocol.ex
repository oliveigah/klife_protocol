defmodule KlifeProtocol do
  alias KlifeProtocol.Messages
  alias KlifeProtocol.Connection

  def test do
    {:ok, conn} = Connection.new("localhost:29092")

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
