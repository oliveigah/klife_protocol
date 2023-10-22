if Mix.env() in [:dev] do
  defmodule Mix.Tasks.Benchmark do
    alias KlifeProtocol.TestSupport.Helpers
    alias KlifeProtocol.Messages
    use Mix.Task

    def run(args) do
      Helpers.initialize_shared_storage()
      Helpers.initialize_connections(System.get_env("CONN_MODE"))
      apply(Mix.Tasks.Benchmark, :do_run_bench, args)
    end

    def produce_generate_content(qty, size) do
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
                    Enum.map(1..qty, fn idx ->
                      %{
                        attributes: 0,
                        timestamp_delta: idx - 1,
                        offset_delta: idx - 1,
                        key: "some_key",
                        value: :rand.bytes(size),
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
      Benchee.run(
        %{
          "prepend" => fn -> Enum.reduce(1..1000, [], fn i, acc -> [i | acc] end) end,
          "new_list" => fn -> Enum.reduce(1..1000, [], fn i, acc -> [acc, i] end) end
        },
        time: 10,
        memory_time: 2
      )
    end

    def do_run_bench("produce_serialization") do
      headers = Helpers.genereate_headers()

      input_1_500 = %{
        headers: headers,
        content: produce_generate_content(1, 500_000)
      }

      input_10_50 = %{
        headers: headers,
        content: produce_generate_content(10, 50_000)
      }

      input_50_10 = %{
        headers: headers,
        content: produce_generate_content(50, 10_000)
      }

      input_100_5 = %{
        headers: headers,
        content: produce_generate_content(100, 5_000)
      }

      File.write(
        Path.relative("/priv/test_resources/produce_test_binary"),
        :erlang.term_to_binary(input_50_10)
      )

      Benchee.run(
        %{
          "1x500" => fn -> Messages.Produce.serialize_request(input_1_500, 9) end,
          "10x50" => fn -> Messages.Produce.serialize_request(input_10_50, 9) end,
          "50x10" => fn -> Messages.Produce.serialize_request(input_50_10, 9) end,
          "100x5" => fn -> Messages.Produce.serialize_request(input_100_5, 9) end
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
         broker: _broker,
         partition_index: _partition_index,
         offset: offset_1
       }} = Helpers.produce_message(topic_name, produce_content.(1, 500_000))

      {:ok,
       %{
         broker: _broker,
         partition_index: _partition_index,
         offset: offset_2
       }} = Helpers.produce_message(topic_name, produce_content.(10, 50_000))

      {:ok,
       %{
         broker: _broker,
         partition_index: _partition_index,
         offset: offset_3
       }} = Helpers.produce_message(topic_name, produce_content.(100, 5_000))

      {:ok,
       %{
         broker: broker,
         partition_index: partition_index,
         offset: offset_4
       }} = Helpers.produce_message(topic_name, produce_content.(50, 10_000))

      headers = Helpers.genereate_headers()

      content_1 = %{
        replica_id: -1,
        max_wait_ms: 1000,
        min_bytes: 1,
        max_bytes: 0,
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
                partition_max_bytes: 0
              }
            ]
          }
        ],
        forgotten_topics_data: [],
        rack_id: "rack"
      }

      binary_input_1_500 =
        %{headers: headers, content: content_1}
        |> Messages.Fetch.serialize_request(version)
        |> Helpers.send_message_to_broker(broker)

      content_2 = %{
        replica_id: -1,
        max_wait_ms: 1000,
        min_bytes: 1,
        max_bytes: 0,
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
                fetch_offset: offset_2,
                last_fetched_epoch: 0,
                log_start_offset: 0,
                partition_max_bytes: 0
              }
            ]
          }
        ],
        forgotten_topics_data: [],
        rack_id: "rack"
      }

      binary_input_10_50 =
        %{headers: headers, content: content_2}
        |> Messages.Fetch.serialize_request(version)
        |> Helpers.send_message_to_broker(broker)

      content_3 = %{
        replica_id: -1,
        max_wait_ms: 1000,
        min_bytes: 1,
        max_bytes: 0,
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
                fetch_offset: offset_3,
                last_fetched_epoch: 0,
                log_start_offset: 0,
                partition_max_bytes: 0
              }
            ]
          }
        ],
        forgotten_topics_data: [],
        rack_id: "rack"
      }

      binary_input_100_5 =
        %{headers: headers, content: content_3}
        |> Messages.Fetch.serialize_request(version)
        |> Helpers.send_message_to_broker(broker)

      content_4 = %{
        replica_id: -1,
        max_wait_ms: 1000,
        min_bytes: 1,
        max_bytes: 0,
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
                fetch_offset: offset_4,
                last_fetched_epoch: 0,
                log_start_offset: 0,
                partition_max_bytes: 0
              }
            ]
          }
        ],
        forgotten_topics_data: [],
        rack_id: "rack"
      }

      binary_input_50_10 =
        %{headers: headers, content: content_4}
        |> Messages.Fetch.serialize_request(version)
        |> Helpers.send_message_to_broker(broker)

      File.write(Path.relative("/priv/test_resources/fetch_test_binary"), binary_input_50_10)

      Benchee.run(
        %{
          "1x500" => fn -> Messages.Fetch.deserialize_response(binary_input_1_500, version) end,
          "10x50" => fn -> Messages.Fetch.deserialize_response(binary_input_10_50, version) end,
          "50x10" => fn -> Messages.Fetch.deserialize_response(binary_input_50_10, version) end,
          "100x5" => fn -> Messages.Fetch.deserialize_response(binary_input_100_5, version) end
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
