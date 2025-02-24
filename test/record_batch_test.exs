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
end
