defmodule KlifeProtocol do
  alias KlifeProtocol.Messages
  alias KlifeProtocol.Connection

  def test do
    {:ok, conn} = Connection.new("localhost:19092")
    version = 1
    input = %{headers: %{correlation_id: 123}, content: %{}}
    serialized_msg = Messages.ApiVersions.serialize_request(input, version)
    :ok = Connection.send_data(conn, serialized_msg)
    {:ok, received_data} = Connection.read_data(conn)
    {:ok, response} = Messages.ApiVersions.deserialize_response(received_data, version)
    IO.inspect(response)
  end
end
