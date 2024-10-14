defmodule KlifeProtocol.Socket do
  @moduledoc """
  Initialize a socket using `connect/3` of `:gen_tcp` or `:ssl` backend injecting the options `:binary` and `packet: 4`.

  Options:

  - backend: `:gen_tcp` or `:ssl` (defaults to `:gen_tcp`)
  - sasl_opts: optional. sasl only. Is a keyword list containing:
    - mechanism: sasl mechanism string (eg. "PLAIN"),
    - auth_vsn: api version number to use for SaslAuthenticate messages,
    - handshake_vsn: api version number to use for SaslHandshake messages,
    - mechanism_opts: mechanism specific keywordlist
  - any other option will be forwarded to the backend module `connect/3` function
  """

  alias KlifeProtocol.SASL

  def connect(host, port, opts \\ []) do
    {backend, opts} = Keyword.pop(opts, :backend, :gen_tcp)
    {sasl_opts, opts} = Keyword.pop(opts, :sasl_opts, [])
    must_have_opts = [:binary, packet: 4]

    case backend.connect(String.to_charlist(host), port, opts ++ must_have_opts) do
      {:ok, socket} ->
        :ok = authenticate(socket, backend, sasl_opts)
        {:ok, socket}

      err ->
        err
    end
  end

  def authenticate(_socket, _backend, []), do: :ok

  def authenticate(socket, backend, sasl_opts) do
    mech = Keyword.fetch!(sasl_opts, :mechanism)
    handshake_vsn = Keyword.fetch!(sasl_opts, :handshake_vsn)
    auth_vsn = Keyword.fetch!(sasl_opts, :auth_vsn)
    mechanism_opts = Keyword.get(sasl_opts, :mechanism_opts, [])

    send_recv_raw_fun = fn data ->
      :ok = apply(backend, :send, [socket, data])
      {:ok, rcv_bin} = apply(backend, :recv, [socket, 0, 5000])
      rcv_bin
    end

    :ok = SASL.authenticate(mech, handshake_vsn, auth_vsn, mechanism_opts, send_recv_raw_fun)
  end
end
