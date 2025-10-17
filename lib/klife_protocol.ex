defmodule KlifeProtocol do
  @moduledoc """
  Use the `KlifeProtocol.Messages` modules to serialze and deserialize messages.
  """

  def perf_test() do
    bin = File.read!("test/files/large_fetch_resp")

    t0 = System.monotonic_time(:millisecond)
    {:ok, _resp} = KlifeProtocol.Messages.Fetch.deserialize_response(bin, 4)
    tf = System.monotonic_time(:millisecond)

    tf - t0
  end
end
