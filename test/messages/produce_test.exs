defmodule Messages.ProduceTest do
  use ExUnit.Case, async: true

  alias KlifeProtocol.Messages.Produce
  alias KlifeProtocol.TestSupport.Helpers

  test "request and response v0", _ctx do
    topic_name = "test_topic_default"

    version = 0
    partition_index = 0
    ts = DateTime.to_unix(DateTime.utc_now())

    {:ok, _} = Helpers.get_or_create_topic(topic_name)

    broker = Helpers.get_broker_for_topic_partition(topic_name, partition_index)

    headers = %{correlation_id: correlation_id} = Helpers.generate_headers()

    content = %{
      acks: 1,
      timeout_ms: 1000,
      topic_data: [
        %{
          name: topic_name,
          partition_data: [
            %{
              index: partition_index,
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
                records: [
                  %{
                    attributes: 0,
                    timestamp_delta: 0,
                    offset_delta: 0,
                    key: "some_key",
                    value: "some_value",
                    headers: [
                      %{key: "header_key", value: "header_value"}
                    ]
                  }
                ]
              }
            }
          ]
        }
      ]
    }

    {:ok, result} =
      %{headers: headers, content: content}
      |> Produce.serialize_request(version)
      |> Helpers.send_message_to_broker(broker)
      |> Produce.deserialize_response(version)

    assert %{
             headers: headers,
             content: content
           } = result

    assert length(Map.keys(headers)) == 1
    assert %{correlation_id: ^correlation_id} = headers

    assert %{
             responses: [
               %{
                 name: ^topic_name,
                 partition_responses: [
                   %{
                     base_offset: _,
                     error_code: 0,
                     index: ^partition_index
                   }
                 ]
               }
             ]
           } = content
  end

  test "request and response v1", _ctx do
    topic_name = "test_topic_default"

    version = 1
    partition_index = 0
    ts = DateTime.to_unix(DateTime.utc_now())

    {:ok, _} = Helpers.get_or_create_topic(topic_name)

    broker = Helpers.get_broker_for_topic_partition(topic_name, partition_index)

    headers = %{correlation_id: correlation_id} = Helpers.generate_headers()

    content = %{
      acks: 1,
      timeout_ms: 1000,
      topic_data: [
        %{
          name: topic_name,
          partition_data: [
            %{
              index: partition_index,
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
                records: [
                  %{
                    attributes: 0,
                    timestamp_delta: 0,
                    offset_delta: 0,
                    key: "some_key",
                    value: "some_value",
                    headers: [
                      %{key: "header_key", value: "header_value"}
                    ]
                  }
                ]
              }
            }
          ]
        }
      ]
    }

    {:ok, result} =
      %{headers: headers, content: content}
      |> Produce.serialize_request(version)
      |> Helpers.send_message_to_broker(broker)
      |> Produce.deserialize_response(version)

    assert %{
             headers: headers,
             content: content
           } = result

    assert length(Map.keys(headers)) == 1
    assert %{correlation_id: ^correlation_id} = headers

    assert %{
             responses: topics_responses,
             throttle_time_ms: _
           } = content

    assert [
             %{
               name: ^topic_name,
               partition_responses: [
                 %{
                   base_offset: _,
                   error_code: 0,
                   index: ^partition_index
                 }
               ]
             }
           ] = topics_responses
  end

  test "request and response v2", _ctx do
    topic_name = "test_topic_default"

    version = 2
    partition_index = 0
    ts = DateTime.to_unix(DateTime.utc_now())

    {:ok, _} = Helpers.get_or_create_topic(topic_name)

    broker = Helpers.get_broker_for_topic_partition(topic_name, partition_index)

    headers = %{correlation_id: correlation_id} = Helpers.generate_headers()

    content = %{
      acks: 1,
      timeout_ms: 1000,
      topic_data: [
        %{
          name: topic_name,
          partition_data: [
            %{
              index: partition_index,
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
                records: [
                  %{
                    attributes: 0,
                    timestamp_delta: 0,
                    offset_delta: 0,
                    key: "some_key",
                    value: "some_value",
                    headers: [
                      %{key: "header_key", value: "header_value"}
                    ]
                  }
                ]
              }
            }
          ]
        }
      ]
    }

    {:ok, result} =
      %{headers: headers, content: content}
      |> Produce.serialize_request(version)
      |> Helpers.send_message_to_broker(broker)
      |> Produce.deserialize_response(version)

    assert %{
             headers: headers,
             content: content
           } = result

    assert length(Map.keys(headers)) == 1
    assert %{correlation_id: ^correlation_id} = headers

    assert %{
             responses: topics_responses,
             throttle_time_ms: _
           } = content

    assert [
             %{
               name: ^topic_name,
               partition_responses: [
                 %{
                   base_offset: _,
                   error_code: 0,
                   index: ^partition_index,
                   log_append_time_ms: _
                 }
               ]
             }
           ] = topics_responses
  end

  test "request and response v3", _ctx do
    topic_name = "test_topic_default"

    version = 3
    partition_index = 0
    ts = DateTime.to_unix(DateTime.utc_now())

    {:ok, _} = Helpers.get_or_create_topic(topic_name)

    broker = Helpers.get_broker_for_topic_partition(topic_name, partition_index)

    headers = %{correlation_id: correlation_id} = Helpers.generate_headers()

    content = %{
      transactional_id: "some_transactional_id",
      acks: 1,
      timeout_ms: 1000,
      topic_data: [
        %{
          name: topic_name,
          partition_data: [
            %{
              index: partition_index,
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
                records: [
                  %{
                    attributes: 0,
                    timestamp_delta: 0,
                    offset_delta: 0,
                    key: "some_key",
                    value: "some_value",
                    headers: [
                      %{key: "header_key", value: "header_value"}
                    ]
                  }
                ]
              }
            }
          ]
        }
      ]
    }

    {:ok, result} =
      %{headers: headers, content: content}
      |> Produce.serialize_request(version)
      |> Helpers.send_message_to_broker(broker)
      |> Produce.deserialize_response(version)

    assert %{
             headers: headers,
             content: content
           } = result

    assert length(Map.keys(headers)) == 1
    assert %{correlation_id: ^correlation_id} = headers

    assert %{
             responses: topics_responses,
             throttle_time_ms: _
           } = content

    assert [
             %{
               name: ^topic_name,
               partition_responses: [
                 %{
                   base_offset: _,
                   error_code: 0,
                   index: ^partition_index,
                   log_append_time_ms: _
                 }
               ]
             }
           ] = topics_responses
  end

  test "request and response v4", _ctx do
    topic_name = "test_topic_default"

    version = 4
    partition_index = 0
    ts = DateTime.to_unix(DateTime.utc_now())

    {:ok, _} = Helpers.get_or_create_topic(topic_name)

    broker = Helpers.get_broker_for_topic_partition(topic_name, partition_index)

    headers = %{correlation_id: correlation_id} = Helpers.generate_headers()

    content = %{
      transactional_id: "some_transactional_id",
      acks: 1,
      timeout_ms: 1000,
      topic_data: [
        %{
          name: topic_name,
          partition_data: [
            %{
              index: partition_index,
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
                records: [
                  %{
                    attributes: 0,
                    timestamp_delta: 0,
                    offset_delta: 0,
                    key: "some_key",
                    value: "some_value",
                    headers: [
                      %{key: "header_key", value: "header_value"}
                    ]
                  }
                ]
              }
            }
          ]
        }
      ]
    }

    {:ok, result} =
      %{headers: headers, content: content}
      |> Produce.serialize_request(version)
      |> Helpers.send_message_to_broker(broker)
      |> Produce.deserialize_response(version)

    assert %{
             headers: headers,
             content: content
           } = result

    assert length(Map.keys(headers)) == 1
    assert %{correlation_id: ^correlation_id} = headers

    assert %{
             responses: topics_responses,
             throttle_time_ms: _
           } = content

    assert [
             %{
               name: ^topic_name,
               partition_responses: [
                 %{
                   base_offset: _,
                   error_code: 0,
                   index: ^partition_index,
                   log_append_time_ms: _
                 }
               ]
             }
           ] = topics_responses
  end

  test "request and response v5", _ctx do
    topic_name = "test_topic_default"

    version = 5
    partition_index = 0
    ts = DateTime.to_unix(DateTime.utc_now())

    {:ok, _} = Helpers.get_or_create_topic(topic_name)

    broker = Helpers.get_broker_for_topic_partition(topic_name, partition_index)

    headers = %{correlation_id: correlation_id} = Helpers.generate_headers()

    content = %{
      transactional_id: "some_transactional_id",
      acks: 1,
      timeout_ms: 1000,
      topic_data: [
        %{
          name: topic_name,
          partition_data: [
            %{
              index: partition_index,
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
                records: [
                  %{
                    attributes: 0,
                    timestamp_delta: 0,
                    offset_delta: 0,
                    key: "some_key",
                    value: "some_value",
                    headers: [
                      %{key: "header_key", value: "header_value"}
                    ]
                  }
                ]
              }
            }
          ]
        }
      ]
    }

    {:ok, result} =
      %{headers: headers, content: content}
      |> Produce.serialize_request(version)
      |> Helpers.send_message_to_broker(broker)
      |> Produce.deserialize_response(version)

    assert %{
             headers: headers,
             content: content
           } = result

    assert length(Map.keys(headers)) == 1
    assert %{correlation_id: ^correlation_id} = headers

    assert %{
             responses: topics_responses,
             throttle_time_ms: _
           } = content

    assert [
             %{
               name: ^topic_name,
               partition_responses: [
                 %{
                   base_offset: _,
                   error_code: 0,
                   index: ^partition_index,
                   log_append_time_ms: _
                 }
               ]
             }
           ] = topics_responses
  end

  test "request and response v6", _ctx do
    topic_name = "test_topic_default"

    version = 6
    partition_index = 0
    ts = DateTime.to_unix(DateTime.utc_now())

    {:ok, _} = Helpers.get_or_create_topic(topic_name)

    broker = Helpers.get_broker_for_topic_partition(topic_name, partition_index)

    headers = %{correlation_id: correlation_id} = Helpers.generate_headers()

    content = %{
      transactional_id: "some_transactional_id",
      acks: 1,
      timeout_ms: 1000,
      topic_data: [
        %{
          name: topic_name,
          partition_data: [
            %{
              index: partition_index,
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
                records: [
                  %{
                    attributes: 0,
                    timestamp_delta: 0,
                    offset_delta: 0,
                    key: "some_key",
                    value: "some_value",
                    headers: [
                      %{key: "header_key", value: "header_value"}
                    ]
                  }
                ]
              }
            }
          ]
        }
      ]
    }

    {:ok, result} =
      %{headers: headers, content: content}
      |> Produce.serialize_request(version)
      |> Helpers.send_message_to_broker(broker)
      |> Produce.deserialize_response(version)

    assert %{
             headers: headers,
             content: content
           } = result

    assert length(Map.keys(headers)) == 1
    assert %{correlation_id: ^correlation_id} = headers

    assert %{
             responses: topics_responses,
             throttle_time_ms: _
           } = content

    assert [
             %{
               name: ^topic_name,
               partition_responses: [
                 %{
                   base_offset: _,
                   error_code: 0,
                   index: ^partition_index,
                   log_append_time_ms: _
                 }
               ]
             }
           ] = topics_responses
  end

  test "request and response v7", _ctx do
    topic_name = "test_topic_default"

    version = 7
    partition_index = 0
    ts = DateTime.to_unix(DateTime.utc_now())

    {:ok, _} = Helpers.get_or_create_topic(topic_name)

    broker = Helpers.get_broker_for_topic_partition(topic_name, partition_index)

    headers = %{correlation_id: correlation_id} = Helpers.generate_headers()

    content = %{
      transactional_id: "some_transactional_id",
      acks: 1,
      timeout_ms: 1000,
      topic_data: [
        %{
          name: topic_name,
          partition_data: [
            %{
              index: partition_index,
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
                records: [
                  %{
                    attributes: 0,
                    timestamp_delta: 0,
                    offset_delta: 0,
                    key: "some_key",
                    value: "some_value",
                    headers: [
                      %{key: "header_key", value: "header_value"}
                    ]
                  }
                ]
              }
            }
          ]
        }
      ]
    }

    {:ok, result} =
      %{headers: headers, content: content}
      |> Produce.serialize_request(version)
      |> Helpers.send_message_to_broker(broker)
      |> Produce.deserialize_response(version)

    assert %{
             headers: headers,
             content: content
           } = result

    assert length(Map.keys(headers)) == 1
    assert %{correlation_id: ^correlation_id} = headers

    assert %{
             responses: topics_responses,
             throttle_time_ms: _
           } = content

    assert [
             %{
               name: ^topic_name,
               partition_responses: [
                 %{
                   base_offset: _,
                   error_code: 0,
                   index: ^partition_index,
                   log_append_time_ms: _
                 }
               ]
             }
           ] = topics_responses
  end

  test "request and response v8", _ctx do
    topic_name = "test_topic_default"

    version = 8
    partition_index = 0
    ts = DateTime.to_unix(DateTime.utc_now())

    {:ok, _} = Helpers.get_or_create_topic(topic_name)

    broker = Helpers.get_broker_for_topic_partition(topic_name, partition_index)

    headers = %{correlation_id: correlation_id} = Helpers.generate_headers()

    content = %{
      transactional_id: "some_transactional_id",
      acks: 1,
      timeout_ms: 1000,
      topic_data: [
        %{
          name: topic_name,
          partition_data: [
            %{
              index: partition_index,
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
                records: [
                  %{
                    attributes: 0,
                    timestamp_delta: 0,
                    offset_delta: 0,
                    key: "some_key",
                    value: "some_value",
                    headers: [
                      %{key: "header_key", value: "header_value"}
                    ]
                  }
                ]
              }
            }
          ]
        }
      ]
    }

    {:ok, result} =
      %{headers: headers, content: content}
      |> Produce.serialize_request(version)
      |> Helpers.send_message_to_broker(broker)
      |> Produce.deserialize_response(version)

    assert %{
             headers: headers,
             content: content
           } = result

    assert length(Map.keys(headers)) == 1
    assert %{correlation_id: ^correlation_id} = headers

    assert %{
             responses: topics_responses,
             throttle_time_ms: _
           } = content

    assert [
             %{
               name: ^topic_name,
               partition_responses: [
                 %{
                   base_offset: _,
                   error_code: 0,
                   error_message: nil,
                   index: ^partition_index,
                   log_append_time_ms: _,
                   record_errors: []
                 }
               ]
             }
           ] = topics_responses
  end

  test "request and response v9", _ctx do
    topic_name = "test_topic_default"

    version = 9
    partition_index = 0
    ts = DateTime.to_unix(DateTime.utc_now())

    {:ok, _} = Helpers.get_or_create_topic(topic_name)

    broker = Helpers.get_broker_for_topic_partition(topic_name, partition_index)

    headers = %{correlation_id: correlation_id} = Helpers.generate_headers()

    content = %{
      transactional_id: "some_transactional_id",
      acks: 1,
      timeout_ms: 1000,
      topic_data: [
        %{
          name: topic_name,
          partition_data: [
            %{
              index: partition_index,
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
                records: [
                  %{
                    attributes: 0,
                    timestamp_delta: 0,
                    offset_delta: 0,
                    key: nil,
                    value: "some_value",
                    headers: nil
                  }
                ]
              }
            }
          ]
        }
      ]
    }

    {:ok, result} =
      %{headers: headers, content: content}
      |> Produce.serialize_request(version)
      |> Helpers.send_message_to_broker(broker)
      |> Produce.deserialize_response(version)

    assert %{
             headers: headers,
             content: content
           } = result

    assert length(Map.keys(headers)) == 1
    assert %{correlation_id: ^correlation_id} = headers

    assert %{
             responses: topics_responses,
             throttle_time_ms: _
           } = content

    assert [
             %{
               name: ^topic_name,
               partition_responses: [
                 %{
                   base_offset: _,
                   error_code: 0,
                   error_message: nil,
                   index: ^partition_index,
                   log_append_time_ms: _,
                   record_errors: []
                 }
               ]
             }
           ] = topics_responses
  end
end
