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
  alias KlifeProtocol.Deserializer

  def serialize(input) do
    for_crc_input = %{
      attributes: input.attributes,
      last_offset_delta: input.last_offset_delta,
      base_timestamp: input.base_timestamp,
      max_timestamp: input.max_timestamp,
      producer_id: input.producer_id,
      producer_epoch: input.producer_epoch,
      base_sequence: input.base_sequence,
      records: input.records
    }

    for_crc_serialized = Serializer.execute(for_crc_input, for_crc_schema())

    crc = :crc32cer.nif(for_crc_serialized)

    rest_input = %{
      crc: crc,
      partition_leader_epoch: input.partition_leader_epoch,
      magic: input.magic
    }

    serialized_rest = Serializer.execute(rest_input, rest_schema())

    for_length_serialized = serialized_rest <> for_crc_serialized
    batch_length = byte_size(for_length_serialized)

    base_input = %{
      base_offset: input.base_offset,
      batch_length: batch_length
    }

    serialized_base = Serializer.execute(base_input, base_batch_schema())

    serialized_base <> for_length_serialized
  end

  def deserialize(input) do
    with {:ok, {base_result, rest}} <- Deserializer.execute(input, base_batch_schema()),
         {:full_batch?, true} <- {:full_batch?, byte_size(rest) >= base_result.batch_length},
         <<curr_batch::binary-size(base_result.batch_length), total_rest::binary>> <- rest,
         {:ok, {rest_result, rest}} <- Deserializer.execute(curr_batch, rest_schema()),
         {:magic?, true} <- {:magic?, rest_result.magic in [2]},
         {:crc?, true} <- {:crc?, :crc32cer.nif(rest) == rest_result.crc},
         {:ok, {for_crc_result, <<>>}} <- Deserializer.execute(rest, for_crc_schema()) do
      result =
        base_result
        |> Map.merge(rest_result)
        |> Map.merge(for_crc_result)

      {result, total_rest}
    else
      {:full_batch?, false} ->
        :incomplete_batch

      {:magic?, false} ->
        :unsupported_magic

      {:crc?, false} ->
        :redundancy_check_failed

      err ->
        err
    end
  end

  defp base_batch_schema() do
    [
      base_offset: {:int64, %{is_nullable?: false}},
      batch_length: {:int32, %{is_nullable?: false}}
    ]
  end

  defp rest_schema() do
    [
      partition_leader_epoch: {:int32, %{is_nullable?: false}},
      magic: {:int8, %{is_nullable?: false}},
      crc: {:unsigned_int32, %{is_nullable?: false}}
    ]
  end

  defp for_crc_schema() do
    [
      attributes: {:int16, %{is_nullable?: false}},
      last_offset_delta: {:int32, %{is_nullable?: false}},
      base_timestamp: {:int64, %{is_nullable?: false}},
      max_timestamp: {:int64, %{is_nullable?: false}},
      producer_id: {:int64, %{is_nullable?: false}},
      producer_epoch: {:int16, %{is_nullable?: false}},
      base_sequence: {:int32, %{is_nullable?: false}},
      records:
        {{:records_array,
          [
            attributes: {:int8, %{is_nullable?: false}},
            timestamp_delta: {:varint, %{is_nullable?: false}},
            offset_delta: {:varint, %{is_nullable?: false}},
            key: {:record_bytes, %{is_nullable?: true}},
            value: {:record_bytes, %{is_nullable?: false}},
            headers:
              {{:record_headers,
                [
                  key: {:record_bytes, %{is_nullable?: false}},
                  value: {:record_bytes, %{is_nullable?: false}}
                ]}, %{is_nullable?: true}}
          ]}, %{is_nullable?: false}}
    ]
  end
end
