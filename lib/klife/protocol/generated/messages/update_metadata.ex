defmodule Klife.Protocol.Messages.UpdateMetadata do
  alias Klife.Protocol.Deserializer
  alias Klife.Protocol.Serializer
  alias Klife.Protocol.Header

  def get_api_key(), do: 6

  def request_schema(0),
    do: [
      controller_id: :int32,
      controller_epoch: :int32,
      ungrouped_partition_states:
        {:array,
         [
           topic_name: :string,
           partition_index: :int32,
           controller_epoch: :int32,
           leader: :int32,
           leader_epoch: :int32,
           isr: {:array, :int32},
           zk_version: :int32,
           replicas: {:array, :int32}
         ]},
      live_brokers: {:array, [id: :int32, v0_host: :string, v0_port: :int32]}
    ]

  def request_schema(1),
    do: [
      controller_id: :int32,
      controller_epoch: :int32,
      live_brokers:
        {:array,
         [
           id: :int32,
           endpoints: {:array, [port: :int32, host: :string, security_protocol: :int16]}
         ]}
    ]

  def request_schema(2),
    do: [
      controller_id: :int32,
      controller_epoch: :int32,
      live_brokers:
        {:array,
         [
           id: :int32,
           endpoints: {:array, [port: :int32, host: :string, security_protocol: :int16]},
           rack: :string
         ]}
    ]

  def request_schema(3),
    do: [
      controller_id: :int32,
      controller_epoch: :int32,
      live_brokers:
        {:array,
         [
           id: :int32,
           endpoints:
             {:array, [port: :int32, host: :string, listener: :string, security_protocol: :int16]},
           rack: :string
         ]}
    ]

  def request_schema(4),
    do: [
      controller_id: :int32,
      controller_epoch: :int32,
      ungrouped_partition_states:
        {:array,
         [
           topic_name: :string,
           partition_index: :int32,
           controller_epoch: :int32,
           leader: :int32,
           leader_epoch: :int32,
           isr: {:array, :int32},
           zk_version: :int32,
           replicas: {:array, :int32},
           offline_replicas: {:array, :int32}
         ]},
      live_brokers:
        {:array,
         [
           id: :int32,
           endpoints:
             {:array, [port: :int32, host: :string, listener: :string, security_protocol: :int16]},
           rack: :string
         ]}
    ]

  def request_schema(5),
    do: [
      controller_id: :int32,
      controller_epoch: :int32,
      broker_epoch: :int64,
      topic_states:
        {:array,
         [
           topic_name: :string,
           partition_states:
             {:array,
              [
                partition_index: :int32,
                controller_epoch: :int32,
                leader: :int32,
                leader_epoch: :int32,
                isr: {:array, :int32},
                zk_version: :int32,
                replicas: {:array, :int32},
                offline_replicas: {:array, :int32}
              ]}
         ]},
      live_brokers:
        {:array,
         [
           id: :int32,
           endpoints:
             {:array, [port: :int32, host: :string, listener: :string, security_protocol: :int16]},
           rack: :string
         ]}
    ]

  def request_schema(6),
    do: [
      controller_id: :int32,
      controller_epoch: :int32,
      broker_epoch: :int64,
      topic_states:
        {:array,
         [
           topic_name: :string,
           partition_states:
             {:array,
              [
                partition_index: :int32,
                controller_epoch: :int32,
                leader: :int32,
                leader_epoch: :int32,
                isr: {:array, :int32},
                zk_version: :int32,
                replicas: {:array, :int32},
                offline_replicas: {:array, :int32},
                tag_buffer: %{}
              ]},
           tag_buffer: %{}
         ]},
      live_brokers:
        {:array,
         [
           id: :int32,
           endpoints:
             {:array,
              [
                port: :int32,
                host: :string,
                listener: :string,
                security_protocol: :int16,
                tag_buffer: %{}
              ]},
           rack: :string,
           tag_buffer: %{}
         ]},
      tag_buffer: %{}
    ]

  def request_schema(7),
    do: [
      controller_id: :int32,
      controller_epoch: :int32,
      broker_epoch: :int64,
      topic_states:
        {:array,
         [
           topic_name: :string,
           topic_id: :uuid,
           partition_states:
             {:array,
              [
                partition_index: :int32,
                controller_epoch: :int32,
                leader: :int32,
                leader_epoch: :int32,
                isr: {:array, :int32},
                zk_version: :int32,
                replicas: {:array, :int32},
                offline_replicas: {:array, :int32},
                tag_buffer: %{}
              ]},
           tag_buffer: %{}
         ]},
      live_brokers:
        {:array,
         [
           id: :int32,
           endpoints:
             {:array,
              [
                port: :int32,
                host: :string,
                listener: :string,
                security_protocol: :int16,
                tag_buffer: %{}
              ]},
           rack: :string,
           tag_buffer: %{}
         ]},
      tag_buffer: %{}
    ]

  def response_schema(0), do: [error_code: :int16]
  def response_schema(1), do: [error_code: :int16]
  def response_schema(2), do: [error_code: :int16]
  def response_schema(3), do: [error_code: :int16]
  def response_schema(4), do: [error_code: :int16]
  def response_schema(5), do: [error_code: :int16]
  def response_schema(6), do: [error_code: :int16, tag_buffer: %{}]
  def response_schema(7), do: [error_code: :int16, tag_buffer: %{}]
end