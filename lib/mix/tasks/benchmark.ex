if Mix.env() in [:dev] do
  defmodule Mix.Tasks.Benchmark do
    alias KlifeProtocol.TestSupport.Helpers
    alias KlifeProtocol.Messages
    use Mix.Task

    @msg_qty 50
    @msg_size 10_000

    def run(args) do
      Helpers.initialize_shared_storage()
      apply(Mix.Tasks.Benchmark, :do_run_bench, args)
    end

    def produce_generate_content() do
      ts = DateTime.to_unix(DateTime.utc_now())

      %{
        acks: 1,
        timeout_ms: 1000,
        transactional_id: "1",
        topic_data: [
          %{
            name: "some_benchmark_topic",
            partition_data: [
              %{
                index: 0,
                records: %{
                  base_offset: 0,
                  partition_leader_epoch: -1,
                  magic: 2,
                  attributes: 0,
                  last_offset_delta: 0,
                  base_timestamp: ts,
                  max_timestamp: ts,
                  producer_id: 1,
                  producer_epoch: 1,
                  base_sequence: 1,
                  records:
                    Enum.map(1..@msg_qty, fn idx ->
                      %{
                        attributes: 0,
                        timestamp_delta: idx - 1,
                        offset_delta: idx - 1,
                        key: "some_key",
                        value: :rand.bytes(@msg_size),
                        headers: [
                          %{key: "header_key", value: "header_value"}
                        ]
                      }
                    end)
                }
              }
            ]
          }
        ]
      }
    end

    def do_run_bench("test") do
      input = %{a: 1, b: 2, c: 3}

      Benchee.run(
        %{
          "test" => fn -> Map.get(input, :b) end
        },
        time: 10,
        memory_time: 2
      )
    end

    def do_run_bench("produce_serialization") do
      headers = Helpers.genereate_headers()

      input = %{
        headers: headers,
        content: produce_generate_content()
      }

      File.write(
        Path.relative("/priv/test_resources/produce_test_binary"),
        :erlang.term_to_binary(input)
      )

      input =
        "/priv/test_resources/produce_test_binary"
        |> Path.relative()
        |> File.read!()
        |> :erlang.binary_to_term()

      Benchee.run(
        %{
          "main" => fn -> Messages.Produce.serialize_request(input, 9) end
        },
        time: 10,
        memory_time: 2
      )
    end

    def do_run_bench("fetch_deserialization") do
      version = 13
      topic_name = "benchmark_topic"

      {:ok, topic_id} = Helpers.get_or_create_topic(topic_name)

      produce_content = fn qty, size ->
        Enum.map(1..qty, fn _ -> :rand.bytes(size) end)
      end

      {:ok,
       %{
         broker: broker,
         partition_index: partition_index,
         offset: offset_1
       }} = Helpers.produce_message(topic_name, produce_content.(@msg_qty, @msg_size))

      headers = Helpers.genereate_headers()

      content = %{
        replica_id: -1,
        max_wait_ms: 1000,
        min_bytes: 1,
        max_bytes: @msg_qty * @msg_size + 10_000,
        isolation_level: 0,
        session_id: 0,
        session_epoch: 0,
        topics: [
          %{
            topic_id: topic_id,
            partitions: [
              %{
                partition: partition_index,
                current_leader_epoch: 0,
                fetch_offset: offset_1,
                last_fetched_epoch: 0,
                log_start_offset: 0,
                partition_max_bytes: @msg_qty * @msg_size + 10_000
              }
            ]
          }
        ],
        forgotten_topics_data: [],
        rack_id: "rack"
      }

      binary_input =
        %{headers: headers, content: content}
        |> Messages.Fetch.serialize_request(version)
        |> Helpers.send_message_to_broker(broker)

      File.write(Path.relative("/priv/test_resources/fetch_test_binary"), binary_input)
      binary_input = File.read!(Path.relative("/priv/test_resources/fetch_test_binary"))

      Benchee.run(
        %{
          "main" => fn ->
            Messages.Fetch.deserialize_response(binary_input, version)
          end
        },
        time: 10,
        memory_time: 2
      )
    end

    def profile_fetch() do
      binary_input = File.read!(Path.relative("/priv/test_resources/fetch_test_binary"))
      Messages.Fetch.deserialize_response(binary_input, 13)
    end

    def profile_produce() do
      input =
        "/priv/test_resources/produce_test_binary"
        |> Path.relative()
        |> File.read!()
        |> :erlang.binary_to_term()

      Messages.Produce.serialize_request(input, 9)
    end
  end
end
