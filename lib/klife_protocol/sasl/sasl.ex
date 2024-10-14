defmodule KlifeProtocol.SASL do
  alias KlifeProtocol.Messages.SaslAuthenticate
  alias KlifeProtocol.Messages.SaslHandshake

  @supported_mechanisms %{
    "PLAIN" => KlifeProtocol.SASL.Mechanism.Plain
  }

  def authenticate(mech, handshake_vsn, auth_vsn, mech_opts, send_recv_raw_fun) do
    send_recv_fun = fn data ->
      to_send = %{content: %{auth_bytes: data}, headers: %{correlation_id: 123}}
      to_send_raw = SaslAuthenticate.serialize_request(to_send, auth_vsn)
      rcv_bin = send_recv_raw_fun.(to_send_raw)

      {:ok, %{content: resp}} =
        SaslAuthenticate.deserialize_response(rcv_bin, auth_vsn)

      case resp do
        %{error_code: 0, auth_bytes: auth_bytes} ->
          auth_bytes

        %{error_code: ec} ->
          raise """
          Unexpected error on SASL authentication message. ErrorCode: #{inspect(ec)}
          """
      end
    end

    :ok = handshake(mech, handshake_vsn, send_recv_raw_fun)

    case Map.get(@supported_mechanisms, mech) do
      nil ->
        raise "Unsupported SASL mechanism #{inspect(mech)}. Supported ones are: #{inspect(Map.keys(@supported_mechanisms))}"

      mech_mod ->
        :ok = apply(mech_mod, :execute_auth, [send_recv_fun, mech_opts])
    end
  end

  defp handshake(mech, hanshake_vsn, send_rcv_raw_fun) do
    to_send = %{content: %{mechanism: mech}, headers: %{correlation_id: 123}}
    to_send_raw = SaslHandshake.serialize_request(to_send, hanshake_vsn)
    recv_bin = send_rcv_raw_fun.(to_send_raw)

    {:ok, %{content: resp}} = SaslHandshake.deserialize_response(recv_bin, hanshake_vsn)

    case resp do
      %{error_code: 0, mechanisms: server_enabled_mechanisms} ->
        if mech in server_enabled_mechanisms do
          :ok
        else
          raise "Server does not support SASL mechanism #{mech}. Supported mechanisms are: #{inspect(server_enabled_mechanisms)}"
        end

      %{error_code: ec} ->
        raise """
        Unexpected error on SASL handhsake message. ErrorCode: #{inspect(ec)}
        """
    end
  end
end
