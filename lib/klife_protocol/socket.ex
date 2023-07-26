defmodule KlifeProtocol.Socket do
  @moduledoc """
  Initialize a socket using `connect/3` of `:gen_tcp` or `:ssl` backend injecting the options `:binary` and `packet: 4`.

  Any other option will be forwarded to the proper backend module.

  Options:

  - backend: :gen_tcp or :ssl (default to :gen_tcp)
  - any other option will be forwarded to the backend module `connect/3` function
  """

  def connect(host, port, opts \\ []) do
    {backend, opts} = Keyword.pop(opts, :backend, :gen_tcp)
    must_have_opts = [:binary, packet: 4]
    backend.connect(String.to_charlist(host), port, opts ++ must_have_opts)
  end
end
