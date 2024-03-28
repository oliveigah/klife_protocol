alias KlifeProtocol.TestSupport.Helpers

Helpers.initialize_shared_storage()

ssl_opts = [
  verify: :verify_peer,
  cacertfile: Path.relative("test/compose_files/ssl/ca.crt")
]
