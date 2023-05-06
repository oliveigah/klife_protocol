if Mix.env() == :dev do
  defmodule Mix.Tasks.Benchmark do
    alias KlifeProtocol.Serializer
    use Mix.Task

    def run(args) do
      do_run_bench(List.first(args))
    end

    defp do_run_bench("crc32c") do
      input = :rand.bytes(10000)

      Benchee.run(
        %{
          "elixir_crc" => fn -> KlifeProtocol.CRC32c.execute(input) end,
          "nif_crc" => fn -> :crc32cer.nif(input) end
        },
        time: 10,
        memory_time: 2
      )
    end

    defp do_run_bench("create_topic_serialization") do
      Benchee.run(
        %{
          "klife_protocol" => fn ->
            KlifeProtocol.Messages.CreateTopics.serialize_request(
              %{
                headers: %{correlation_id: 1357, client_id: "some_crazy_client"},
                content: %{
                  topics: [
                    %{
                      name: "my_first_topic_abc_new_2",
                      num_partitions: 3,
                      replication_factor: 2,
                      assignments: [],
                      configs: []
                    }
                  ],
                  timeout_ms: 2000,
                  validate_only: true
                }
              },
              0
            )
          end,
          "kafka_protocol" => fn ->
            :kpro_req_lib.create_topics(
              0,
              [
                %{
                  name: "my_first_topic_abc_new_2",
                  num_partitions: 3,
                  replication_factor: 2,
                  assignments: [],
                  configs: []
                }
              ],
              %{timeout: 2000, validate_only: true}
            )
          end
        },
        time: 10,
        memory_time: 2
      )
    end

    defp do_run_bench("varint_serialization") do
      input = -512

      Benchee.run(
        %{
          "klife" => fn -> Serializer.execute(input, :varint) end,
          "varint_lib" => fn ->
            input
            |> Varint.Zigzag.encode()
            |> Varint.LEB128.encode()
          end
        },
        time: 10,
        memory_time: 2
      )
    end

    defp do_run_bench("unsigned_varint_serialization") do
      input = 300

      Benchee.run(
        %{
          "klife" => fn -> Serializer.execute(input, :unsigned_varint) end,
          "varint_lib" => fn -> Varint.LEB128.encode(input) end
        },
        time: 10,
        memory_time: 2
      )
    end

    defp do_run_bench("records_serialization") do
      headers = %{
        correlation_id: 12345,
        client_id: "klife_benchmark"
      }

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

      input = %{headers: headers, content: generate_content.(1, 100_000)}

      Benchee.run(
        %{
          "test" => fn ->
            KlifeProtocol.Messages.Produce.serialize_request(input, 0)
          end
        },
        time: 10,
        memory_time: 2
      )
    end
  end
end
