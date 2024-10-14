defmodule KlifeProtocol.SASL.Mechanism.Behaviour do
  @callback execute_auth(sendrcv_fun :: function, opts :: list) :: :ok | {:error, reason :: term}
end
