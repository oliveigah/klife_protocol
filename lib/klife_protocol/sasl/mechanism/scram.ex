defmodule KlifeProtocol.SASL.Mechanism.Scram do
  @moduledoc false

  # fast_scram verifies the server signature in the final step; do not skip it.
  def execute_auth(send_recv_fun, opts, hash_method) do
    usr = Keyword.fetch!(opts, :username)
    pwd = Keyword.fetch!(opts, :password)

    config = %{
      entity: :client,
      hash_method: hash_method,
      username: escape_username(usr),
      auth_data: %{password: pwd}
    }

    state =
      case :fast_scram.mech_new(config) do
        {:ok, state} -> state
        _err -> raise "Invalid SCRAM configuration"
      end

    {:continue, client_first, state} = :fast_scram.mech_step(state, "")
    server_first = send_recv_fun.(client_first)

    {:continue, client_final, state} = step!(state, server_first)
    server_final = send_recv_fun.(client_final)

    {:ok, _, _} = step!(state, server_final)
    :ok
  end

  # The error is a protocol reason like "invalid-proof"; the state holds secrets and is not logged.
  defp step!(state, server_msg) do
    case :fast_scram.mech_step(state, server_msg) do
      {:error, reason, _state} -> raise "SCRAM authentication failed: #{reason}"
      result -> result
    end
  end

  # RFC 5802 section 5.1: "=" and "," must be escaped in the username.
  defp escape_username(usr) do
    usr
    |> String.replace("=", "=3D")
    |> String.replace(",", "=2C")
  end
end
