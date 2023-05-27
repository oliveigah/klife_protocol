# Klife Protocol

This is an Elixir implementation of the [Kafka protocol](https://kafka.apache.org/protocol.html). It enables communication with Kafka brokers using standard Elixir data structures without the need for manual serialization.

The implementation is specifically designed to handle only the wire protocol. Therefore, it should be used inside a full Kafka client rather than being directly integrated into application code.

## Supported messages

One of the main features of this library is its ability to generate Elixir code using [Kafka message definitions](https://github.com/apache/kafka/tree/trunk/clients/src/main/resources/common/message). This ensures that all currently available and future messages (excluding the ones mentioned below) should be easily supported in all versions by the implementation. 

This implementation of the Kafka protocol supports all currently available messages and versions, except for `Fetch` versions below 4. This is due to a change in record batch serialization in newer versions (>=4) of this message. As a result, the library is NOT compatible with Kafka versions prior 0.11.

## Basic example

This is an example of usage that creates a connection with a broker, send the API version message and handle the response.

```elixir
alias KlifeProtocol.Connection
alias KlifeProtocol.Messages

{:ok, conn} = Connection.new("localhost:19092")
version = 0
input = %{headers: %{correlation_id: 123}, content: %{}}
serialized_msg = Messages.ApiVersions.serialize_request(input, version)
:ok = Connection.send_data(conn, serialized_msg)
{:ok, received_data} = Connection.read_data(conn)
{:ok, response} = Messages.ApiVersions.deserialize_response(received_data, version)
```

Inside the `response` variable you will get something like this:

```elixir
%{
  content: %{
    api_keys: [
      %{api_key: 0, max_version: 9, min_version: 0},
      %{api_key: 1, max_version: 13, min_version: 0},
      %{api_key: 2, max_version: 7, min_version: 0},
      %{api_key: 3, max_version: 12, min_version: 0},
      ...
    ],
    error_code: 0,
    throttle_time_ms: 0
  },
  headers: %{correlation_id: 123}
}
```
## Messages API

Each message has it's own set of fields, as described in the Kafka official documentation. On this library, each message has it's own module within `KlifeProtocol.Messages` namespace. In the previous example we used `KlifeProtocol.Messages.ApiVersions` which stands for the [API version message](https://kafka.apache.org/protocol.html#The_Messages_ApiVersions).

You can find the available fields directly on the Kafka documentation or inside the message module documentation, which contains all the possible fields, along with extra comments describing each one of them. All fields can be provided (for serialization) or returned (for deseriaization) inside the content map attribute.

For instance the `Messages.ApiVersions.serialize_request/2` has the following documentation:
```elixir
  @doc """
  Content fields:

  - client_software_name: The name of the client. (string | versions 3+)
  - client_software_version: The version of the client. (string | versions 3+)

  """
```

Which means that on versions 3+ you can provide `client_software_name` and `client_software_version` on the content map of the input, like this:

```elixir
input = %{headers: %{correlation_id: 123}, content: %{client_software_name: "some_name"}}
serialized_msg = Messages.ApiVersions.serialize_request(input, 3)
```

The `Messages.ApiVersions.deserialize_response/2` schema works the same, but instead of the input map, it affects the returning map.

```elixir
  @doc """
  Content fields:

  - error_code: The top-level error code. (int16 | versions 0+)
  - api_keys: The APIs supported by the broker. ([]ApiVersion | versions 0+)
      - api_key: The API index. (int16 | versions 0+)
      - min_version: The minimum supported version, inclusive. (int16 | versions 0+)
      - max_version: The maximum supported version, inclusive. (int16 | versions 0+)
  - throttle_time_ms: The duration in milliseconds for which the request was throttled due to a quota violation, or zero if the request did not violate any quota. (int32 | versions 1+)
  - supported_features: Features supported by the broker. ([]SupportedFeatureKey | versions 3+)
      - name: The name of the feature. (string | versions 3+)
      - min_version: The minimum supported version for the feature. (int16 | versions 3+)
      - max_version: The maximum supported version for the feature. (int16 | versions 3+)
  - finalized_features_epoch: The monotonically increasing epoch for the finalized features information. Valid values are >= 0. A value of -1 is special and represents unknown epoch. (int64 | versions 3+)
  - finalized_features: List of cluster-wide finalized features. The information is valid only if FinalizedFeaturesEpoch >= 0. ([]FinalizedFeatureKey | versions 3+)
      - name: The name of the feature. (string | versions 3+)
      - max_version_level: The cluster-wide finalized max version level for the feature. (int16 | versions 3+)
      - min_version_level: The cluster-wide finalized min version level for the feature. (int16 | versions 3+)
  - zk_migration_ready: Set by a KRaft controller if the required configurations for ZK migration are present (bool | versions 3+)
  """
```

Which means that on the returning value of the deserialization function will return all this fields. Like this:

```elixir
{:ok, %{ headers: headers, content: content }} = Messages.ApiVersions.deserialize_response(binary, 3)

%{
  error_code: 0,
  api_keys: api_keys,
  throttle_time_ms: 0,
  finalized_features_epoch: 0
} = content

```
## Compression and Record Batch Attributes

Currently supports two compression methods: `snappy` using [sanppyer library](https://github.com/zmstone/snappyer) and `gzip` using [erlang zlib library](https://www.erlang.org/doc/man/zlib.html).


To configure the compression strategy, along with other important data such as `timestampType` and `isTransactional`, you can utilize the Kafka record batch's [attributes byte](https://kafka.apache.org/documentation/#recordbatch).


Klife protocol provides an interface to simplify the creation of this attributes using the `encode_attributes/1` and `decode_attributes/1` functions of the `RecordBatch` module. Here's an example:

```elixir
alias KlifeProtocol.RecordBatch

opts = [
  compression: :snappy, 
  timestamp_type: :log_append_time,
  is_transactional: true,
  is_control_batch: true,
  has_delete_horizon: true
]

attr_val = RecordBatch.encode_attributes(opts)

%{
  compression: :snappy,
  timestamp_type: :log_append_time,
  is_transactional: true,
  is_control_batch: true,
  has_delete_horizon: true
} = RecordBatch.decode_attributes(attr_val)
```

With these functions, a client can easily generate and decode attributes for each record batch it handles.
## Performance

This section provides performance benchmarks for the main use cases of produce serialization and fetch deserialization, conducted using the [benchee tool](https://github.com/bencheeorg/benchee). The benchmarks measure only the serialization work, as the Kafka cluster is running solely to retrieve data samples for benchmarking purposes. Note that network latency is not included in the measurements, only serialization/deserialization performance.

The benchmarks were conducted on a personal computer with the following specifications, using only a single core. The operations were performed on messages containing a single record batch with 1, 10, 50 and 100 records to/from a single partition without compression.

```
CPU: Intel i7 10750h
OS : Ubuntu 22.04 
Elixir: 1.14.3-OTP-25
Kernel: 5.19.0
```

All benchmarks can be executed by running the benchmark mix task from the project's base folder:
```
bash run-kafka.sh
mix benchmark produce_serialization
mix benchmark fetch_deserialization
bash stop-kafka.sh
```
### Produce Serialization
| REC QTY | REC SIZE | REC/S  | IPS    | AVG    | P50    | P99     | SD   | Mem. Usg |
|---------|----------|--------|--------|--------|--------|---------|------|----------|
| 1       | 500 kb   | 1.6 k  | 1.60 K | 623 μs | 610 μs | 1150 μs | ±32% | 4 kb     |
| 10      | 50 kb    | 14.3 k | 1.43 K | 700 μs | 645 μs | 1393 μs | ±30% | 13 kb    |
| 50      | 10 kb    | 67.5 k | 1.35 K | 738 μs | 680 μs | 1321 μs | ±25% | 57 kb    |
| 100     | 5 kb     | 110 k  | 1.10 K | 907 μs | 855 μs | 1547 μs | ±22% | 109 kb   |

### Fetch Deserialization
| REC QTY | REC SIZE | REC/S  | IPS    | AVG    | P50    | P99     | SD   | Mem. Usg |
|---------|----------|--------|--------|--------|--------|---------|------|----------|
| 1       | 500 kb   | 4.54 k | 4.54 k | 220 μs | 206 μs | 370 μs  | ±15% | 19 kb    |
| 10      | 50 kb    | 39.7 k | 3.97 k | 252 μs | 232 μs | 377 μs  | ±17% | 62 kb    |
| 50      | 10 kb    | 131 k  | 2.62 k | 382 μs | 370 μs | 521 μs  | ±14% | 250 kb   |
| 100     | 5 kb     | 200 k  | 2.00 k | 500 μs | 490 μs | 652 μs  | ±13% | 486 kb   |


## Project Overview

The project is composed by 5 main components:

- [Module generator](./lib/mix/tasks/generate_files.ex): This component performs a variety of tasks to convert Kafka's message definitions into message modules.

- [Message Modules](./lib/klife_protocol/generated/messages/): These modules serve as the primary interface for clients using this library. They enable the serialization and deserialization of specific messages in the Kafka protocol.

- [Serializer](./lib/klife_protocol/serializer.ex): This module is responsible for transforming Elixir maps into appropriate binaries using the schemas defined by the message modules. These binaries can then be sent across the wire to Kafka brokers.

- [Deserializer](./lib/klife_protocol/deserializer.ex): This module handles the conversion of binaries received from Kafka brokers into Elixir maps. It utilizes the schemas defined by the message modules.

- [Connection](./lib/klife_protocol/connection.ex): Simple wrapper of `:gen_tcp` and `:ssl` erlang modules. Set socket opts that are needed to proper communicate with kafka broker (mainly `packet: 4`). Since it is a simple wrapper, clients may choose to set up their on connection or just initialize it with this module and extract the `socket` attribute and using it directly with `:gen_tcp` and `:ssl` modules.

![](./overview.png "Project overview")
## Running Tests

```
bash run-kafka.sh
mix test
bash stop-kafka.sh
```

In order to prevent race conditions with kafka initialization is recommended to wait a couple seconds between `bash run-kafka.sh` and `mix test`. 

If you want to run tests using a SSL connection, you can use an env var `CONN_MODE=SSL` like this:

```
bash run-kafka.sh
CONN_MODE=SSL mix test
bash stop-kafka.sh
```

## TODOs

- Execute tests on CI
- Publish hex package