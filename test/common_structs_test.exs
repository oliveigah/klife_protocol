defmodule KlifeProtocol.CommonStructsTest do
  use ExUnit.Case, async: true

  alias KlifeProtocol.Messages.StreamsGroupDescribe
  alias KlifeProtocol.Messages.StreamsGroupTopologyDescriptionUpdate

  @source %{
    name: "source",
    node_type: 1,
    source_topics: ["input"],
    sink_topic: nil,
    stores: [],
    successors: ["processor"]
  }

  @processor %{
    name: "processor",
    node_type: 2,
    source_topics: [],
    sink_topic: "output",
    stores: ["store"],
    successors: []
  }

  @topology %{
    subtopologies: [%{subtopology_id: "0", nodes: [@source]}],
    global_stores: [%{source: @source, processor: @processor}]
  }

  @tag core: true
  test "serialize request with deeply nested common structs" do
    input = %{
      headers: %{correlation_id: 42, client_id: "klife_test_client"},
      content: %{
        group_id: "streams",
        member_id: "member",
        topology_epoch: 7,
        topology_description: @topology
      }
    }

    # Serialized independently by Apache Kafka 4.4.0's Java message classes.
    expected =
      Base.decode64!(
        "AF0AAAAAACoAEWtsaWZlX3Rlc3RfY2xpZW50AAhzdHJlYW1zB21lbWJlcgAAAAcCAjACB3NvdXJjZQECBmlucHV0AAECCnByb2Nlc3NvcgAAAgdzb3VyY2UBAgZpbnB1dAABAgpwcm9jZXNzb3IACnByb2Nlc3NvcgIBB291dHB1dAIGc3RvcmUBAAAAAA=="
      )

    binary =
      input |> StreamsGroupTopologyDescriptionUpdate.serialize_request(0) |> IO.iodata_to_binary()

    assert binary == expected
  end

  @tag core: true
  test "deserialize response with deeply nested common structs" do
    # Serialized independently by Apache Kafka 4.4.0's Java message classes.
    raw =
      Base.decode64!(
        "AAAAKgAAAAAAAgAAAAhzdHJlYW1zB1N0YWJsZQAAAAcAAAAH/wEAAAAAAQICMAIHc291cmNlAQIGaW5wdXQAAQIKcHJvY2Vzc29yAAACB3NvdXJjZQECBmlucHV0AAECCnByb2Nlc3NvcgAKcHJvY2Vzc29yAgEHb3V0cHV0AgZzdG9yZQEAAAADB3N0aWNreQAA"
      )

    assert {:ok, %{headers: %{correlation_id: 42}, content: %{groups: [group]}}} =
             StreamsGroupDescribe.deserialize_response(raw, 1)

    assert group.error_code == 0
    assert group.group_id == "streams"
    assert group.topology_description == @topology
    assert group.topology_description_status == 3
    assert group.assignor_name == "sticky"
  end
end
