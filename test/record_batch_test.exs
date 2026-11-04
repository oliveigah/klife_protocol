defmodule KlifeProtocol.RecordBatchTest do
  use ExUnit.Case, async: true

  alias KlifeProtocol.RecordBatch

  @tag core: true
  test "compression bits" do
    none = RecordBatch.encode_attributes(compression: :none)
    assert Bitwise.band(none, 7) == 0
    gzip = RecordBatch.encode_attributes(compression: :gzip)
    assert Bitwise.band(gzip, 7) == 1
    snappy = RecordBatch.encode_attributes(compression: :snappy)
    assert Bitwise.band(snappy, 7) == 2
    lz4 = RecordBatch.encode_attributes(compression: :lz4)
    assert Bitwise.band(lz4, 7) == 3
    zstd = RecordBatch.encode_attributes(compression: :zstd)
    assert Bitwise.band(zstd, 7) == 4

    assert is_integer(none)
    assert %{compression: :none} = RecordBatch.decode_attributes(none)

    assert is_integer(gzip)
    assert %{compression: :gzip} = RecordBatch.decode_attributes(gzip)

    assert is_integer(snappy)
    assert %{compression: :snappy} = RecordBatch.decode_attributes(snappy)

    assert is_integer(lz4)
    assert %{compression: :lz4} = RecordBatch.decode_attributes(lz4)

    assert is_integer(zstd)
    assert %{compression: :zstd} = RecordBatch.decode_attributes(zstd)
  end

  @tag core: true
  test "other bits" do
    opts = [
      compression: :gzip,
      timestamp_type: :log_append_time,
      is_transactional: true,
      is_control_batch: true,
      has_delete_horizon: true
    ]

    input = RecordBatch.encode_attributes(opts)

    assert is_integer(input)

    assert %{
             compression: :gzip,
             timestamp_type: :log_append_time,
             is_transactional: true,
             is_control_batch: true,
             has_delete_horizon: true
           } = RecordBatch.decode_attributes(input)
  end

  @tag core: true
  test "serializes and deserializes tombstones and null header values" do
    for compression <- [:none, :gzip, :snappy] do
      input = %{
        base_offset: 0,
        partition_leader_epoch: -1,
        magic: 2,
        attributes: RecordBatch.encode_attributes(compression: compression),
        last_offset_delta: 0,
        base_timestamp: 1_000,
        max_timestamp: 1_000,
        producer_id: -1,
        producer_epoch: -1,
        base_sequence: -1,
        records: [
          %{
            attributes: 0,
            timestamp_delta: 0,
            offset_delta: 0,
            key: "key",
            value: nil,
            headers: [%{key: "header", value: nil}]
          }
        ]
      }

      bin = input |> RecordBatch.serialize() |> :erlang.iolist_to_binary()

      assert {%{records: [%{key: "key", value: nil, headers: headers}]}, <<>>} =
               RecordBatch.deserialize(bin)

      assert [%{key: "header", value: nil}] = headers

      # Without compression the record is the tail of the batch, so the wire
      # format can be checked directly. Varints are zigzag encoded, so the -1
      # length that marks a null value is the single byte 0x01.
      if compression == :none do
        expected_record = <<
          # attributes, timestamp_delta, offset_delta
          0,
          0,
          0,
          # key length 3, key
          6,
          "key",
          # value length -1 (tombstone)
          1,
          # header count 1
          2,
          # header key length 6, header key
          12,
          "header",
          # header value length -1
          1
        >>

        # record count, then the record length as a zigzag varint
        expected_tail =
          <<1::32>> <> <<byte_size(expected_record) * 2>> <> expected_record

        assert String.ends_with?(bin, expected_tail)
      end
    end
  end
end
