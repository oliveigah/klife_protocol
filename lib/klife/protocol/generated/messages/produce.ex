defmodule Klife.Protocol.Messages.Produce do
  alias Klife.Protocol.Deserializer
  alias Klife.Protocol.Serializer
  alias Klife.Protocol.Header

  def get_api_key(), do: 0

  def request_schema(0),
    do: [
      acks: :int16,
      timeout_ms: :int32,
      topic_data:
        {:array, [name: :string, partition_data: {:array, [index: :int32, records: :records]}]}
    ]

  def request_schema(1),
    do: [
      acks: :int16,
      timeout_ms: :int32,
      topic_data:
        {:array, [name: :string, partition_data: {:array, [index: :int32, records: :records]}]}
    ]

  def request_schema(2),
    do: [
      acks: :int16,
      timeout_ms: :int32,
      topic_data:
        {:array, [name: :string, partition_data: {:array, [index: :int32, records: :records]}]}
    ]

  def request_schema(3),
    do: [
      transactional_id: :string,
      acks: :int16,
      timeout_ms: :int32,
      topic_data:
        {:array, [name: :string, partition_data: {:array, [index: :int32, records: :records]}]}
    ]

  def request_schema(4),
    do: [
      transactional_id: :string,
      acks: :int16,
      timeout_ms: :int32,
      topic_data:
        {:array, [name: :string, partition_data: {:array, [index: :int32, records: :records]}]}
    ]

  def request_schema(5),
    do: [
      transactional_id: :string,
      acks: :int16,
      timeout_ms: :int32,
      topic_data:
        {:array, [name: :string, partition_data: {:array, [index: :int32, records: :records]}]}
    ]

  def request_schema(6),
    do: [
      transactional_id: :string,
      acks: :int16,
      timeout_ms: :int32,
      topic_data:
        {:array, [name: :string, partition_data: {:array, [index: :int32, records: :records]}]}
    ]

  def request_schema(7),
    do: [
      transactional_id: :string,
      acks: :int16,
      timeout_ms: :int32,
      topic_data:
        {:array, [name: :string, partition_data: {:array, [index: :int32, records: :records]}]}
    ]

  def request_schema(8),
    do: [
      transactional_id: :string,
      acks: :int16,
      timeout_ms: :int32,
      topic_data:
        {:array, [name: :string, partition_data: {:array, [index: :int32, records: :records]}]}
    ]

  def request_schema(9),
    do: [
      transactional_id: :string,
      acks: :int16,
      timeout_ms: :int32,
      topic_data:
        {:array,
         [
           name: :string,
           partition_data: {:array, [index: :int32, records: :records, tag_buffer: %{}]},
           tag_buffer: %{}
         ]},
      tag_buffer: %{}
    ]

  def response_schema(0),
    do: [
      responses:
        {:array,
         [
           name: :string,
           partition_responses: {:array, [index: :int32, error_code: :int16, base_offset: :int64]}
         ]}
    ]

  def response_schema(1),
    do: [
      responses:
        {:array,
         [
           name: :string,
           partition_responses: {:array, [index: :int32, error_code: :int16, base_offset: :int64]}
         ]},
      throttle_time_ms: :int32
    ]

  def response_schema(2),
    do: [
      responses:
        {:array,
         [
           name: :string,
           partition_responses:
             {:array,
              [index: :int32, error_code: :int16, base_offset: :int64, log_append_time_ms: :int64]}
         ]},
      throttle_time_ms: :int32
    ]

  def response_schema(3),
    do: [
      responses:
        {:array,
         [
           name: :string,
           partition_responses:
             {:array,
              [index: :int32, error_code: :int16, base_offset: :int64, log_append_time_ms: :int64]}
         ]},
      throttle_time_ms: :int32
    ]

  def response_schema(4),
    do: [
      responses:
        {:array,
         [
           name: :string,
           partition_responses:
             {:array,
              [index: :int32, error_code: :int16, base_offset: :int64, log_append_time_ms: :int64]}
         ]},
      throttle_time_ms: :int32
    ]

  def response_schema(5),
    do: [
      responses:
        {:array,
         [
           name: :string,
           partition_responses:
             {:array,
              [
                index: :int32,
                error_code: :int16,
                base_offset: :int64,
                log_append_time_ms: :int64,
                log_start_offset: :int64
              ]}
         ]},
      throttle_time_ms: :int32
    ]

  def response_schema(6),
    do: [
      responses:
        {:array,
         [
           name: :string,
           partition_responses:
             {:array,
              [
                index: :int32,
                error_code: :int16,
                base_offset: :int64,
                log_append_time_ms: :int64,
                log_start_offset: :int64
              ]}
         ]},
      throttle_time_ms: :int32
    ]

  def response_schema(7),
    do: [
      responses:
        {:array,
         [
           name: :string,
           partition_responses:
             {:array,
              [
                index: :int32,
                error_code: :int16,
                base_offset: :int64,
                log_append_time_ms: :int64,
                log_start_offset: :int64
              ]}
         ]},
      throttle_time_ms: :int32
    ]

  def response_schema(8),
    do: [
      responses:
        {:array,
         [
           name: :string,
           partition_responses:
             {:array,
              [
                index: :int32,
                error_code: :int16,
                base_offset: :int64,
                log_append_time_ms: :int64,
                log_start_offset: :int64,
                record_errors:
                  {:array, [batch_index: :int32, batch_index_error_message: :string]},
                error_message: :string
              ]}
         ]},
      throttle_time_ms: :int32
    ]

  def response_schema(9),
    do: [
      responses:
        {:array,
         [
           name: :string,
           partition_responses:
             {:array,
              [
                index: :int32,
                error_code: :int16,
                base_offset: :int64,
                log_append_time_ms: :int64,
                log_start_offset: :int64,
                record_errors:
                  {:array,
                   [batch_index: :int32, batch_index_error_message: :string, tag_buffer: %{}]},
                error_message: :string,
                tag_buffer: %{}
              ]},
           tag_buffer: %{}
         ]},
      throttle_time_ms: :int32,
      tag_buffer: %{}
    ]
end