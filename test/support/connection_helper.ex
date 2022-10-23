defmodule KlifeProtocol.TestSupport.ConnectionHelper do
  alias KlifeProtocol.Connection

  @default_brokers [
    broker1: "localhost:19092",
    broker2: "localhost:29092",
    broker3: "localhost:39092"
  ]

  def start_connections() do
    @default_brokers
    |> Enum.map(fn {name, host} ->
      {:ok, conn} = Connection.new(host)
      {name, conn}
    end)
    |> Map.new()
  end
end
