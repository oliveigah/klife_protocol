defmodule KlifeProtocol.SASL.Mechanism.Scram do
  @behaviour KlifeProtocol.SASL.Mechanism.Behaviour

  # RFC 5802 + RFC 7677 the way Kafka uses them: no channel binding,
  # password sent as raw UTF-8 bytes (no SASLprep, same as Kafka's Java client)

  # Kafka's own minimum for both SCRAM mechanisms; fewer means a weak or rogue server
  @min_iterations 4096
  @gs2_header "n,,"

  def execute_auth(send_recv_fun, opts) do
    digest = Keyword.fetch!(opts, :digest)
    key_length = key_length(digest)
    username = Keyword.fetch!(opts, :username)
    password = Keyword.fetch!(opts, :password)

    client_nonce = Base.encode64(:crypto.strong_rand_bytes(32))
    client_first_bare = "n=#{escape(username)},r=#{client_nonce}"

    %{auth_bytes: server_first} = send_recv_fun.(@gs2_header <> client_first_bare)
    %{"r" => nonce, "s" => salt, "i" => iterations} = parse(server_first)
    iterations = String.to_integer(iterations)

    if not String.starts_with?(nonce, client_nonce),
      do: raise("SCRAM server nonce does not extend the client nonce")

    if iterations < @min_iterations,
      do: raise("SCRAM server asked for #{iterations} iterations, minimum is #{@min_iterations}")

    salted_password =
      :crypto.pbkdf2_hmac(digest, password, Base.decode64!(salt), iterations, key_length)

    client_key = hmac(digest, salted_password, "Client Key")
    client_final_without_proof = "c=#{Base.encode64(@gs2_header)},r=#{nonce}"
    auth_message = Enum.join([client_first_bare, server_first, client_final_without_proof], ",")
    client_signature = hmac(digest, :crypto.hash(digest, client_key), auth_message)
    client_proof = :crypto.exor(client_key, client_signature)

    %{auth_bytes: server_final} =
      final_resp =
      send_recv_fun.(client_final_without_proof <> ",p=" <> Base.encode64(client_proof))

    server_signature = hmac(digest, hmac(digest, salted_password, "Server Key"), auth_message)

    case parse(server_final) do
      %{"v" => v} ->
        if Base.decode64!(v) == server_signature,
          do: {:ok, final_resp},
          else: raise("SCRAM server signature mismatch")

      %{"e" => reason} ->
        raise "SCRAM authentication failed: #{reason}"
    end
  end

  defp key_length(:sha256), do: 32
  defp key_length(:sha512), do: 64

  defp hmac(digest, key, data), do: :crypto.mac(:hmac, digest, key, data)

  defp escape(username),
    do: username |> String.replace("=", "=3D") |> String.replace(",", "=2C")

  defp parse(message) do
    message
    |> String.split(",")
    |> Map.new(fn <<key::binary-size(1), "=", value::binary>> -> {key, value} end)
  end
end
