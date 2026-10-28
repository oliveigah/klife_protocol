defmodule KlifeProtocol.SASL.Mechanism.OAuthBearer do
  @behaviour KlifeProtocol.SASL.Mechanism.Behaviour

  # RFC 7628 initial client response the way Kafka parses it (KIP-255, extensions KIP-342).
  # Getting the token (OIDC client credentials, caching, refresh) is the caller's job:
  # `token_mfa` is applied on every authentication, so it should hand out a cached token

  @sep <<1>>

  def execute_auth(send_recv_fun, opts) do
    {mod, fun, args} = Keyword.fetch!(opts, :token_mfa)
    extensions = Keyword.get(opts, :extensions, %{})

    token =
      case apply(mod, fun, args) do
        token when is_binary(token) and token != "" ->
          token

        other ->
          raise "OAUTHBEARER token_mfa must return a non-empty binary, got: #{inspect(other)}"
      end

    kvpairs = Enum.map(extensions, fn {key, value} -> [key, "=", value, @sep] end)
    message = IO.iodata_to_binary(["n,,", @sep, "auth=Bearer ", token, @sep, kvpairs, @sep])

    case send_recv_fun.(message) do
      %{auth_bytes: ""} = final_resp ->
        {:ok, final_resp}

      # RFC 7628 §3.2.2: the error comes as a challenge; answering %x01 makes Kafka
      # fail the exchange, so it surfaces as ErrorCode 58 like any other auth failure
      %{auth_bytes: error_json} ->
        _ = send_recv_fun.(@sep)
        raise "OAUTHBEARER authentication failed: #{error_json}"
    end
  end
end
