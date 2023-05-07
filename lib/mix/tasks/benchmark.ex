if Mix.env() in [:dev] do
  defmodule Mix.Tasks.Benchmark do
    alias KlifeProtocol.Serializer
    alias KlifeProtocol.TestSupport.Helpers
    alias KlifeProtocol.Messages
    use Mix.Task

    def run(args) do
      Helpers.initialize_shared_storage()
      do_run_bench(List.first(args))
    end

    defp do_run_bench("produce_serialization") do
      headers = Helpers.genereate_headers()
      ts = DateTime.to_unix(DateTime.utc_now())

      generate_content = fn qty, size ->
        %{
          acks: 1,
          timeout_ms: 1000,
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

      input = %{headers: headers, content: generate_content.(1, 10_000)}

      Benchee.run(
        %{
          "test" => fn -> Messages.Produce.serialize_request(input, 0) end
        },
        time: 10,
        memory_time: 2
      )
    end

    defp do_run_bench("fetch_deserialization") do
      version = Messages.Fetch.max_supported_version()
      topic_name = "benchmark_topic"
      {:ok, topic_id} = Helpers.get_or_create_topic(topic_name)

      produce_content = fn qty, size ->
        Enum.map(1..qty, fn _ -> :rand.bytes(10_000) end)
      end

      {:ok,
       %{
         broker: broker,
         partition_index: partition_index,
         offset: offset_1
       }} = Helpers.produce_message(topic_name, produce_content.(1, 10_000))

      headers = Helpers.genereate_headers()

      content = %{
        replica_id: -1,
        max_wait_ms: 1000,
        min_bytes: 1,
        max_bytes: 1_000_000,
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
                partition_max_bytes: 1_000_000
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

      Benchee.run(
        %{
          "test" => fn -> Messages.Fetch.deserialize_response(binary_input, version) end
        },
        time: 10,
        memory_time: 2
      )
    end
  end
end
