defmodule Klife.Protocol.Messages.DescribeLogDirs do
  alias Klife.Protocol.Deserializer
  alias Klife.Protocol.Serializer
  alias Klife.Protocol.Header

  def get_api_key(), do: 35

  def request_schema(0), do: [topics: {:array, [topic: :string, partitions: {:array, :int32}]}]
  def request_schema(1), do: [topics: {:array, [topic: :string, partitions: {:array, :int32}]}]

  def request_schema(2),
    do: [
      topics: {:array, [topic: :string, partitions: {:array, :int32}, tag_buffer: %{}]},
      tag_buffer: %{}
    ]

  def request_schema(3),
    do: [
      topics: {:array, [topic: :string, partitions: {:array, :int32}, tag_buffer: %{}]},
      tag_buffer: %{}
    ]

  def request_schema(4),
    do: [
      topics: {:array, [topic: :string, partitions: {:array, :int32}, tag_buffer: %{}]},
      tag_buffer: %{}
    ]

  def response_schema(0),
    do: [
      throttle_time_ms: :int32,
      results:
        {:array,
         [
           error_code: :int16,
           log_dir: :string,
           topics:
             {:array,
              [
                name: :string,
                partitions:
                  {:array,
                   [
                     partition_index: :int32,
                     partition_size: :int64,
                     offset_lag: :int64,
                     is_future_key: :boolean
                   ]}
              ]}
         ]}
    ]

  def response_schema(1),
    do: [
      throttle_time_ms: :int32,
      results:
        {:array,
         [
           error_code: :int16,
           log_dir: :string,
           topics:
             {:array,
              [
                name: :string,
                partitions:
                  {:array,
                   [
                     partition_index: :int32,
                     partition_size: :int64,
                     offset_lag: :int64,
                     is_future_key: :boolean
                   ]}
              ]}
         ]}
    ]

  def response_schema(2),
    do: [
      throttle_time_ms: :int32,
      results:
        {:array,
         [
           error_code: :int16,
           log_dir: :string,
           topics:
             {:array,
              [
                name: :string,
                partitions:
                  {:array,
                   [
                     partition_index: :int32,
                     partition_size: :int64,
                     offset_lag: :int64,
                     is_future_key: :boolean,
                     tag_buffer: %{}
                   ]},
                tag_buffer: %{}
              ]},
           tag_buffer: %{}
         ]},
      tag_buffer: %{}
    ]

  def response_schema(3),
    do: [
      throttle_time_ms: :int32,
      error_code: :int16,
      results:
        {:array,
         [
           error_code: :int16,
           log_dir: :string,
           topics:
             {:array,
              [
                name: :string,
                partitions:
                  {:array,
                   [
                     partition_index: :int32,
                     partition_size: :int64,
                     offset_lag: :int64,
                     is_future_key: :boolean,
                     tag_buffer: %{}
                   ]},
                tag_buffer: %{}
              ]},
           tag_buffer: %{}
         ]},
      tag_buffer: %{}
    ]

  def response_schema(4),
    do: [
      throttle_time_ms: :int32,
      error_code: :int16,
      results:
        {:array,
         [
           error_code: :int16,
           log_dir: :string,
           topics:
             {:array,
              [
                name: :string,
                partitions:
                  {:array,
                   [
                     partition_index: :int32,
                     partition_size: :int64,
                     offset_lag: :int64,
                     is_future_key: :boolean,
                     tag_buffer: %{}
                   ]},
                tag_buffer: %{}
              ]},
           total_bytes: :int64,
           usable_bytes: :int64,
           tag_buffer: %{}
         ]},
      tag_buffer: %{}
    ]
end