defmodule KlifeProtocol.SASL.Mechanism.Plain do
  @behaviour KlifeProtocol.SASL.Mechanism.Behaviour

  def execute_auth(send_recv_fun, opts) do
    usr = Keyword.fetch!(opts, :username)
    pwd = Keyword.fetch!(opts, :password)
    to_send = :erlang.iolist_to_binary([0, usr, 0, pwd])
    %{auth_bytes: ""} = final_resp = send_recv_fun.(to_send)
    {:ok, final_resp}
  end
end
