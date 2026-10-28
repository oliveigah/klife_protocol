defmodule KlifeProtocol.SASL.Mechanism.Behaviour do
  # send_recv_fun returns the SaslAuthenticate response content (raises on error codes);
  # mechanisms return the last one, which carries the session lifetime
  @callback execute_auth(send_recv_fun :: function, opts :: list) :: {:ok, final_response :: map}
end
