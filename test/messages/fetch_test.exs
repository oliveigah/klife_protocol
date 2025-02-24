defmodule Messages.FetchTest do
  use ExUnit.Case, async: true

  alias KlifeProtocol.Messages.Fetch
  alias KlifeProtocol.TestSupport.Helpers
  alias KlifeProtocol.RecordBatch

  @tag "#{Fetch.api_key()}": 4
  test "request and response v4", _ctx do
    version = 4
    topic_name = "test_topic_default"
    message_data_1 = ["msg_1", "msg_2", "msg_3"]
    message_data_2 = ["msg_4", "msg_5", "msg_6"]
    message_data_3 = ["msg_7", "msg_8", "msg_9"]

    {:ok, _topic_id} = Helpers.get_or_create_topic(topic_name)

    {:ok,
     %{
       broker: broker,
       partition_index: partition_index,
       offset: offset_1
     }} = Helpers.produce_message(topic_name, message_data_1)

    {:ok,
     %{
       broker: ^broker,
       partition_index: ^partition_index,
       offset: offset_2
     }} = Helpers.produce_message(topic_name, message_data_2)

    {:ok,
     %{
       broker: ^broker,
       partition_index: ^partition_index,
       offset: offset_3
     }} = Helpers.produce_message(topic_name, message_data_3)

    headers = %{correlation_id: correlation_id} = Helpers.generate_headers()

    content = %{
      replica_id: -1,
      max_wait_ms: 1000,
      min_bytes: 1,
      max_bytes: 100_000,
      isolation_level: 0,
      topics: [
        %{
          topic: topic_name,
          partitions: [
            %{
              partition: partition_index,
              fetch_offset: offset_1,
              partition_max_bytes: 100_000
            }
          ]
        }
      ]
    }

    {:ok, %{headers: resp_headers, content: resp_content}} =
      %{headers: headers, content: content}
      |> Fetch.serialize_request(version)
      |> Helpers.send_message_to_broker(broker)
      |> Fetch.deserialize_response(version)

    assert %{correlation_id: ^correlation_id} = resp_headers

    topic_resp = Enum.find(resp_content.responses, fn r -> r.topic == topic_name end)

    partition_resp =
      Enum.find(topic_resp.partitions, fn r -> r.partition_index == partition_index end)

    assert partition_resp.error_code == 0

    assert [
             %{
               attributes: _,
               base_offset: ^offset_1,
               base_sequence: _,
               base_timestamp: _,
               batch_length: _,
               crc: _,
               last_offset_delta: 2,
               magic: 2,
               max_timestamp: _,
               partition_leader_epoch: _,
               producer_epoch: _,
               producer_id: _,
               records: records_1
             },
             %{
               attributes: _,
               base_offset: ^offset_2,
               base_sequence: _,
               base_timestamp: _,
               batch_length: _,
               crc: _,
               last_offset_delta: 2,
               magic: 2,
               max_timestamp: _,
               partition_leader_epoch: _,
               producer_epoch: _,
               producer_id: _,
               records: records_2
             },
             %{
               attributes: _,
               base_offset: ^offset_3,
               base_sequence: _,
               base_timestamp: _,
               batch_length: _,
               crc: _,
               last_offset_delta: 2,
               magic: 2,
               max_timestamp: _,
               partition_leader_epoch: _,
               producer_epoch: _,
               producer_id: _,
               records: records_3
             }
           ] = partition_resp.records

    assert [
             %{
               attributes: _,
               headers: [],
               key: nil,
               offset_delta: 0,
               timestamp_delta: 0,
               value: "msg_1"
             },
             %{
               attributes: _,
               headers: [],
               key: nil,
               offset_delta: 1,
               timestamp_delta: 1,
               value: "msg_2"
             },
             %{
               attributes: _,
               headers: [],
               key: nil,
               offset_delta: 2,
               timestamp_delta: 2,
               value: "msg_3"
             }
           ] = records_1

    assert [
             %{
               attributes: _,
               headers: [],
               key: nil,
               offset_delta: 0,
               timestamp_delta: 0,
               value: "msg_4"
             },
             %{
               attributes: _,
               headers: [],
               key: nil,
               offset_delta: 1,
               timestamp_delta: 1,
               value: "msg_5"
             },
             %{
               attributes: _,
               headers: [],
               key: nil,
               offset_delta: 2,
               timestamp_delta: 2,
               value: "msg_6"
             }
           ] = records_2

    assert [
             %{
               attributes: _,
               headers: [],
               key: nil,
               offset_delta: 0,
               timestamp_delta: 0,
               value: "msg_7"
             },
             %{
               attributes: _,
               headers: [],
               key: nil,
               offset_delta: 1,
               timestamp_delta: 1,
               value: "msg_8"
             },
             %{
               attributes: _,
               headers: [],
               key: nil,
               offset_delta: 2,
               timestamp_delta: 2,
               value: "msg_9"
             }
           ] = records_3
  end

  @tag "#{Fetch.api_key()}": 5
  test "request and response v5", _ctx do
    version = 5
    topic_name = "test_topic_default"
    message_data_1 = ["msg_1", "msg_2", "msg_3"]
    message_data_2 = ["msg_4", "msg_5", "msg_6"]
    message_data_3 = ["msg_7", "msg_8", "msg_9"]

    {:ok, _topic_id} = Helpers.get_or_create_topic(topic_name)

    {:ok,
     %{
       broker: broker,
       partition_index: partition_index,
       offset: offset_1
     }} = Helpers.produce_message(topic_name, message_data_1)

    {:ok,
     %{
       broker: ^broker,
       partition_index: ^partition_index,
       offset: offset_2
     }} = Helpers.produce_message(topic_name, message_data_2)

    {:ok,
     %{
       broker: ^broker,
       partition_index: ^partition_index,
       offset: offset_3
     }} = Helpers.produce_message(topic_name, message_data_3)

    headers = %{correlation_id: correlation_id} = Helpers.generate_headers()

    content = %{
      replica_id: -1,
      max_wait_ms: 1000,
      min_bytes: 1,
      max_bytes: 100_000,
      isolation_level: 0,
      topics: [
        %{
          topic: topic_name,
          partitions: [
            %{
              partition: partition_index,
              fetch_offset: offset_1,
              log_start_offset: 0,
              partition_max_bytes: 100_000
            }
          ]
        }
      ]
    }

    {:ok, %{headers: resp_headers, content: resp_content}} =
      %{headers: headers, content: content}
      |> Fetch.serialize_request(version)
      |> Helpers.send_message_to_broker(broker)
      |> Fetch.deserialize_response(version)

    assert %{correlation_id: ^correlation_id} = resp_headers

    topic_resp = Enum.find(resp_content.responses, fn r -> r.topic == topic_name end)

    partition_resp =
      Enum.find(topic_resp.partitions, fn r -> r.partition_index == partition_index end)

    assert partition_resp.error_code == 0

    assert [
             %{
               attributes: _,
               base_offset: ^offset_1,
               base_sequence: _,
               base_timestamp: _,
               batch_length: _,
               crc: _,
               last_offset_delta: 2,
               magic: 2,
               max_timestamp: _,
               partition_leader_epoch: _,
               producer_epoch: _,
               producer_id: _,
               records: records_1
             },
             %{
               attributes: _,
               base_offset: ^offset_2,
               base_sequence: _,
               base_timestamp: _,
               batch_length: _,
               crc: _,
               last_offset_delta: 2,
               magic: 2,
               max_timestamp: _,
               partition_leader_epoch: _,
               producer_epoch: _,
               producer_id: _,
               records: records_2
             },
             %{
               attributes: _,
               base_offset: ^offset_3,
               base_sequence: _,
               base_timestamp: _,
               batch_length: _,
               crc: _,
               last_offset_delta: 2,
               magic: 2,
               max_timestamp: _,
               partition_leader_epoch: _,
               producer_epoch: _,
               producer_id: _,
               records: records_3
             }
           ] = partition_resp.records

    assert [
             %{
               attributes: _,
               headers: [],
               key: nil,
               offset_delta: 0,
               timestamp_delta: 0,
               value: "msg_1"
             },
             %{
               attributes: _,
               headers: [],
               key: nil,
               offset_delta: 1,
               timestamp_delta: 1,
               value: "msg_2"
             },
             %{
               attributes: _,
               headers: [],
               key: nil,
               offset_delta: 2,
               timestamp_delta: 2,
               value: "msg_3"
             }
           ] = records_1

    assert [
             %{
               attributes: _,
               headers: [],
               key: nil,
               offset_delta: 0,
               timestamp_delta: 0,
               value: "msg_4"
             },
             %{
               attributes: _,
               headers: [],
               key: nil,
               offset_delta: 1,
               timestamp_delta: 1,
               value: "msg_5"
             },
             %{
               attributes: _,
               headers: [],
               key: nil,
               offset_delta: 2,
               timestamp_delta: 2,
               value: "msg_6"
             }
           ] = records_2

    assert [
             %{
               attributes: _,
               headers: [],
               key: nil,
               offset_delta: 0,
               timestamp_delta: 0,
               value: "msg_7"
             },
             %{
               attributes: _,
               headers: [],
               key: nil,
               offset_delta: 1,
               timestamp_delta: 1,
               value: "msg_8"
             },
             %{
               attributes: _,
               headers: [],
               key: nil,
               offset_delta: 2,
               timestamp_delta: 2,
               value: "msg_9"
             }
           ] = records_3
  end

  @tag "#{Fetch.api_key()}": 6
  test "request and response v6", _ctx do
    version = 6
    topic_name = "test_topic_default"
    message_data_1 = ["msg_1", "msg_2", "msg_3"]
    message_data_2 = ["msg_4", "msg_5", "msg_6"]
    message_data_3 = ["msg_7", "msg_8", "msg_9"]

    {:ok, _topic_id} = Helpers.get_or_create_topic(topic_name)

    {:ok,
     %{
       broker: broker,
       partition_index: partition_index,
       offset: offset_1
     }} = Helpers.produce_message(topic_name, message_data_1)

    {:ok,
     %{
       broker: ^broker,
       partition_index: ^partition_index,
       offset: offset_2
     }} = Helpers.produce_message(topic_name, message_data_2)

    {:ok,
     %{
       broker: ^broker,
       partition_index: ^partition_index,
       offset: offset_3
     }} = Helpers.produce_message(topic_name, message_data_3)

    headers = %{correlation_id: correlation_id} = Helpers.generate_headers()

    content = %{
      replica_id: -1,
      max_wait_ms: 1000,
      min_bytes: 1,
      max_bytes: 100_000,
      isolation_level: 0,
      topics: [
        %{
          topic: topic_name,
          partitions: [
            %{
              partition: partition_index,
              fetch_offset: offset_1,
              log_start_offset: 0,
              partition_max_bytes: 100_000
            }
          ]
        }
      ]
    }

    {:ok, %{headers: resp_headers, content: resp_content}} =
      %{headers: headers, content: content}
      |> Fetch.serialize_request(version)
      |> Helpers.send_message_to_broker(broker)
      |> Fetch.deserialize_response(version)

    assert %{correlation_id: ^correlation_id} = resp_headers

    topic_resp = Enum.find(resp_content.responses, fn r -> r.topic == topic_name end)

    partition_resp =
      Enum.find(topic_resp.partitions, fn r -> r.partition_index == partition_index end)

    assert partition_resp.error_code == 0

    assert [
             %{
               attributes: _,
               base_offset: ^offset_1,
               base_sequence: _,
               base_timestamp: _,
               batch_length: _,
               crc: _,
               last_offset_delta: 2,
               magic: 2,
               max_timestamp: _,
               partition_leader_epoch: _,
               producer_epoch: _,
               producer_id: _,
               records: records_1
             },
             %{
               attributes: _,
               base_offset: ^offset_2,
               base_sequence: _,
               base_timestamp: _,
               batch_length: _,
               crc: _,
               last_offset_delta: 2,
               magic: 2,
               max_timestamp: _,
               partition_leader_epoch: _,
               producer_epoch: _,
               producer_id: _,
               records: records_2
             },
             %{
               attributes: _,
               base_offset: ^offset_3,
               base_sequence: _,
               base_timestamp: _,
               batch_length: _,
               crc: _,
               last_offset_delta: 2,
               magic: 2,
               max_timestamp: _,
               partition_leader_epoch: _,
               producer_epoch: _,
               producer_id: _,
               records: records_3
             }
           ] = partition_resp.records

    assert [
             %{
               attributes: _,
               headers: [],
               key: nil,
               offset_delta: 0,
               timestamp_delta: 0,
               value: "msg_1"
             },
             %{
               attributes: _,
               headers: [],
               key: nil,
               offset_delta: 1,
               timestamp_delta: 1,
               value: "msg_2"
             },
             %{
               attributes: _,
               headers: [],
               key: nil,
               offset_delta: 2,
               timestamp_delta: 2,
               value: "msg_3"
             }
           ] = records_1

    assert [
             %{
               attributes: _,
               headers: [],
               key: nil,
               offset_delta: 0,
               timestamp_delta: 0,
               value: "msg_4"
             },
             %{
               attributes: _,
               headers: [],
               key: nil,
               offset_delta: 1,
               timestamp_delta: 1,
               value: "msg_5"
             },
             %{
               attributes: _,
               headers: [],
               key: nil,
               offset_delta: 2,
               timestamp_delta: 2,
               value: "msg_6"
             }
           ] = records_2

    assert [
             %{
               attributes: _,
               headers: [],
               key: nil,
               offset_delta: 0,
               timestamp_delta: 0,
               value: "msg_7"
             },
             %{
               attributes: _,
               headers: [],
               key: nil,
               offset_delta: 1,
               timestamp_delta: 1,
               value: "msg_8"
             },
             %{
               attributes: _,
               headers: [],
               key: nil,
               offset_delta: 2,
               timestamp_delta: 2,
               value: "msg_9"
             }
           ] = records_3
  end

  @tag "#{Fetch.api_key()}": 7
  test "request and response v7", _ctx do
    version = 7
    topic_name = "test_topic_default"
    message_data_1 = ["msg_1", "msg_2", "msg_3"]
    message_data_2 = ["msg_4", "msg_5", "msg_6"]
    message_data_3 = ["msg_7", "msg_8", "msg_9"]

    {:ok, _topic_id} = Helpers.get_or_create_topic(topic_name)

    {:ok,
     %{
       broker: broker,
       partition_index: partition_index,
       offset: offset_1
     }} = Helpers.produce_message(topic_name, message_data_1)

    {:ok,
     %{
       broker: ^broker,
       partition_index: ^partition_index,
       offset: offset_2
     }} = Helpers.produce_message(topic_name, message_data_2)

    {:ok,
     %{
       broker: ^broker,
       partition_index: ^partition_index,
       offset: offset_3
     }} = Helpers.produce_message(topic_name, message_data_3)

    headers = %{correlation_id: correlation_id} = Helpers.generate_headers()

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
              fetch_offset: offset_1,
              log_start_offset: 0,
              partition_max_bytes: 100_000
            }
          ]
        }
      ],
      forgotten_topics_data: []
    }

    {:ok, %{headers: resp_headers, content: resp_content}} =
      %{headers: headers, content: content}
      |> Fetch.serialize_request(version)
      |> Helpers.send_message_to_broker(broker)
      |> Fetch.deserialize_response(version)

    assert %{correlation_id: ^correlation_id} = resp_headers
    assert resp_content.error_code == 0

    topic_resp = Enum.find(resp_content.responses, fn r -> r.topic == topic_name end)

    partition_resp =
      Enum.find(topic_resp.partitions, fn r -> r.partition_index == partition_index end)

    assert partition_resp.error_code == 0

    assert [
             %{
               attributes: _,
               base_offset: ^offset_1,
               base_sequence: _,
               base_timestamp: _,
               batch_length: _,
               crc: _,
               last_offset_delta: 2,
               magic: 2,
               max_timestamp: _,
               partition_leader_epoch: _,
               producer_epoch: _,
               producer_id: _,
               records: records_1
             },
             %{
               attributes: _,
               base_offset: ^offset_2,
               base_sequence: _,
               base_timestamp: _,
               batch_length: _,
               crc: _,
               last_offset_delta: 2,
               magic: 2,
               max_timestamp: _,
               partition_leader_epoch: _,
               producer_epoch: _,
               producer_id: _,
               records: records_2
             },
             %{
               attributes: _,
               base_offset: ^offset_3,
               base_sequence: _,
               base_timestamp: _,
               batch_length: _,
               crc: _,
               last_offset_delta: 2,
               magic: 2,
               max_timestamp: _,
               partition_leader_epoch: _,
               producer_epoch: _,
               producer_id: _,
               records: records_3
             }
           ] = partition_resp.records

    assert [
             %{
               attributes: _,
               headers: [],
               key: nil,
               offset_delta: 0,
               timestamp_delta: 0,
               value: "msg_1"
             },
             %{
               attributes: _,
               headers: [],
               key: nil,
               offset_delta: 1,
               timestamp_delta: 1,
               value: "msg_2"
             },
             %{
               attributes: _,
               headers: [],
               key: nil,
               offset_delta: 2,
               timestamp_delta: 2,
               value: "msg_3"
             }
           ] = records_1

    assert [
             %{
               attributes: _,
               headers: [],
               key: nil,
               offset_delta: 0,
               timestamp_delta: 0,
               value: "msg_4"
             },
             %{
               attributes: _,
               headers: [],
               key: nil,
               offset_delta: 1,
               timestamp_delta: 1,
               value: "msg_5"
             },
             %{
               attributes: _,
               headers: [],
               key: nil,
               offset_delta: 2,
               timestamp_delta: 2,
               value: "msg_6"
             }
           ] = records_2

    assert [
             %{
               attributes: _,
               headers: [],
               key: nil,
               offset_delta: 0,
               timestamp_delta: 0,
               value: "msg_7"
             },
             %{
               attributes: _,
               headers: [],
               key: nil,
               offset_delta: 1,
               timestamp_delta: 1,
               value: "msg_8"
             },
             %{
               attributes: _,
               headers: [],
               key: nil,
               offset_delta: 2,
               timestamp_delta: 2,
               value: "msg_9"
             }
           ] = records_3
  end

  @tag "#{Fetch.api_key()}": 8
  test "request and response v8", _ctx do
    version = 8
    topic_name = "test_topic_default"
    message_data_1 = ["msg_1", "msg_2", "msg_3"]
    message_data_2 = ["msg_4", "msg_5", "msg_6"]
    message_data_3 = ["msg_7", "msg_8", "msg_9"]

    {:ok, _topic_id} = Helpers.get_or_create_topic(topic_name)

    {:ok,
     %{
       broker: broker,
       partition_index: partition_index,
       offset: offset_1
     }} = Helpers.produce_message(topic_name, message_data_1)

    {:ok,
     %{
       broker: ^broker,
       partition_index: ^partition_index,
       offset: offset_2
     }} = Helpers.produce_message(topic_name, message_data_2)

    {:ok,
     %{
       broker: ^broker,
       partition_index: ^partition_index,
       offset: offset_3
     }} = Helpers.produce_message(topic_name, message_data_3)

    headers = %{correlation_id: correlation_id} = Helpers.generate_headers()

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
              fetch_offset: offset_1,
              log_start_offset: 0,
              partition_max_bytes: 100_000
            }
          ]
        }
      ],
      forgotten_topics_data: []
    }

    {:ok, %{headers: resp_headers, content: resp_content}} =
      %{headers: headers, content: content}
      |> Fetch.serialize_request(version)
      |> Helpers.send_message_to_broker(broker)
      |> Fetch.deserialize_response(version)

    assert %{correlation_id: ^correlation_id} = resp_headers
    assert resp_content.error_code == 0

    topic_resp = Enum.find(resp_content.responses, fn r -> r.topic == topic_name end)

    partition_resp =
      Enum.find(topic_resp.partitions, fn r -> r.partition_index == partition_index end)

    assert partition_resp.error_code == 0

    assert [
             %{
               attributes: _,
               base_offset: ^offset_1,
               base_sequence: _,
               base_timestamp: _,
               batch_length: _,
               crc: _,
               last_offset_delta: 2,
               magic: 2,
               max_timestamp: _,
               partition_leader_epoch: _,
               producer_epoch: _,
               producer_id: _,
               records: records_1
             },
             %{
               attributes: _,
               base_offset: ^offset_2,
               base_sequence: _,
               base_timestamp: _,
               batch_length: _,
               crc: _,
               last_offset_delta: 2,
               magic: 2,
               max_timestamp: _,
               partition_leader_epoch: _,
               producer_epoch: _,
               producer_id: _,
               records: records_2
             },
             %{
               attributes: _,
               base_offset: ^offset_3,
               base_sequence: _,
               base_timestamp: _,
               batch_length: _,
               crc: _,
               last_offset_delta: 2,
               magic: 2,
               max_timestamp: _,
               partition_leader_epoch: _,
               producer_epoch: _,
               producer_id: _,
               records: records_3
             }
           ] = partition_resp.records

    assert [
             %{
               attributes: _,
               headers: [],
               key: nil,
               offset_delta: 0,
               timestamp_delta: 0,
               value: "msg_1"
             },
             %{
               attributes: _,
               headers: [],
               key: nil,
               offset_delta: 1,
               timestamp_delta: 1,
               value: "msg_2"
             },
             %{
               attributes: _,
               headers: [],
               key: nil,
               offset_delta: 2,
               timestamp_delta: 2,
               value: "msg_3"
             }
           ] = records_1

    assert [
             %{
               attributes: _,
               headers: [],
               key: nil,
               offset_delta: 0,
               timestamp_delta: 0,
               value: "msg_4"
             },
             %{
               attributes: _,
               headers: [],
               key: nil,
               offset_delta: 1,
               timestamp_delta: 1,
               value: "msg_5"
             },
             %{
               attributes: _,
               headers: [],
               key: nil,
               offset_delta: 2,
               timestamp_delta: 2,
               value: "msg_6"
             }
           ] = records_2

    assert [
             %{
               attributes: _,
               headers: [],
               key: nil,
               offset_delta: 0,
               timestamp_delta: 0,
               value: "msg_7"
             },
             %{
               attributes: _,
               headers: [],
               key: nil,
               offset_delta: 1,
               timestamp_delta: 1,
               value: "msg_8"
             },
             %{
               attributes: _,
               headers: [],
               key: nil,
               offset_delta: 2,
               timestamp_delta: 2,
               value: "msg_9"
             }
           ] = records_3
  end

  @tag "#{Fetch.api_key()}": 9
  test "request and response v9", _ctx do
    version = 9
    topic_name = "test_topic_default"
    message_data_1 = ["msg_1", "msg_2", "msg_3"]
    message_data_2 = ["msg_4", "msg_5", "msg_6"]
    message_data_3 = ["msg_7", "msg_8", "msg_9"]

    {:ok, _topic_id} = Helpers.get_or_create_topic(topic_name)

    {:ok,
     %{
       broker: broker,
       partition_index: partition_index,
       offset: offset_1
     }} = Helpers.produce_message(topic_name, message_data_1)

    {:ok,
     %{
       broker: ^broker,
       partition_index: ^partition_index,
       offset: offset_2
     }} = Helpers.produce_message(topic_name, message_data_2)

    {:ok,
     %{
       broker: ^broker,
       partition_index: ^partition_index,
       offset: offset_3
     }} = Helpers.produce_message(topic_name, message_data_3)

    headers = %{correlation_id: correlation_id} = Helpers.generate_headers()

    %{leader_epoch: leader_epoch} =
      Helpers.get_metadata_for_topic_and_partition(topic_name, partition_index)

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
              current_leader_epoch: leader_epoch,
              fetch_offset: offset_1,
              log_start_offset: 0,
              partition_max_bytes: 100_000
            }
          ]
        }
      ],
      forgotten_topics_data: []
    }

    {:ok, %{headers: resp_headers, content: resp_content}} =
      %{headers: headers, content: content}
      |> Fetch.serialize_request(version)
      |> Helpers.send_message_to_broker(broker)
      |> Fetch.deserialize_response(version)

    assert %{correlation_id: ^correlation_id} = resp_headers
    assert resp_content.error_code == 0

    topic_resp = Enum.find(resp_content.responses, fn r -> r.topic == topic_name end)

    partition_resp =
      Enum.find(topic_resp.partitions, fn r -> r.partition_index == partition_index end)

    assert partition_resp.error_code == 0

    assert [
             %{
               attributes: _,
               base_offset: ^offset_1,
               base_sequence: _,
               base_timestamp: _,
               batch_length: _,
               crc: _,
               last_offset_delta: 2,
               magic: 2,
               max_timestamp: _,
               partition_leader_epoch: _,
               producer_epoch: _,
               producer_id: _,
               records: records_1
             },
             %{
               attributes: _,
               base_offset: ^offset_2,
               base_sequence: _,
               base_timestamp: _,
               batch_length: _,
               crc: _,
               last_offset_delta: 2,
               magic: 2,
               max_timestamp: _,
               partition_leader_epoch: _,
               producer_epoch: _,
               producer_id: _,
               records: records_2
             },
             %{
               attributes: _,
               base_offset: ^offset_3,
               base_sequence: _,
               base_timestamp: _,
               batch_length: _,
               crc: _,
               last_offset_delta: 2,
               magic: 2,
               max_timestamp: _,
               partition_leader_epoch: _,
               producer_epoch: _,
               producer_id: _,
               records: records_3
             }
           ] = partition_resp.records

    assert [
             %{
               attributes: _,
               headers: [],
               key: nil,
               offset_delta: 0,
               timestamp_delta: 0,
               value: "msg_1"
             },
             %{
               attributes: _,
               headers: [],
               key: nil,
               offset_delta: 1,
               timestamp_delta: 1,
               value: "msg_2"
             },
             %{
               attributes: _,
               headers: [],
               key: nil,
               offset_delta: 2,
               timestamp_delta: 2,
               value: "msg_3"
             }
           ] = records_1

    assert [
             %{
               attributes: _,
               headers: [],
               key: nil,
               offset_delta: 0,
               timestamp_delta: 0,
               value: "msg_4"
             },
             %{
               attributes: _,
               headers: [],
               key: nil,
               offset_delta: 1,
               timestamp_delta: 1,
               value: "msg_5"
             },
             %{
               attributes: _,
               headers: [],
               key: nil,
               offset_delta: 2,
               timestamp_delta: 2,
               value: "msg_6"
             }
           ] = records_2

    assert [
             %{
               attributes: _,
               headers: [],
               key: nil,
               offset_delta: 0,
               timestamp_delta: 0,
               value: "msg_7"
             },
             %{
               attributes: _,
               headers: [],
               key: nil,
               offset_delta: 1,
               timestamp_delta: 1,
               value: "msg_8"
             },
             %{
               attributes: _,
               headers: [],
               key: nil,
               offset_delta: 2,
               timestamp_delta: 2,
               value: "msg_9"
             }
           ] = records_3
  end

  @tag "#{Fetch.api_key()}": 10
  test "request and response v10", _ctx do
    version = 10
    topic_name = "test_topic_default"
    message_data_1 = ["msg_1", "msg_2", "msg_3"]
    message_data_2 = ["msg_4", "msg_5", "msg_6"]
    message_data_3 = ["msg_7", "msg_8", "msg_9"]

    {:ok, _topic_id} = Helpers.get_or_create_topic(topic_name)

    {:ok,
     %{
       broker: broker,
       partition_index: partition_index,
       offset: offset_1
     }} = Helpers.produce_message(topic_name, message_data_1)

    {:ok,
     %{
       broker: ^broker,
       partition_index: ^partition_index,
       offset: offset_2
     }} = Helpers.produce_message(topic_name, message_data_2)

    {:ok,
     %{
       broker: ^broker,
       partition_index: ^partition_index,
       offset: offset_3
     }} = Helpers.produce_message(topic_name, message_data_3)

    headers = %{correlation_id: correlation_id} = Helpers.generate_headers()

    %{leader_epoch: leader_epoch} =
      Helpers.get_metadata_for_topic_and_partition(topic_name, partition_index)

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
              current_leader_epoch: leader_epoch,
              fetch_offset: offset_1,
              log_start_offset: 0,
              partition_max_bytes: 100_000
            }
          ]
        }
      ],
      forgotten_topics_data: []
    }

    {:ok, %{headers: resp_headers, content: resp_content}} =
      %{headers: headers, content: content}
      |> Fetch.serialize_request(version)
      |> Helpers.send_message_to_broker(broker)
      |> Fetch.deserialize_response(version)

    assert %{correlation_id: ^correlation_id} = resp_headers
    assert resp_content.error_code == 0

    topic_resp = Enum.find(resp_content.responses, fn r -> r.topic == topic_name end)

    partition_resp =
      Enum.find(topic_resp.partitions, fn r -> r.partition_index == partition_index end)

    assert partition_resp.error_code == 0

    assert [
             %{
               attributes: _,
               base_offset: ^offset_1,
               base_sequence: _,
               base_timestamp: _,
               batch_length: _,
               crc: _,
               last_offset_delta: 2,
               magic: 2,
               max_timestamp: _,
               partition_leader_epoch: _,
               producer_epoch: _,
               producer_id: _,
               records: records_1
             },
             %{
               attributes: _,
               base_offset: ^offset_2,
               base_sequence: _,
               base_timestamp: _,
               batch_length: _,
               crc: _,
               last_offset_delta: 2,
               magic: 2,
               max_timestamp: _,
               partition_leader_epoch: _,
               producer_epoch: _,
               producer_id: _,
               records: records_2
             },
             %{
               attributes: _,
               base_offset: ^offset_3,
               base_sequence: _,
               base_timestamp: _,
               batch_length: _,
               crc: _,
               last_offset_delta: 2,
               magic: 2,
               max_timestamp: _,
               partition_leader_epoch: _,
               producer_epoch: _,
               producer_id: _,
               records: records_3
             }
           ] = partition_resp.records

    assert [
             %{
               attributes: _,
               headers: [],
               key: nil,
               offset_delta: 0,
               timestamp_delta: 0,
               value: "msg_1"
             },
             %{
               attributes: _,
               headers: [],
               key: nil,
               offset_delta: 1,
               timestamp_delta: 1,
               value: "msg_2"
             },
             %{
               attributes: _,
               headers: [],
               key: nil,
               offset_delta: 2,
               timestamp_delta: 2,
               value: "msg_3"
             }
           ] = records_1

    assert [
             %{
               attributes: _,
               headers: [],
               key: nil,
               offset_delta: 0,
               timestamp_delta: 0,
               value: "msg_4"
             },
             %{
               attributes: _,
               headers: [],
               key: nil,
               offset_delta: 1,
               timestamp_delta: 1,
               value: "msg_5"
             },
             %{
               attributes: _,
               headers: [],
               key: nil,
               offset_delta: 2,
               timestamp_delta: 2,
               value: "msg_6"
             }
           ] = records_2

    assert [
             %{
               attributes: _,
               headers: [],
               key: nil,
               offset_delta: 0,
               timestamp_delta: 0,
               value: "msg_7"
             },
             %{
               attributes: _,
               headers: [],
               key: nil,
               offset_delta: 1,
               timestamp_delta: 1,
               value: "msg_8"
             },
             %{
               attributes: _,
               headers: [],
               key: nil,
               offset_delta: 2,
               timestamp_delta: 2,
               value: "msg_9"
             }
           ] = records_3
  end

  @tag "#{Fetch.api_key()}": 11
  test "request and response v11", _ctx do
    version = 11
    topic_name = "test_topic_default"
    message_data_1 = ["msg_1", "msg_2", "msg_3"]
    message_data_2 = ["msg_4", "msg_5", "msg_6"]
    message_data_3 = ["msg_7", "msg_8", "msg_9"]

    {:ok, _topic_id} = Helpers.get_or_create_topic(topic_name)

    {:ok,
     %{
       broker: broker,
       partition_index: partition_index,
       offset: offset_1
     }} = Helpers.produce_message(topic_name, message_data_1)

    {:ok,
     %{
       broker: ^broker,
       partition_index: ^partition_index,
       offset: offset_2
     }} = Helpers.produce_message(topic_name, message_data_2)

    {:ok,
     %{
       broker: ^broker,
       partition_index: ^partition_index,
       offset: offset_3
     }} = Helpers.produce_message(topic_name, message_data_3)

    headers = %{correlation_id: correlation_id} = Helpers.generate_headers()

    %{leader_epoch: leader_epoch} =
      Helpers.get_metadata_for_topic_and_partition(topic_name, partition_index)

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
              current_leader_epoch: leader_epoch,
              fetch_offset: offset_1,
              log_start_offset: 0,
              partition_max_bytes: 100_000
            }
          ]
        }
      ],
      forgotten_topics_data: [],
      rack_id: "rack"
    }

    {:ok, %{headers: resp_headers, content: resp_content}} =
      %{headers: headers, content: content}
      |> Fetch.serialize_request(version)
      |> Helpers.send_message_to_broker(broker)
      |> Fetch.deserialize_response(version)

    assert %{correlation_id: ^correlation_id} = resp_headers
    assert resp_content.error_code == 0

    topic_resp = Enum.find(resp_content.responses, fn r -> r.topic == topic_name end)

    partition_resp =
      Enum.find(topic_resp.partitions, fn r -> r.partition_index == partition_index end)

    assert partition_resp.error_code == 0

    assert [
             %{
               attributes: _,
               base_offset: ^offset_1,
               base_sequence: _,
               base_timestamp: _,
               batch_length: _,
               crc: _,
               last_offset_delta: 2,
               magic: 2,
               max_timestamp: _,
               partition_leader_epoch: _,
               producer_epoch: _,
               producer_id: _,
               records: records_1
             },
             %{
               attributes: _,
               base_offset: ^offset_2,
               base_sequence: _,
               base_timestamp: _,
               batch_length: _,
               crc: _,
               last_offset_delta: 2,
               magic: 2,
               max_timestamp: _,
               partition_leader_epoch: _,
               producer_epoch: _,
               producer_id: _,
               records: records_2
             },
             %{
               attributes: _,
               base_offset: ^offset_3,
               base_sequence: _,
               base_timestamp: _,
               batch_length: _,
               crc: _,
               last_offset_delta: 2,
               magic: 2,
               max_timestamp: _,
               partition_leader_epoch: _,
               producer_epoch: _,
               producer_id: _,
               records: records_3
             }
           ] = partition_resp.records

    assert [
             %{
               attributes: _,
               headers: [],
               key: nil,
               offset_delta: 0,
               timestamp_delta: 0,
               value: "msg_1"
             },
             %{
               attributes: _,
               headers: [],
               key: nil,
               offset_delta: 1,
               timestamp_delta: 1,
               value: "msg_2"
             },
             %{
               attributes: _,
               headers: [],
               key: nil,
               offset_delta: 2,
               timestamp_delta: 2,
               value: "msg_3"
             }
           ] = records_1

    assert [
             %{
               attributes: _,
               headers: [],
               key: nil,
               offset_delta: 0,
               timestamp_delta: 0,
               value: "msg_4"
             },
             %{
               attributes: _,
               headers: [],
               key: nil,
               offset_delta: 1,
               timestamp_delta: 1,
               value: "msg_5"
             },
             %{
               attributes: _,
               headers: [],
               key: nil,
               offset_delta: 2,
               timestamp_delta: 2,
               value: "msg_6"
             }
           ] = records_2

    assert [
             %{
               attributes: _,
               headers: [],
               key: nil,
               offset_delta: 0,
               timestamp_delta: 0,
               value: "msg_7"
             },
             %{
               attributes: _,
               headers: [],
               key: nil,
               offset_delta: 1,
               timestamp_delta: 1,
               value: "msg_8"
             },
             %{
               attributes: _,
               headers: [],
               key: nil,
               offset_delta: 2,
               timestamp_delta: 2,
               value: "msg_9"
             }
           ] = records_3
  end

  @tag "#{Fetch.api_key()}": 12
  test "request and response v12", _ctx do
    version = 12
    topic_name = "test_topic_default"
    message_data_1 = ["msg_1", "msg_2", "msg_3"]
    message_data_2 = ["msg_4", "msg_5", "msg_6"]
    message_data_3 = ["msg_7", "msg_8", "msg_9"]

    {:ok, _topic_id} = Helpers.get_or_create_topic(topic_name)

    {:ok,
     %{
       broker: broker,
       partition_index: partition_index,
       offset: offset_1
     }} = Helpers.produce_message(topic_name, message_data_1)

    {:ok,
     %{
       broker: ^broker,
       partition_index: ^partition_index,
       offset: offset_2
     }} = Helpers.produce_message(topic_name, message_data_2)

    {:ok,
     %{
       broker: ^broker,
       partition_index: ^partition_index,
       offset: offset_3
     }} = Helpers.produce_message(topic_name, message_data_3)

    headers = %{correlation_id: correlation_id} = Helpers.generate_headers()

    %{leader_epoch: leader_epoch} =
      Helpers.get_metadata_for_topic_and_partition(topic_name, partition_index)

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
              current_leader_epoch: leader_epoch,
              fetch_offset: offset_1,
              last_fetched_epoch: 0,
              log_start_offset: 0,
              partition_max_bytes: 100_000
            }
          ]
        }
      ],
      forgotten_topics_data: [],
      rack_id: "rack"
    }

    {:ok, %{headers: resp_headers, content: resp_content}} =
      %{headers: headers, content: content}
      |> Fetch.serialize_request(version)
      |> Helpers.send_message_to_broker(broker)
      |> Fetch.deserialize_response(version)

    assert %{correlation_id: ^correlation_id} = resp_headers
    assert resp_content.error_code == 0

    topic_resp = Enum.find(resp_content.responses, fn r -> r.topic == topic_name end)

    partition_resp =
      Enum.find(topic_resp.partitions, fn r -> r.partition_index == partition_index end)

    assert partition_resp.error_code == 0

    assert [
             %{
               attributes: _,
               base_offset: ^offset_1,
               base_sequence: _,
               base_timestamp: _,
               batch_length: _,
               crc: _,
               last_offset_delta: 2,
               magic: 2,
               max_timestamp: _,
               partition_leader_epoch: _,
               producer_epoch: _,
               producer_id: _,
               records: records_1
             },
             %{
               attributes: _,
               base_offset: ^offset_2,
               base_sequence: _,
               base_timestamp: _,
               batch_length: _,
               crc: _,
               last_offset_delta: 2,
               magic: 2,
               max_timestamp: _,
               partition_leader_epoch: _,
               producer_epoch: _,
               producer_id: _,
               records: records_2
             },
             %{
               attributes: _,
               base_offset: ^offset_3,
               base_sequence: _,
               base_timestamp: _,
               batch_length: _,
               crc: _,
               last_offset_delta: 2,
               magic: 2,
               max_timestamp: _,
               partition_leader_epoch: _,
               producer_epoch: _,
               producer_id: _,
               records: records_3
             }
           ] = partition_resp.records

    assert [
             %{
               attributes: _,
               headers: [],
               key: nil,
               offset_delta: 0,
               timestamp_delta: 0,
               value: "msg_1"
             },
             %{
               attributes: _,
               headers: [],
               key: nil,
               offset_delta: 1,
               timestamp_delta: 1,
               value: "msg_2"
             },
             %{
               attributes: _,
               headers: [],
               key: nil,
               offset_delta: 2,
               timestamp_delta: 2,
               value: "msg_3"
             }
           ] = records_1

    assert [
             %{
               attributes: _,
               headers: [],
               key: nil,
               offset_delta: 0,
               timestamp_delta: 0,
               value: "msg_4"
             },
             %{
               attributes: _,
               headers: [],
               key: nil,
               offset_delta: 1,
               timestamp_delta: 1,
               value: "msg_5"
             },
             %{
               attributes: _,
               headers: [],
               key: nil,
               offset_delta: 2,
               timestamp_delta: 2,
               value: "msg_6"
             }
           ] = records_2

    assert [
             %{
               attributes: _,
               headers: [],
               key: nil,
               offset_delta: 0,
               timestamp_delta: 0,
               value: "msg_7"
             },
             %{
               attributes: _,
               headers: [],
               key: nil,
               offset_delta: 1,
               timestamp_delta: 1,
               value: "msg_8"
             },
             %{
               attributes: _,
               headers: [],
               key: nil,
               offset_delta: 2,
               timestamp_delta: 2,
               value: "msg_9"
             }
           ] = records_3
  end

  @tag "#{Fetch.api_key()}": 13
  test "request and response v13", _ctx do
    version = 13
    topic_name = "test_topic_default"
    message_data_1 = ["msg_1", "msg_2", "msg_3"]
    message_data_2 = ["msg_4", "msg_5", "msg_6"]
    message_data_3 = ["msg_7", "msg_8", "msg_9"]

    {:ok, topic_id} = Helpers.get_or_create_topic(topic_name)

    {:ok,
     %{
       broker: broker,
       partition_index: partition_index,
       offset: offset_1
     }} = Helpers.produce_message(topic_name, message_data_1)

    {:ok,
     %{
       broker: ^broker,
       partition_index: ^partition_index,
       offset: offset_2
     }} = Helpers.produce_message(topic_name, message_data_2)

    {:ok,
     %{
       broker: ^broker,
       partition_index: ^partition_index,
       offset: offset_3
     }} = Helpers.produce_message(topic_name, message_data_3)

    %{leader_epoch: leader_epoch} =
      Helpers.get_metadata_for_topic_and_partition(topic_name, partition_index)

    headers = %{correlation_id: correlation_id} = Helpers.generate_headers()

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
          topic_id: topic_id,
          partitions: [
            %{
              partition: partition_index,
              current_leader_epoch: leader_epoch,
              fetch_offset: offset_1,
              last_fetched_epoch: 0,
              log_start_offset: 0,
              partition_max_bytes: 100_000
            }
          ]
        }
      ],
      forgotten_topics_data: [],
      rack_id: "rack"
    }

    {:ok, %{headers: resp_headers, content: resp_content}} =
      %{headers: headers, content: content}
      |> Fetch.serialize_request(version)
      |> Helpers.send_message_to_broker(broker)
      |> Fetch.deserialize_response(version)

    assert %{correlation_id: ^correlation_id} = resp_headers
    assert resp_content.error_code == 0

    topic_resp = Enum.find(resp_content.responses, fn r -> r.topic_id == topic_id end)

    partition_resp =
      Enum.find(topic_resp.partitions, fn r -> r.partition_index == partition_index end)

    assert partition_resp.error_code == 0

    assert [
             %{
               attributes: _,
               base_offset: ^offset_1,
               base_sequence: _,
               base_timestamp: _,
               batch_length: _,
               crc: _,
               last_offset_delta: 2,
               magic: 2,
               max_timestamp: _,
               partition_leader_epoch: _,
               producer_epoch: _,
               producer_id: _,
               records: records_1
             },
             %{
               attributes: _,
               base_offset: ^offset_2,
               base_sequence: _,
               base_timestamp: _,
               batch_length: _,
               crc: _,
               last_offset_delta: 2,
               magic: 2,
               max_timestamp: _,
               partition_leader_epoch: _,
               producer_epoch: _,
               producer_id: _,
               records: records_2
             },
             %{
               attributes: _,
               base_offset: ^offset_3,
               base_sequence: _,
               base_timestamp: _,
               batch_length: _,
               crc: _,
               last_offset_delta: 2,
               magic: 2,
               max_timestamp: _,
               partition_leader_epoch: _,
               producer_epoch: _,
               producer_id: _,
               records: records_3
             }
           ] = partition_resp.records

    assert [
             %{
               attributes: _,
               headers: [],
               key: nil,
               offset_delta: 0,
               timestamp_delta: 0,
               value: "msg_1"
             },
             %{
               attributes: _,
               headers: [],
               key: nil,
               offset_delta: 1,
               timestamp_delta: 1,
               value: "msg_2"
             },
             %{
               attributes: _,
               headers: [],
               key: nil,
               offset_delta: 2,
               timestamp_delta: 2,
               value: "msg_3"
             }
           ] = records_1

    assert [
             %{
               attributes: _,
               headers: [],
               key: nil,
               offset_delta: 0,
               timestamp_delta: 0,
               value: "msg_4"
             },
             %{
               attributes: _,
               headers: [],
               key: nil,
               offset_delta: 1,
               timestamp_delta: 1,
               value: "msg_5"
             },
             %{
               attributes: _,
               headers: [],
               key: nil,
               offset_delta: 2,
               timestamp_delta: 2,
               value: "msg_6"
             }
           ] = records_2

    assert [
             %{
               attributes: _,
               headers: [],
               key: nil,
               offset_delta: 0,
               timestamp_delta: 0,
               value: "msg_7"
             },
             %{
               attributes: _,
               headers: [],
               key: nil,
               offset_delta: 1,
               timestamp_delta: 1,
               value: "msg_8"
             },
             %{
               attributes: _,
               headers: [],
               key: nil,
               offset_delta: 2,
               timestamp_delta: 2,
               value: "msg_9"
             }
           ] = records_3
  end

  @tag "#{Fetch.api_key()}": 13
  test "Partial messages", _ctx do
    version = 13
    topic_name = "test_topic_default"
    message_data_1 = ["msg_1", "msg_2", "msg_3"]
    message_data_2 = ["msg_4", "msg_5", "msg_6"]
    message_data_3 = ["msg_7", "msg_8", "msg_9"]

    {:ok, topic_id} = Helpers.get_or_create_topic(topic_name)

    {:ok,
     %{
       broker: broker,
       partition_index: partition_index,
       offset: offset_1
     }} = Helpers.produce_message(topic_name, message_data_1)

    {:ok,
     %{
       broker: ^broker,
       partition_index: ^partition_index,
       offset: offset_2
     }} = Helpers.produce_message(topic_name, message_data_2)

    {:ok,
     %{
       broker: ^broker,
       partition_index: ^partition_index,
       offset: _offset_3
     }} = Helpers.produce_message(topic_name, message_data_3)

    headers = %{correlation_id: correlation_id} = Helpers.generate_headers()

    %{leader_epoch: leader_epoch} =
      Helpers.get_metadata_for_topic_and_partition(topic_name, partition_index)

    content = %{
      replica_id: -1,
      max_wait_ms: 1000,
      min_bytes: 1,
      max_bytes: 200,
      isolation_level: 0,
      session_id: 0,
      session_epoch: 0,
      topics: [
        %{
          topic_id: topic_id,
          partitions: [
            %{
              partition: partition_index,
              current_leader_epoch: leader_epoch,
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

    {:ok, %{headers: resp_headers, content: resp_content}} =
      %{headers: headers, content: content}
      |> Fetch.serialize_request(version)
      |> Helpers.send_message_to_broker(broker)
      |> Fetch.deserialize_response(version)

    assert %{correlation_id: ^correlation_id} = resp_headers
    assert resp_content.error_code == 0

    topic_resp = Enum.find(resp_content.responses, fn r -> r.topic_id == topic_id end)

    partition_resp =
      Enum.find(topic_resp.partitions, fn r -> r.partition_index == partition_index end)

    assert partition_resp.error_code == 0

    assert [
             %{
               attributes: _,
               base_offset: ^offset_1,
               base_sequence: _,
               base_timestamp: _,
               batch_length: _,
               crc: _,
               last_offset_delta: 2,
               magic: 2,
               max_timestamp: _,
               partition_leader_epoch: _,
               producer_epoch: _,
               producer_id: _,
               records: records_1
             },
             %{
               attributes: _,
               base_offset: ^offset_2,
               base_sequence: _,
               base_timestamp: _,
               batch_length: _,
               crc: _,
               last_offset_delta: 2,
               magic: 2,
               max_timestamp: _,
               partition_leader_epoch: _,
               producer_epoch: _,
               producer_id: _,
               records: records_2
             }
           ] = partition_resp.records

    assert [
             %{
               attributes: _,
               headers: [],
               key: nil,
               offset_delta: 0,
               timestamp_delta: 0,
               value: "msg_1"
             },
             %{
               attributes: _,
               headers: [],
               key: nil,
               offset_delta: 1,
               timestamp_delta: 1,
               value: "msg_2"
             },
             %{
               attributes: _,
               headers: [],
               key: nil,
               offset_delta: 2,
               timestamp_delta: 2,
               value: "msg_3"
             }
           ] = records_1

    assert [
             %{
               attributes: _,
               headers: [],
               key: nil,
               offset_delta: 0,
               timestamp_delta: 0,
               value: "msg_4"
             },
             %{
               attributes: _,
               headers: [],
               key: nil,
               offset_delta: 1,
               timestamp_delta: 1,
               value: "msg_5"
             },
             %{
               attributes: _,
               headers: [],
               key: nil,
               offset_delta: 2,
               timestamp_delta: 2,
               value: "msg_6"
             }
           ] = records_2
  end

  @tag "#{Fetch.api_key()}": 13
  test "Partial messages with compression", _ctx do
    version = 13
    topic_name = "test_topic_default"
    message_data_1 = ["msg_1", "msg_2", "msg_3"]
    message_data_2 = ["msg_4", "msg_5", "msg_6"]
    message_data_3 = ["msg_7", "msg_8", "msg_9"]

    attr = RecordBatch.encode_attributes(compression: :snappy)

    {:ok, topic_id} = Helpers.get_or_create_topic(topic_name)

    {:ok,
     %{
       broker: broker,
       partition_index: partition_index,
       offset: offset_1
     }} = Helpers.produce_message(topic_name, message_data_1, attributes: attr)

    {:ok,
     %{
       broker: ^broker,
       partition_index: ^partition_index,
       offset: offset_2
     }} = Helpers.produce_message(topic_name, message_data_2, attributes: attr)

    {:ok,
     %{
       broker: ^broker,
       partition_index: ^partition_index,
       offset: _offset_3
     }} = Helpers.produce_message(topic_name, message_data_3, attributes: attr)

    headers = %{correlation_id: correlation_id} = Helpers.generate_headers()

    %{leader_epoch: leader_epoch} =
      Helpers.get_metadata_for_topic_and_partition(topic_name, partition_index)

    content = %{
      replica_id: -1,
      max_wait_ms: 1000,
      min_bytes: 1,
      max_bytes: 200,
      isolation_level: 0,
      session_id: 0,
      session_epoch: 0,
      topics: [
        %{
          topic_id: topic_id,
          partitions: [
            %{
              partition: partition_index,
              current_leader_epoch: leader_epoch,
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

    {:ok, %{headers: resp_headers, content: resp_content}} =
      %{headers: headers, content: content}
      |> Fetch.serialize_request(version)
      |> Helpers.send_message_to_broker(broker)
      |> Fetch.deserialize_response(version)

    assert %{correlation_id: ^correlation_id} = resp_headers
    assert resp_content.error_code == 0

    topic_resp = Enum.find(resp_content.responses, fn r -> r.topic_id == topic_id end)

    partition_resp =
      Enum.find(topic_resp.partitions, fn r -> r.partition_index == partition_index end)

    assert partition_resp.error_code == 0

    assert [
             %{
               attributes: _,
               base_offset: ^offset_1,
               base_sequence: _,
               base_timestamp: _,
               batch_length: _,
               crc: _,
               last_offset_delta: 2,
               magic: 2,
               max_timestamp: _,
               partition_leader_epoch: _,
               producer_epoch: _,
               producer_id: _,
               records: records_1
             },
             %{
               attributes: _,
               base_offset: ^offset_2,
               base_sequence: _,
               base_timestamp: _,
               batch_length: _,
               crc: _,
               last_offset_delta: 2,
               magic: 2,
               max_timestamp: _,
               partition_leader_epoch: _,
               producer_epoch: _,
               producer_id: _,
               records: records_2
             }
           ] = partition_resp.records

    assert [
             %{
               attributes: _,
               headers: [],
               key: nil,
               offset_delta: 0,
               timestamp_delta: 0,
               value: "msg_1"
             },
             %{
               attributes: _,
               headers: [],
               key: nil,
               offset_delta: 1,
               timestamp_delta: 1,
               value: "msg_2"
             },
             %{
               attributes: _,
               headers: [],
               key: nil,
               offset_delta: 2,
               timestamp_delta: 2,
               value: "msg_3"
             }
           ] = records_1

    assert [
             %{
               attributes: _,
               headers: [],
               key: nil,
               offset_delta: 0,
               timestamp_delta: 0,
               value: "msg_4"
             },
             %{
               attributes: _,
               headers: [],
               key: nil,
               offset_delta: 1,
               timestamp_delta: 1,
               value: "msg_5"
             },
             %{
               attributes: _,
               headers: [],
               key: nil,
               offset_delta: 2,
               timestamp_delta: 2,
               value: "msg_6"
             }
           ] = records_2
  end

  @tag "#{Fetch.api_key()}": 13
  test "request and response v13 with gzip compression", _ctx do
    version = 13
    topic_name = "test_topic_default"
    message_data_1 = ["msg_1", "msg_2", "msg_3"]
    message_data_2 = ["msg_4", "msg_5", "msg_6"]
    message_data_3 = ["msg_7", "msg_8", "msg_9"]
    attr = RecordBatch.encode_attributes(compression: :gzip)

    {:ok, topic_id} = Helpers.get_or_create_topic(topic_name)

    {:ok,
     %{
       broker: broker,
       partition_index: partition_index,
       offset: offset_1
     }} = Helpers.produce_message(topic_name, message_data_1, attributes: attr)

    {:ok,
     %{
       broker: ^broker,
       partition_index: ^partition_index,
       offset: offset_2
     }} = Helpers.produce_message(topic_name, message_data_2, attributes: attr)

    {:ok,
     %{
       broker: ^broker,
       partition_index: ^partition_index,
       offset: offset_3
     }} = Helpers.produce_message(topic_name, message_data_3, attributes: attr)

    %{leader_epoch: leader_epoch} =
      Helpers.get_metadata_for_topic_and_partition(topic_name, partition_index)

    headers = %{correlation_id: correlation_id} = Helpers.generate_headers()

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
          topic_id: topic_id,
          partitions: [
            %{
              partition: partition_index,
              current_leader_epoch: leader_epoch,
              fetch_offset: offset_1,
              last_fetched_epoch: 0,
              log_start_offset: 0,
              partition_max_bytes: 100_000
            }
          ]
        }
      ],
      forgotten_topics_data: [],
      rack_id: "rack"
    }

    {:ok, %{headers: resp_headers, content: resp_content}} =
      %{headers: headers, content: content}
      |> Fetch.serialize_request(version)
      |> Helpers.send_message_to_broker(broker)
      |> Fetch.deserialize_response(version)

    assert %{correlation_id: ^correlation_id} = resp_headers
    assert resp_content.error_code == 0

    topic_resp = Enum.find(resp_content.responses, fn r -> r.topic_id == topic_id end)

    partition_resp =
      Enum.find(topic_resp.partitions, fn r -> r.partition_index == partition_index end)

    assert partition_resp.error_code == 0

    assert [
             %{
               attributes: _,
               base_offset: ^offset_1,
               base_sequence: _,
               base_timestamp: _,
               batch_length: _,
               crc: _,
               last_offset_delta: 2,
               magic: 2,
               max_timestamp: _,
               partition_leader_epoch: _,
               producer_epoch: _,
               producer_id: _,
               records: records_1
             },
             %{
               attributes: _,
               base_offset: ^offset_2,
               base_sequence: _,
               base_timestamp: _,
               batch_length: _,
               crc: _,
               last_offset_delta: 2,
               magic: 2,
               max_timestamp: _,
               partition_leader_epoch: _,
               producer_epoch: _,
               producer_id: _,
               records: records_2
             },
             %{
               attributes: _,
               base_offset: ^offset_3,
               base_sequence: _,
               base_timestamp: _,
               batch_length: _,
               crc: _,
               last_offset_delta: 2,
               magic: 2,
               max_timestamp: _,
               partition_leader_epoch: _,
               producer_epoch: _,
               producer_id: _,
               records: records_3
             }
           ] = partition_resp.records

    assert [
             %{
               attributes: _,
               headers: [],
               key: nil,
               offset_delta: 0,
               timestamp_delta: 0,
               value: "msg_1"
             },
             %{
               attributes: _,
               headers: [],
               key: nil,
               offset_delta: 1,
               timestamp_delta: 1,
               value: "msg_2"
             },
             %{
               attributes: _,
               headers: [],
               key: nil,
               offset_delta: 2,
               timestamp_delta: 2,
               value: "msg_3"
             }
           ] = records_1

    assert [
             %{
               attributes: _,
               headers: [],
               key: nil,
               offset_delta: 0,
               timestamp_delta: 0,
               value: "msg_4"
             },
             %{
               attributes: _,
               headers: [],
               key: nil,
               offset_delta: 1,
               timestamp_delta: 1,
               value: "msg_5"
             },
             %{
               attributes: _,
               headers: [],
               key: nil,
               offset_delta: 2,
               timestamp_delta: 2,
               value: "msg_6"
             }
           ] = records_2

    assert [
             %{
               attributes: _,
               headers: [],
               key: nil,
               offset_delta: 0,
               timestamp_delta: 0,
               value: "msg_7"
             },
             %{
               attributes: _,
               headers: [],
               key: nil,
               offset_delta: 1,
               timestamp_delta: 1,
               value: "msg_8"
             },
             %{
               attributes: _,
               headers: [],
               key: nil,
               offset_delta: 2,
               timestamp_delta: 2,
               value: "msg_9"
             }
           ] = records_3
  end

  @tag "#{Fetch.api_key()}": 13
  test "request and response v13 with snappy compression", _ctx do
    version = 13
    topic_name = "test_topic_default"
    message_data_1 = ["msg_1", "msg_2", "msg_3"]
    message_data_2 = ["msg_4", "msg_5", "msg_6"]
    message_data_3 = ["msg_7", "msg_8", "msg_9"]
    attr = RecordBatch.encode_attributes(compression: :snappy)

    {:ok, topic_id} = Helpers.get_or_create_topic(topic_name)

    {:ok,
     %{
       broker: broker,
       partition_index: partition_index,
       offset: offset_1
     }} = Helpers.produce_message(topic_name, message_data_1, attributes: attr)

    {:ok,
     %{
       broker: ^broker,
       partition_index: ^partition_index,
       offset: offset_2
     }} = Helpers.produce_message(topic_name, message_data_2, attributes: attr)

    {:ok,
     %{
       broker: ^broker,
       partition_index: ^partition_index,
       offset: offset_3
     }} = Helpers.produce_message(topic_name, message_data_3, attributes: attr)

    %{leader_epoch: leader_epoch} =
      Helpers.get_metadata_for_topic_and_partition(topic_name, partition_index)

    headers = %{correlation_id: correlation_id} = Helpers.generate_headers()

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
          topic_id: topic_id,
          partitions: [
            %{
              partition: partition_index,
              current_leader_epoch: leader_epoch,
              fetch_offset: offset_1,
              last_fetched_epoch: 0,
              log_start_offset: 0,
              partition_max_bytes: 100_000
            }
          ]
        }
      ],
      forgotten_topics_data: [],
      rack_id: "rack"
    }

    {:ok, %{headers: resp_headers, content: resp_content}} =
      %{headers: headers, content: content}
      |> Fetch.serialize_request(version)
      |> Helpers.send_message_to_broker(broker)
      |> Fetch.deserialize_response(version)

    assert %{correlation_id: ^correlation_id} = resp_headers
    assert resp_content.error_code == 0

    topic_resp = Enum.find(resp_content.responses, fn r -> r.topic_id == topic_id end)

    partition_resp =
      Enum.find(topic_resp.partitions, fn r -> r.partition_index == partition_index end)

    assert partition_resp.error_code == 0

    assert [
             %{
               attributes: _,
               base_offset: ^offset_1,
               base_sequence: _,
               base_timestamp: _,
               batch_length: _,
               crc: _,
               last_offset_delta: 2,
               magic: 2,
               max_timestamp: _,
               partition_leader_epoch: _,
               producer_epoch: _,
               producer_id: _,
               records: records_1
             },
             %{
               attributes: _,
               base_offset: ^offset_2,
               base_sequence: _,
               base_timestamp: _,
               batch_length: _,
               crc: _,
               last_offset_delta: 2,
               magic: 2,
               max_timestamp: _,
               partition_leader_epoch: _,
               producer_epoch: _,
               producer_id: _,
               records: records_2
             },
             %{
               attributes: _,
               base_offset: ^offset_3,
               base_sequence: _,
               base_timestamp: _,
               batch_length: _,
               crc: _,
               last_offset_delta: 2,
               magic: 2,
               max_timestamp: _,
               partition_leader_epoch: _,
               producer_epoch: _,
               producer_id: _,
               records: records_3
             }
           ] = partition_resp.records

    assert [
             %{
               attributes: _,
               headers: [],
               key: nil,
               offset_delta: 0,
               timestamp_delta: 0,
               value: "msg_1"
             },
             %{
               attributes: _,
               headers: [],
               key: nil,
               offset_delta: 1,
               timestamp_delta: 1,
               value: "msg_2"
             },
             %{
               attributes: _,
               headers: [],
               key: nil,
               offset_delta: 2,
               timestamp_delta: 2,
               value: "msg_3"
             }
           ] = records_1

    assert [
             %{
               attributes: _,
               headers: [],
               key: nil,
               offset_delta: 0,
               timestamp_delta: 0,
               value: "msg_4"
             },
             %{
               attributes: _,
               headers: [],
               key: nil,
               offset_delta: 1,
               timestamp_delta: 1,
               value: "msg_5"
             },
             %{
               attributes: _,
               headers: [],
               key: nil,
               offset_delta: 2,
               timestamp_delta: 2,
               value: "msg_6"
             }
           ] = records_2

    assert [
             %{
               attributes: _,
               headers: [],
               key: nil,
               offset_delta: 0,
               timestamp_delta: 0,
               value: "msg_7"
             },
             %{
               attributes: _,
               headers: [],
               key: nil,
               offset_delta: 1,
               timestamp_delta: 1,
               value: "msg_8"
             },
             %{
               attributes: _,
               headers: [],
               key: nil,
               offset_delta: 2,
               timestamp_delta: 2,
               value: "msg_9"
             }
           ] = records_3
  end
end
