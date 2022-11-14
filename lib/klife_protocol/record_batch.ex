defmodule KlifeProtocol.RecordBatch do
  @moduledoc """

  Record batch

  baseOffset: The offset of the first record on the batch
  batchLength: byte size of records batch
  partitionLeaderEpoch: Epoch of the partition leader (-1 indicates unkown)
  magic: record format version of this record batch
  crc: cyclic redundancy check for the record batch
  attributes: multi purpose informational 16 bit value
    bit 0~2:
        0: no compression
        1: gzip
        2: snappy
        3: lz4
        4: zstd
    bit 3: timestampType
    bit 4: isTransactional (0 means not transactional)
    bit 5: isControlBatch (0 means not a control batch)
    bit 6: hasDeleteHorizonMs (0 means baseTimestamp is not set as the delete horizon for compaction)
    bit 7~15: unused
  lastOffsetDelta: afaict usually equivalent to batchLength - 1
  baseTimestamp: timestamp of the first record on the batch
  maxTimestamp: max timestamp on the batch
  producerId: producer identifier
  producerEpoch: epoch of producer
  baseSequence: first sequence of the batch
  records: array of records
  """

  alias KlifeProtocol.Serializer
  alias KlifeProtocol.CRC32c

  def serialize(input) do
    serialized_batch_headers = Serializer.execute(input, batch_headers_schema())

    serialized_records = Serializer.execute(input, record_schema())

    for_crc_serialized = serialized_batch_headers <> serialized_records
    crc = CRC32c.execute(for_crc_serialized)

    serialized_crc = Serializer.execute(%{crc: crc}, crc_schema())
    serialized_rest = Serializer.execute(input, rest_schema())

    for_length_serialized = serialized_rest <> serialized_crc <> for_crc_serialized
    batch_length = byte_size(for_length_serialized)

    base_input = %{
      base_offset: input.base_offset,
      batch_length: batch_length
    }

    base_data = Serializer.execute(base_input, base_batch_schema())

    base_data <> for_length_serialized
  end

  def base_batch_schema do
    [
      base_offset: {:int64, %{is_nullable?: false}},
      batch_length: {:int32, %{is_nullable?: false}}
    ]
  end

  def rest_schema() do
    [
      partition_leader_epoch: {:int32, %{is_nullable?: false}},
      magic: {:int8, %{is_nullable?: false}}
    ]
  end

  def crc_schema() do
    [crc: {:int32, %{is_nullable?: false}}]
  end

  def batch_headers_schema() do
    [
      attributes: {:int16, %{is_nullable?: false}},
      last_offset_delta: {:int32, %{is_nullable?: false}},
      base_timestamp: {:int64, %{is_nullable?: false}},
      max_timestamp: {:int64, %{is_nullable?: false}},
      producer_id: {:int64, %{is_nullable?: false}},
      producer_epoch: {:int16, %{is_nullable?: false}},
      base_sequence: {:int32, %{is_nullable?: false}}
    ]
  end

  defp record_schema() do
    [
      records:
        {{:records,
          [
            attributes: {:int8, %{is_nullable?: false}},
            timestamp_delta: {:varint, %{is_nullable?: false}},
            offset_delta: {:varint, %{is_nullable?: false}},
            key: {:compact_bytes, %{is_nullable?: false}},
            value: {:compact_bytes, %{is_nullable?: false}},
            headers:
              {{:compact_array,
                [
                  key: {:compact_string, %{is_nullable?: false}},
                  value: {:compact_bytes, %{is_nullable?: false}}
                ]}, %{is_nullable?: false}}
          ]}, %{is_nullable?: false}}
    ]
  end
end
