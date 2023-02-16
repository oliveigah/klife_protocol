defmodule Messages.FetchTest do
  use ExUnit.Case

  alias KlifeProtocol.Messages.Fetch
  alias KlifeProtocol.TestSupport.Helpers

  test "request and response v11", ctx do
    topic_name = Helpers.generate_topic_name(ctx)
    message_data = "some_message_data"
    {:ok, _topic_id} = Helpers.get_or_create_topic(topic_name)

    {:ok,
     %{
       broker: broker,
       partition_index: partition_index,
       offset: offset
     }} =
      Helpers.produce_message(topic_name, message_data,
        key: "record_key",
        headers: [
          %{key: "key_01", value: "val_01"},
          %{key: "key_02", value: "val_02"},
          %{key: "key_03", value: "val_03"}
        ]
      )

    version = 11

    headers = %{correlation_id: correlation_id} = Helpers.genereate_headers()

    content = %{
      replica_id: -1,
      max_wait_ms: 1000,
      min_bytes: 1,
      max_bytes: 100_000,
      isolation_level: 0,
      session_id: 0,
      session_epoch: 0,
      topics: [
        %{
          topic: topic_name,
          partitions: [
            %{
              partition: partition_index,
              current_leader_epoch: 0,
              fetch_offset: offset,
              log_start_offset: 0,
              partition_max_bytes: 100_000
            }
          ]
        }
      ],
      forgotten_topics_data: [],
      rack_id: "rack"
    }

    %{headers: resp_headers, content: resp_content} =
      %{headers: headers, content: content}
      |> Fetch.serialize_request(version)
      |> Helpers.send_message_to_broker(broker)
      |> Fetch.deserialize_response(version)

    assert %{correlation_id: ^correlation_id} = resp_headers
    assert resp_content.error_code == 0

    topic_resp = Enum.find(resp_content.responses, fn r -> r.topic == topic_name end)

    partition_resp =
      Enum.find(topic_resp.partitions, fn r -> r.partition_index == partition_index end)

    assert %{
             attributes: _,
             base_offset: ^offset,
             base_sequence: _,
             base_timestamp: _,
             batch_length: _,
             crc: _,
             last_offset_delta: 0,
             magic: 2,
             max_timestamp: _,
             partition_leader_epoch: _,
             producer_epoch: _,
             producer_id: _,
             records: records
           } = partition_resp.records

    assert [
             %{
               attributes: _,
               headers: [
                 %{key: "key_01", value: "val_01"},
                 %{key: "key_02", value: "val_02"},
                 %{key: "key_03", value: "val_03"}
               ],
               key: "record_key",
               offset_delta: 0,
               timestamp_delta: 0,
               value: "some_message_data"
             }
           ] = records
  end
end
