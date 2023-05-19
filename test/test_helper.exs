:ok = KlifeProtocol.TestSupport.Helpers.initialize_shared_storage()
:ok = KlifeProtocol.TestSupport.Helpers.initialize_connections(System.get_env("CONN_MODE"))

ExUnit.start()
