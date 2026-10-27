defmodule KlifeProtocol.SASL.Mechanism.ScramSha512 do
  @behaviour KlifeProtocol.SASL.Mechanism.Behaviour

  alias KlifeProtocol.SASL.Mechanism.Scram

  def execute_auth(send_recv_fun, opts), do: Scram.execute_auth(send_recv_fun, opts, :sha512)
end
