alias KlifeProtocol.TestSupport.Helpers

:ok = Helpers.initialize_shared_storage()
:ok = Helpers.initialize_connections(System.get_env("CONN_MODE"))

# Topics need to be created beforehand in order to prevent
# race conditions on topic creation with the kafka cluster
# that makes tests being flaky on the first execution

test_topics = [
  {"test_topic_default", []}
]

Enum.map(test_topics, fn {topic_name, opts} ->
  {:ok, _} = Helpers.get_or_create_topic(topic_name, opts)
end)

ExUnit.configure(include: Helpers.get_versions_to_test() ++ [core: true], exclude: :test)

ExUnit.start()
