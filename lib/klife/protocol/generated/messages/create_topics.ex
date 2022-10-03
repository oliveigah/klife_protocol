defmodule Klife.Protocol.Messages.CreateTopics do
  alias Klife.Protocol.Deserializer
  alias Klife.Protocol.Serializer
  alias Klife.Protocol.Header

  def get_api_key(), do: 19

  def request_schema(0),
    do: [
      topics:
        {:array,
         [
           name: :string,
           num_partitions: :int32,
           replication_factor: :int16,
           assignments: {:array, [partition_index: :int32, broker_ids: {:array, :int32}]},
           configs: {:array, [name: :string, value: :string]}
         ]},
      timeout_ms: :int32
    ]

  def request_schema(1),
    do: [
      topics:
        {:array,
         [
           name: :string,
           num_partitions: :int32,
           replication_factor: :int16,
           assignments: {:array, [partition_index: :int32, broker_ids: {:array, :int32}]},
           configs: {:array, [name: :string, value: :string]}
         ]},
      timeout_ms: :int32,
      validate_only: :boolean
    ]

  def request_schema(2),
    do: [
      topics:
        {:array,
         [
           name: :string,
           num_partitions: :int32,
           replication_factor: :int16,
           assignments: {:array, [partition_index: :int32, broker_ids: {:array, :int32}]},
           configs: {:array, [name: :string, value: :string]}
         ]},
      timeout_ms: :int32,
      validate_only: :boolean
    ]

  def request_schema(3),
    do: [
      topics:
        {:array,
         [
           name: :string,
           num_partitions: :int32,
           replication_factor: :int16,
           assignments: {:array, [partition_index: :int32, broker_ids: {:array, :int32}]},
           configs: {:array, [name: :string, value: :string]}
         ]},
      timeout_ms: :int32,
      validate_only: :boolean
    ]

  def request_schema(4),
    do: [
      topics:
        {:array,
         [
           name: :string,
           num_partitions: :int32,
           replication_factor: :int16,
           assignments: {:array, [partition_index: :int32, broker_ids: {:array, :int32}]},
           configs: {:array, [name: :string, value: :string]}
         ]},
      timeout_ms: :int32,
      validate_only: :boolean
    ]

  def request_schema(5),
    do: [
      topics:
        {:array,
         [
           name: :string,
           num_partitions: :int32,
           replication_factor: :int16,
           assignments:
             {:array, [partition_index: :int32, broker_ids: {:array, :int32}, tag_buffer: %{}]},
           configs: {:array, [name: :string, value: :string, tag_buffer: %{}]},
           tag_buffer: %{}
         ]},
      timeout_ms: :int32,
      validate_only: :boolean,
      tag_buffer: %{}
    ]

  def request_schema(6),
    do: [
      topics:
        {:array,
         [
           name: :string,
           num_partitions: :int32,
           replication_factor: :int16,
           assignments:
             {:array, [partition_index: :int32, broker_ids: {:array, :int32}, tag_buffer: %{}]},
           configs: {:array, [name: :string, value: :string, tag_buffer: %{}]},
           tag_buffer: %{}
         ]},
      timeout_ms: :int32,
      validate_only: :boolean,
      tag_buffer: %{}
    ]

  def request_schema(7),
    do: [
      topics:
        {:array,
         [
           name: :string,
           num_partitions: :int32,
           replication_factor: :int16,
           assignments:
             {:array, [partition_index: :int32, broker_ids: {:array, :int32}, tag_buffer: %{}]},
           configs: {:array, [name: :string, value: :string, tag_buffer: %{}]},
           tag_buffer: %{}
         ]},
      timeout_ms: :int32,
      validate_only: :boolean,
      tag_buffer: %{}
    ]

  def response_schema(0), do: [topics: {:array, [name: :string, error_code: :int16]}]

  def response_schema(1),
    do: [topics: {:array, [name: :string, error_code: :int16, error_message: :string]}]

  def response_schema(2),
    do: [
      throttle_time_ms: :int32,
      topics: {:array, [name: :string, error_code: :int16, error_message: :string]}
    ]

  def response_schema(3),
    do: [
      throttle_time_ms: :int32,
      topics: {:array, [name: :string, error_code: :int16, error_message: :string]}
    ]

  def response_schema(4),
    do: [
      throttle_time_ms: :int32,
      topics: {:array, [name: :string, error_code: :int16, error_message: :string]}
    ]

  def response_schema(5),
    do: [
      throttle_time_ms: :int32,
      topics:
        {:array,
         [
           name: :string,
           error_code: :int16,
           error_message: :string,
           num_partitions: :int32,
           replication_factor: :int16,
           configs:
             {:array,
              [
                name: :string,
                value: :string,
                read_only: :boolean,
                config_source: :int8,
                is_sensitive: :boolean,
                tag_buffer: %{}
              ]},
           tag_buffer: %{0 => {:topic_config_error_code, :int16}}
         ]},
      tag_buffer: %{}
    ]

  def response_schema(6),
    do: [
      throttle_time_ms: :int32,
      topics:
        {:array,
         [
           name: :string,
           error_code: :int16,
           error_message: :string,
           num_partitions: :int32,
           replication_factor: :int16,
           configs:
             {:array,
              [
                name: :string,
                value: :string,
                read_only: :boolean,
                config_source: :int8,
                is_sensitive: :boolean,
                tag_buffer: %{}
              ]},
           tag_buffer: %{0 => {:topic_config_error_code, :int16}}
         ]},
      tag_buffer: %{}
    ]

  def response_schema(7),
    do: [
      throttle_time_ms: :int32,
      topics:
        {:array,
         [
           name: :string,
           topic_id: :uuid,
           error_code: :int16,
           error_message: :string,
           num_partitions: :int32,
           replication_factor: :int16,
           configs:
             {:array,
              [
                name: :string,
                value: :string,
                read_only: :boolean,
                config_source: :int8,
                is_sensitive: :boolean,
                tag_buffer: %{}
              ]},
           tag_buffer: %{0 => {:topic_config_error_code, :int16}}
         ]},
      tag_buffer: %{}
    ]
end