defmodule KlifeProtocol.ScramTest do
  use ExUnit.Case, async: true

  alias KlifeProtocol.SASL.Mechanism.Scram

  # A real broker never sends what these tests send, so the client-side
  # checks are exercised against a fake server instead

  @opts [digest: :sha512, username: "klifeusr", password: "klifepwd"]
  @salt Base.encode64("klife-salt")

  # Answers the client-first message with `server_first.(client_nonce)`
  # and the client-final message with `server_final`
  defp fake_server(server_first, server_final) do
    fn
      "n,,n=klifeusr,r=" <> client_nonce -> server_first.(client_nonce)
      "c=" <> _client_final -> server_final
    end
  end

  @tag core: true
  test "rejects a forged server signature" do
    server =
      fake_server(
        fn client_nonce -> "r=#{client_nonce}srv,s=#{@salt},i=4096" end,
        "v=" <> Base.encode64("forged")
      )

    assert_raise RuntimeError, "SCRAM server signature mismatch", fn ->
      Scram.execute_auth(server, @opts)
    end
  end

  @tag core: true
  test "rejects a server nonce that does not extend ours" do
    server = fake_server(fn _client_nonce -> "r=srv,s=#{@salt},i=4096" end, nil)

    assert_raise RuntimeError, "SCRAM server nonce does not extend the client nonce", fn ->
      Scram.execute_auth(server, @opts)
    end
  end

  @tag core: true
  test "rejects fewer iterations than kafka's minimum" do
    server = fake_server(fn client_nonce -> "r=#{client_nonce}srv,s=#{@salt},i=4095" end, nil)

    assert_raise RuntimeError, ~r/asked for 4095 iterations/, fn ->
      Scram.execute_auth(server, @opts)
    end
  end
end
