defmodule Messages.ProduceTest do
  use ExUnit.Case

  alias KlifeProtocol.Messages.Produce
  alias KlifeProtocol.TestSupport.Helpers

  test "request and response v0", ctx do
    topic_name = String.replace("#{ctx.module}_#{ctx.test}", " ", "_")

    version = 0
    partition_index = 0
    ts = DateTime.to_unix(DateTime.utc_now())

    {:ok, _} = Helpers.create_topic(topic_name)

    broker = Helpers.get_broker_for_topic_partition(topic_name, partition_index)

    headers = %{correlation_id: correlation_id} = Helpers.genereate_headers()

    content = %{
      acks: 1,
      timeout_ms: 1000,
      topic_data: [
        %{
          name: topic_name,
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

    result =
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

  test "request and response v1", ctx do
    topic_name = String.replace("#{ctx.module}_#{ctx.test}", " ", "_")

    version = 1
    partition_index = 0
    ts = DateTime.to_unix(DateTime.utc_now())

    {:ok, _} = Helpers.create_topic(topic_name)

    broker = Helpers.get_broker_for_topic_partition(topic_name, partition_index)

    headers = %{correlation_id: correlation_id} = Helpers.genereate_headers()

    content = %{
      acks: 1,
      timeout_ms: 1000,
      topic_data: [
        %{
          name: topic_name,
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

    result =
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

  test "request and response v2", ctx do
    topic_name = String.replace("#{ctx.module}_#{ctx.test}", " ", "_")

    version = 2
    partition_index = 0
    ts = DateTime.to_unix(DateTime.utc_now())

    {:ok, _} = Helpers.create_topic(topic_name)

    broker = Helpers.get_broker_for_topic_partition(topic_name, partition_index)

    headers = %{correlation_id: correlation_id} = Helpers.genereate_headers()

    content = %{
      acks: 1,
      timeout_ms: 1000,
      topic_data: [
        %{
          name: topic_name,
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

    result =
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

  test "request and response v3", ctx do
    topic_name = String.replace("#{ctx.module}_#{ctx.test}", " ", "_")

    version = 3
    partition_index = 0
    ts = DateTime.to_unix(DateTime.utc_now())

    {:ok, _} = Helpers.create_topic(topic_name)

    broker = Helpers.get_broker_for_topic_partition(topic_name, partition_index)

    headers = %{correlation_id: correlation_id} = Helpers.genereate_headers()

    content = %{
      transactional_id: "some_transactional_id",
      acks: 1,
      timeout_ms: 1000,
      topic_data: [
        %{
          name: topic_name,
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

    result =
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

  test "request and response v4", ctx do
    topic_name = String.replace("#{ctx.module}_#{ctx.test}", " ", "_")

    version = 4
    partition_index = 0
    ts = DateTime.to_unix(DateTime.utc_now())

    {:ok, _} = Helpers.create_topic(topic_name)

    broker = Helpers.get_broker_for_topic_partition(topic_name, partition_index)

    headers = %{correlation_id: correlation_id} = Helpers.genereate_headers()

    content = %{
      transactional_id: "some_transactional_id",
      acks: 1,
      timeout_ms: 1000,
      topic_data: [
        %{
          name: topic_name,
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

    result =
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

  test "request and response v5", ctx do
    topic_name = String.replace("#{ctx.module}_#{ctx.test}", " ", "_")

    version = 5
    partition_index = 0
    ts = DateTime.to_unix(DateTime.utc_now())

    {:ok, _} = Helpers.create_topic(topic_name)

    broker = Helpers.get_broker_for_topic_partition(topic_name, partition_index)

    headers = %{correlation_id: correlation_id} = Helpers.genereate_headers()

    content = %{
      transactional_id: "some_transactional_id",
      acks: 1,
      timeout_ms: 1000,
      topic_data: [
        %{
          name: topic_name,
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

    result =
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

  test "request and response v6", ctx do
    topic_name = String.replace("#{ctx.module}_#{ctx.test}", " ", "_")

    version = 6
    partition_index = 0
    ts = DateTime.to_unix(DateTime.utc_now())

    {:ok, _} = Helpers.create_topic(topic_name)

    broker = Helpers.get_broker_for_topic_partition(topic_name, partition_index)

    headers = %{correlation_id: correlation_id} = Helpers.genereate_headers()

    content = %{
      transactional_id: "some_transactional_id",
      acks: 1,
      timeout_ms: 1000,
      topic_data: [
        %{
          name: topic_name,
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

    result =
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

  test "request and response v7", ctx do
    topic_name = String.replace("#{ctx.module}_#{ctx.test}", " ", "_")

    version = 7
    partition_index = 0
    ts = DateTime.to_unix(DateTime.utc_now())

    {:ok, _} = Helpers.create_topic(topic_name)

    broker = Helpers.get_broker_for_topic_partition(topic_name, partition_index)

    headers = %{correlation_id: correlation_id} = Helpers.genereate_headers()

    content = %{
      transactional_id: "some_transactional_id",
      acks: 1,
      timeout_ms: 1000,
      topic_data: [
        %{
          name: topic_name,
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

    result =
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

  test "request and response v8", ctx do
    topic_name = String.replace("#{ctx.module}_#{ctx.test}", " ", "_")

    version = 8
    partition_index = 0
    ts = DateTime.to_unix(DateTime.utc_now())

    {:ok, _} = Helpers.create_topic(topic_name)

    broker = Helpers.get_broker_for_topic_partition(topic_name, partition_index)

    headers = %{correlation_id: correlation_id} = Helpers.genereate_headers()

    content = %{
      transactional_id: "some_transactional_id",
      acks: 1,
      timeout_ms: 1000,
      topic_data: [
        %{
          name: topic_name,
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

    result =
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

  test "request and response v9", ctx do
    topic_name = String.replace("#{ctx.module}_#{ctx.test}", " ", "_")

    version = 9
    partition_index = 0
    ts = DateTime.to_unix(DateTime.utc_now())

    {:ok, _} = Helpers.create_topic(topic_name)

    broker = Helpers.get_broker_for_topic_partition(topic_name, partition_index)

    headers = %{correlation_id: correlation_id} = Helpers.genereate_headers()

    content = %{
      transactional_id: "some_transactional_id",
      acks: 1,
      timeout_ms: 1000,
      topic_data: [
        %{
          name: topic_name,
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

    result =
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
