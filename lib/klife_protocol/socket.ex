defmodule KlifeProtocol.Socket do
  @moduledoc """
  Initialize a socket using `connect/3` of `:gen_tcp` or `:ssl` backend injecting the options `:binary` and `packet: 4`.

  Options:

  - backend: `:gen_tcp` or `:ssl` (defaults to `:gen_tcp`)
  - sasl_opts: optional. sasl only. Is a keyword list containing:
    - mechanism: sasl mechanism string (eg. "PLAIN"),
    - sasl_auth_vsn: api version number to use for SaslAuthenticate messages,
    - sasl_handshake_vsn: api version number to use for SaslHandshake messages,
    - mechanism_opts: mechanism specific keywordlist
  - any other option will be forwarded to the backend module `connect/3` function
  """

  alias KlifeProtocol.Messages.SaslAuthenticate
  alias KlifeProtocol.Messages.SaslHandshake

  def connect(host, port, opts \\ []) do
    {backend, opts} = Keyword.pop(opts, :backend, :gen_tcp)
    {sasl_opts, opts} = Keyword.pop(opts, :sasl_opts, [])
    must_have_opts = [:binary, packet: 4]

    case backend.connect(String.to_charlist(host), port, opts ++ must_have_opts) do
      {:ok, socket} ->
        :ok = maybe_handle_sasl(socket, backend, sasl_opts)
        {:ok, socket}

      err ->
        err
    end
  end

  defp maybe_handle_sasl(_socket, _backend, []), do: :ok

  defp maybe_handle_sasl(socket, backend, sasl_opts) do
    mechanism = Keyword.fetch!(sasl_opts, :mechanism)
    sasl_auth_vsn = Keyword.fetch!(sasl_opts, :sasl_auth_vsn)
    sasl_handshake_vsn = Keyword.fetch!(sasl_opts, :sasl_handshake_vsn)
    mechanism_opts = Keyword.get(sasl_opts, :mechanism_opts, [])

    send_recv_raw_fun = fn data ->
      :ok = apply(backend, :send, [socket, data])
      {:ok, rcv_bin} = apply(backend, :recv, [socket, 0, 5000])
      rcv_bin
    end

    :ok = sasl_handshake(send_recv_raw_fun, mechanism, sasl_handshake_vsn)

    send_recv_fun = fn data ->
      to_send = %{content: %{auth_bytes: data}, headers: %{correlation_id: 123}}
      to_send_raw = SaslAuthenticate.serialize_request(to_send, sasl_auth_vsn)
      rcv_bin = send_recv_raw_fun.(to_send_raw)

      {:ok, %{content: resp}} =
        SaslAuthenticate.deserialize_response(rcv_bin, sasl_auth_vsn)

      case resp do
        %{error_code: 0, auth_bytes: auth_bytes} ->
          auth_bytes

        %{error_code: ec} ->
          raise """
          Unexpected error on SASL authentication message. ErrorCode: #{inspect(ec)}
          """
      end
    end

    case mechanism do
      "PLAIN" ->
        KlifeProtocol.SASLMechanism.Plain.execute_auth(send_recv_fun, mechanism_opts)

      other ->
        raise "Unsupported SASL mechanism #{inspect(other)}"
    end
  end

  defp sasl_handshake(send_rcv_raw_fun, mechanism, sasl_handshake_vsn) do
    to_send = %{content: %{mechanism: mechanism}, headers: %{correlation_id: 123}}
    to_send_raw = SaslHandshake.serialize_request(to_send, sasl_handshake_vsn)
    recv_bin = send_rcv_raw_fun.(to_send_raw)

    {:ok, %{content: resp}} =
      SaslHandshake.deserialize_response(recv_bin, sasl_handshake_vsn)

    case resp do
      %{error_code: 0, mechanisms: server_enabled_mechanisms} ->
        if mechanism in server_enabled_mechanisms do
          :ok
        else
          raise "Server does not support SASL mechanism #{mechanism}. Supported mechanisms are: #{inspect(server_enabled_mechanisms)}"
        end

      %{error_code: ec} ->
        raise """
        Unexpected error on SASL handhsake message. ErrorCode: #{inspect(ec)}
        """
    end
  end
end
