alias Mix.Tasks.Help
alias KlifeProtocol.TestSupport.Helpers
alias KlifeProtocol.Messages
alias KlifeProtocol.Connection

Helpers.initialize_shared_storage()

ssl_opts = [
  verify: :verify_peer,
  cacertfile: Path.relative("test/compose_files/truststore/ca.crt")
]
