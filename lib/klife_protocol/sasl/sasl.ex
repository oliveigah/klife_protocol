defmodule KlifeProtocol.SASL do
  alias KlifeProtocol.Messages.SaslAuthenticate
  alias KlifeProtocol.Messages.SaslHandshake

  @supported_mechanisms %{
    "PLAIN" => {KlifeProtocol.SASL.Mechanism.Plain, []},
    "SCRAM-SHA-256" => {KlifeProtocol.SASL.Mechanism.Scram, [digest: :sha256]},
    "SCRAM-SHA-512" => {KlifeProtocol.SASL.Mechanism.Scram, [digest: :sha512]},
    "OAUTHBEARER" => {KlifeProtocol.SASL.Mechanism.OAuthBearer, []}
  }

  def authenticate(mech, handshake_vsn, auth_vsn, mech_opts, send_recv_raw_fun) do
    {mech_mod, fixed_opts} =
      Map.get(@supported_mechanisms, mech) ||
        raise "Unsupported SASL mechanism #{inspect(mech)}. Supported ones are: #{inspect(Map.keys(@supported_mechanisms))}"

    send_recv_fun = fn data ->
      to_send = %{content: %{auth_bytes: data}, headers: %{correlation_id: 123}}
      to_send_raw = SaslAuthenticate.serialize_request(to_send, auth_vsn)
      rcv_bin = send_recv_raw_fun.(to_send_raw)

      {:ok, %{content: resp}} =
        SaslAuthenticate.deserialize_response(rcv_bin, auth_vsn)

      case resp do
        %{error_code: 0} ->
          resp

        %{error_code: ec, error_message: error_message} ->
          raise """
          Unexpected error on SASL authentication message. ErrorCode: #{inspect(ec)} ErrorMessage: #{inspect(error_message)}
          """
      end
    end

    :ok = handshake(mech, handshake_vsn, send_recv_raw_fun)

    # fixed_opts win: callers can't override what the mechanism name implies
    {:ok, final_resp} = mech_mod.execute_auth(send_recv_fun, Keyword.merge(mech_opts, fixed_opts))

    # SaslAuthenticate v0 has no session lifetime (nil): the broker may still end the session
    {:ok, %{session_lifetime_ms: Map.get(final_resp, :session_lifetime_ms)}}
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
