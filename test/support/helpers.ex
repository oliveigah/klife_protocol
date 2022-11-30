defmodule KlifeProtocol.TestSupport.Helpers do
  alias KlifeProtocol.Connection
  alias KlifeProtocol.Messages

  @default_brokers [
    broker1: "localhost:19092",
    broker2: "localhost:29092",
    broker3: "localhost:39092"
  ]

  def send_message_to_broker(data, broker \\ nil) do
    host =
      if broker do
        Keyword.fetch!(@default_brokers, broker)
      else
        @default_brokers
        |> Enum.random()
        |> elem(1)
      end

    {:ok, conn} = Connection.new(host)
    :ok = Connection.send_data(conn, data)
    {:ok, response} = Connection.read_data(conn)
    Connection.close(conn)
    response
  end

  def genereate_headers(opts \\ []) do
    %{
      correlation_id: Keyword.get(opts, :correlation_id, Enum.random(1..100_000)),
      client_id: Keyword.get(opts, :client_id, "test_klife_client_id")
    }
  end

  def metadata_request(opts) do
    headers = genereate_headers()
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
    |> send_message_to_broker()
    |> Messages.Metadata.deserialize_response(version)
  end

  def get_cluster_controller_broker() do
    version = Messages.DescribeCluster.max_supported_version()

    headers = genereate_headers()

    content = %{
      include_cluster_authorized_operations: true
    }

    %{headers: _resp_headers, content: resp_content} =
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
    %{content: content} = metadata_request(topic_name: topic)
    [topic_data] = content.topics

    %{leader_id: leader_id} =
      Enum.find(topic_data.partitions, &(&1.partition_index == partition_index))

    %{host: host} = Enum.find(content.brokers, &(&1.node_id == leader_id))

    String.to_existing_atom(host)
  end

  def create_topic(topic_name, opts \\ []) do
    version = Messages.CreateTopics.max_supported_version()

    headers = genereate_headers()

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

    %{headers: _headers, content: resp_content} =
      %{headers: headers, content: content}
      |> Messages.CreateTopics.serialize_request(version)
      |> send_message_to_broker(get_cluster_controller_broker())
      |> Messages.CreateTopics.deserialize_response(version)

    [result] = resp_content.topics

    case result do
      %{error_code: 0} ->
        {:ok, result.topic_id}

      %{error_code: 36} ->
        %{content: content} = metadata_request(topic_name: topic_name)
        [result] = content.topics

        {:ok, result.topic_id}

      _ ->
        {:error, {result.error_code, result[:error_message]}}
    end
  end
end
