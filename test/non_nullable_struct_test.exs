defmodule KlifeProtocol.NonNullableStructTest do
  use ExUnit.Case, async: true

  alias KlifeProtocol.Deserializer
  alias KlifeProtocol.Serializer

  @leader_schema [
    leader_id: {:int32, %{is_nullable?: false}},
    leader_epoch: {:int32, %{is_nullable?: false}},
    tag_buffer: {:tag_buffer, %{}}
  ]

  @tag core: true
  test "non nullable structs are encoded inline without a presence marker" do
    schema = [
      before: {:int16, %{is_nullable?: false}},
      current_leader: {{:object, @leader_schema}, %{is_nullable?: false}},
      after: {:int16, %{is_nullable?: false}}
    ]

    input = %{before: 7, current_leader: %{leader_id: 3, leader_epoch: 9}, after: 8}

    bin = schema |> then(&Serializer.execute(input, &1)) |> IO.iodata_to_binary()
    assert bin == <<7::16, 3::32, 9::32, 0, 8::16>>

    assert {:ok, {%{before: 7, current_leader: %{leader_id: 3, leader_epoch: 9}, after: 8}, <<>>}} =
             Deserializer.execute(bin, schema)
  end

  @tag core: true
  test "nullable structs keep the presence marker" do
    schema = [assignment: {{:object, @leader_schema}, %{is_nullable?: true}}]

    bin =
      IO.iodata_to_binary(
        Serializer.execute(%{assignment: %{leader_id: 1, leader_epoch: 2}}, schema)
      )

    assert bin == <<1, 1::32, 2::32, 0>>

    assert {:ok, {%{assignment: %{leader_id: 1, leader_epoch: 2}}, <<>>}} =
             Deserializer.execute(bin, schema)

    null_bin = IO.iodata_to_binary(Serializer.execute(%{assignment: nil}, schema))
    assert null_bin == <<255>>
    assert {:ok, {%{assignment: nil}, <<>>}} = Deserializer.execute(null_bin, schema)
  end
end
