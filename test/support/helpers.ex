defmodule KlifeProtocol.TestSupport.Helpers do
  @moduledoc """
  TEST PURPOSES ONLY!
  """

  alias KlifeProtocol.Socket
  alias KlifeProtocol.Messages

  # defined by the docker compose file
  @default_brokers [
    kafka1: "localhost:19092",
    kafka2: "localhost:29092",
    kafka3: "localhost:39092"
  ]

  @default_brokers_ssl [
    kafka1: "localhost:19093",
    kafka2: "localhost:29093",
    kafka3: "localhost:39093"
  ]

  def initialize_shared_storage() do
    :ets.new(:shared_storage, [:named_table, :set, :public])
    write_to_shared(:correlation_counter, :atomics.new(1, []))

    :ok
  end

  def initialize_connections("SSL") do
    ssl_opts = [
      verify: :verify_peer,
      cacertfile: Path.relative("test/compose_files/ssl/ca.crt")
    ]

    socket_backend = :ssl
    opts = [backend: socket_backend, active: false] ++ ssl_opts

    Enum.each(@default_brokers_ssl, fn {broker, hostname} ->
      [host, port] = String.split(hostname, ":")
      result = Socket.connect(host, String.to_integer(port), opts)
      write_to_shared(broker, {socket_backend, result})
    end)
  end

  def initialize_connections(nil) do
    socket_backend = :gen_tcp
    opts = [backend: socket_backend, active: false]

    Enum.each(@default_brokers, fn {broker, hostname} ->
      [host, port] = String.split(hostname, ":")
      result = Socket.connect(host, String.to_integer(port), opts)
      write_to_shared(broker, {socket_backend, result})
    end)
  end

  def initialize_connections(unknown_conn_mode) do
    raise """
    Unkown CONN_MODE env var.

    Expected: SSL
    Found: #{unknown_conn_mode}
    """
  end

  def write_to_shared(key, val), do: :ets.insert(:shared_storage, {key, val})

  def read_from_shared(key, default \\ nil) do
    case :ets.lookup(:shared_storage, key) do
      [{^key, val}] ->
        val

      [] ->
        default
    end
  end

  def send_message_to_broker(data), do: send_message_to_broker(data, nil)

  def send_message_to_broker(data, nil) do
    broker =
      @default_brokers
      |> Enum.random()
      |> elem(0)

    {backend, {:ok, socket}} = read_from_shared(broker)
    :ok = backend.send(socket, data)
    {:ok, response} = backend.recv(socket, 0, 5_000)
    response
  end

  def send_message_to_broker(data, broker) do
    {backend, {:ok, socket}} = read_from_shared(broker)
    :ok = backend.send(socket, data)
    {:ok, response} = backend.recv(socket, 0, 5_000)
    response
  end

  defp generate_correlation_id() do
    ref = read_from_shared(:correlation_counter)
    :atomics.add_get(ref, 1, 1)
  end

  def increment_and_get_base_sequence(topic, partition, incr) do
    key = {:base_sequence_counter, topic, partition}

    ref =
      case read_from_shared(key) do
        nil ->
          ref = :atomics.new(1, [])
          write_to_shared(key, ref)
          ref

        ref ->
          ref
      end

    new_val = :atomics.add_get(ref, 1, incr)
    new_val - incr
  end

  defp decrement_base_sequence(topic, partition, decr) do
    ref = read_from_shared({:base_sequence_counter, topic, partition})
    :atomics.sub_get(ref, 1, decr)
  end

  defp override_base_sequence(topic, partition, val) do
    key = {:base_sequence_counter, topic, partition}

    ref =
      case read_from_shared(key) do
        nil ->
          ref = :atomics.new(1, [])
          write_to_shared(key, ref)
          ref

        ref ->
          ref
      end

    :atomics.put(ref, 1, val)
  end

  def generate_headers(opts \\ []) do
    %{
      correlation_id: generate_correlation_id(),
      client_id: Keyword.get(opts, :client_id, "klife_test_client")
    }
  end

  def metadata_request(opts) do
    headers = generate_headers()
    default_id = "00000000-0000-0000-0000-000000000000"

    version = Messages.Metadata.max_supported_version()

    content = %{
      topics: [
        %{
          topic_id: Keyword.get(opts, :topic_id, default_id),
          name: Keyword.get(opts, :topic_name)
        }
      ],
      allow_auto_topic_creation: false,
      include_cluster_authorized_operations: true,
      include_topic_authorized_operations: true
    }

    %{headers: headers, content: content}
    |> Messages.Metadata.serialize_request(version)
    |> send_message_to_broker(get_cluster_controller_broker())
    |> Messages.Metadata.deserialize_response(version)
  end

  def get_cluster_controller_broker() do
    version = 0
    headers = generate_headers()

    content = %{
      include_cluster_authorized_operations: true
    }

    {:ok, %{headers: _resp_headers, content: resp_content}} =
      %{headers: headers, content: content}
      |> Messages.DescribeCluster.serialize_request(version)
      |> send_message_to_broker()
      |> Messages.DescribeCluster.deserialize_response(version)

    resp_content
    |> Map.get(:brokers)
    |> Enum.find(fn e -> e.broker_id == resp_content.controller_id end)
    |> Map.get(:host)
    |> String.to_atom()
  end

  def get_broker_for_topic_partition(topic, partition_index) do
    {:ok, %{content: content}} = metadata_request(topic_name: topic)
    [topic_data] = content.topics

    %{leader_id: leader_id} =
      Enum.find(topic_data.partitions, &(&1.partition_index == partition_index))

    %{host: host} = Enum.find(content.brokers, &(&1.node_id == leader_id))

    String.to_existing_atom(host)
  end

  def get_or_create_topic(topic_name, opts \\ []) do
    version = Messages.CreateTopics.max_supported_version()

    headers = generate_headers()

    content = %{
      topics: [
        %{
          name: topic_name,
          num_partitions: Keyword.get(opts, :num_partitions, 3),
          replication_factor: Keyword.get(opts, :replication_factor, 2),
          assignments: [],
          configs: []
        }
      ],
      timeout_ms: 1000,
      validate_only: false
    }

    {:ok, %{headers: _headers, content: resp_content}} =
      %{headers: headers, content: content}
      |> Messages.CreateTopics.serialize_request(version)
      |> send_message_to_broker(get_cluster_controller_broker())
      |> Messages.CreateTopics.deserialize_response(version)

    [result] = resp_content.topics

    case result do
      %{error_code: 0} ->
        {:ok, result.topic_id}

      %{error_code: 36} ->
        {:ok, %{content: content}} = metadata_request(topic_name: topic_name)

        [result] = content.topics

        sync_shared_base_sequence(topic_name)

        {:ok, result.topic_id}

      _ ->
        {:error, {result.error_code, result[:error_message]}}
    end
  end

  def get_metadata_for_topic_and_partition(topic_name, partition_index) do
    [topic_name: topic_name]
    |> metadata_request()
    |> elem(1)
    |> Map.get(:content)
    |> Map.get(:topics)
    |> Enum.find(%{}, &(&1.name == topic_name))
    |> Map.get(:partitions)
    |> Enum.find(%{}, &(&1.partition_index == partition_index))
  end

  def produce_message(topic_name, vals, opts \\ [])

  def produce_message(topic_name, vals, opts) when is_list(vals) do
    version = 9
    partition_index = Keyword.get(opts, :index, 0)
    ts = Keyword.get(opts, :timestamp, DateTime.to_unix(DateTime.utc_now()))
    {:ok, _} = get_or_create_topic(topic_name, opts)

    %{leader_epoch: leader_epoch} =
      get_metadata_for_topic_and_partition(topic_name, partition_index)

    broker = get_broker_for_topic_partition(topic_name, partition_index)
    headers = generate_headers(opts)
    vals_len = length(vals)

    content = %{
      transactional_id: Keyword.get(opts, :transactional_id),
      acks: Keyword.get(opts, :acks, -1),
      timeout_ms: Keyword.get(opts, :timeout_ms, 1000),
      topic_data: [
        %{
          name: topic_name,
          partition_data: [
            %{
              index: partition_index,
              records: %{
                base_offset: 0,
                partition_leader_epoch: leader_epoch,
                magic: 2,
                attributes: Keyword.get(opts, :attributes, 0),
                last_offset_delta: vals_len - 1,
                base_timestamp: ts,
                max_timestamp: ts + vals_len - 1,
                producer_id: Keyword.get(opts, :producer_id, 0),
                producer_epoch: Keyword.get(opts, :producer_epoch, 0),
                base_sequence:
                  increment_and_get_base_sequence(topic_name, partition_index, vals_len),
                records:
                  vals
                  |> Enum.with_index()
                  |> Enum.map(fn {val, idx} ->
                    %{
                      attributes: Keyword.get(opts, :attributes, 0),
                      timestamp_delta: idx,
                      offset_delta: idx,
                      key: Keyword.get(opts, :key),
                      value: val,
                      headers: Keyword.get(opts, :headers)
                    }
                  end)
              }
            }
          ]
        }
      ]
    }

    {:ok, %{headers: _resp_headers, content: resp_content}} =
      %{headers: headers, content: content}
      |> Messages.Produce.serialize_request(version)
      |> send_message_to_broker(broker)
      |> Messages.Produce.deserialize_response(version)

    %{responses: topics_responses} = resp_content
    [topic_response] = topics_responses
    [partition_response] = topic_response.partition_responses

    case partition_response do
      %{error_code: 0} = resp ->
        {:ok, %{broker: broker, partition_index: partition_index, offset: resp.base_offset}}

      %{error_code: 45, log_start_offset: offset} ->
        override_base_sequence(topic_name, partition_index, offset)
        produce_message(topic_name, vals, opts)

      resp ->
        decrement_base_sequence(topic_name, partition_index, vals_len)
        {:error, {resp.error_code, resp.error_message}}
    end
  end

  def produce_message(topic_name, val, opts), do: produce_message(topic_name, [val], opts)

  defp sync_shared_base_sequence(topic) do
    {:ok, %{content: metadata_content}} = metadata_request(topic_name: topic)
    [topic_res] = metadata_content.topics
    partitions = topic_res.partitions

    Enum.each(partitions, fn p ->
      version = Messages.DescribeProducers.max_supported_version()
      headers = generate_headers()

      content = %{
        topics: [
          %{
            name: topic,
            partition_indexes: [p.partition_index]
          }
        ]
      }

      {:ok, %{headers: _headers, content: resp_content}} =
        %{headers: headers, content: content}
        |> Messages.DescribeProducers.serialize_request(version)
        |> send_message_to_broker(get_broker_for_topic_partition(topic, p.partition_index))
        |> Messages.DescribeProducers.deserialize_response(version)

      last_sequence =
        resp_content
        |> Map.get(:topics)
        |> List.first()
        |> Map.get(:partitions)
        |> List.first()
        |> Map.get(:active_producers)
        |> case do
          [] ->
            -1

          active_producers ->
            active_producers
            |> List.first()
            |> Map.get(:last_sequence)
        end

      override_base_sequence(topic, p.partition_index, last_sequence + 1)
    end)
  end
end
