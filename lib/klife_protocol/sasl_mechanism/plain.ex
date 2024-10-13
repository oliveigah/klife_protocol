defmodule KlifeProtocol.SASLMechanism.Plain do
  @behaviour KlifeProtocol.SASLMechanism.Behaviour

  def execute_auth(send_recv_fun, opts) do
    usr = Keyword.fetch!(opts, :username)
    pwd = Keyword.fetch!(opts, :password)
    to_send = :erlang.iolist_to_binary([0, usr, 0, pwd])
    "" = send_recv_fun.(to_send)
    :ok
  end
end
