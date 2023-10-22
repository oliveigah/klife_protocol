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

  @base_batch_schema [
    base_offset: {:int64, %{is_nullable?: false}},
    batch_length: {:int32, %{is_nullable?: false}}
  ]

  @rest_schema [
    partition_leader_epoch: {:int32, %{is_nullable?: false}},
    magic: {:int8, %{is_nullable?: false}},
    crc: {:uint32, %{is_nullable?: false}}
  ]

  @records_metadata_schema [
    attributes: {:int16, %{is_nullable?: false}},
    last_offset_delta: {:int32, %{is_nullable?: false}},
    base_timestamp: {:int64, %{is_nullable?: false}},
    max_timestamp: {:int64, %{is_nullable?: false}},
    producer_id: {:int64, %{is_nullable?: false}},
    producer_epoch: {:int16, %{is_nullable?: false}},
    base_sequence: {:int32, %{is_nullable?: false}}
  ]

  @records_schema [
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

  @for_crc_serialization_no_compression_schema @records_metadata_schema ++ @records_schema

  def serialize(input) do
    for_crc_serialized =
      case Bitwise.band(input.attributes, 7) do
        0 ->
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

          Serializer.execute(for_crc_input, @for_crc_serialization_no_compression_schema)

        other ->
          serialized_records =
            %{records: input.records}
            |> Serializer.execute(@records_schema)
            |> compress(other)

          records_metadata_input = %{
            attributes: input.attributes,
            last_offset_delta: input.last_offset_delta,
            base_timestamp: input.base_timestamp,
            max_timestamp: input.max_timestamp,
            producer_id: input.producer_id,
            producer_epoch: input.producer_epoch,
            base_sequence: input.base_sequence
          }

          serialized_records_metadata =
            Serializer.execute(records_metadata_input, @records_metadata_schema)

          [serialized_records_metadata, serialized_records]
      end

    crc = :crc32cer.nif(for_crc_serialized)

    rest_input = %{
      crc: crc,
      partition_leader_epoch: input.partition_leader_epoch,
      magic: input.magic
    }

    serialized_rest = Serializer.execute(rest_input, @rest_schema)

    for_length_serialized = [serialized_rest, for_crc_serialized]
    batch_length = :erlang.iolist_size(for_length_serialized)

    base_input = %{
      base_offset: input.base_offset,
      batch_length: batch_length
    }

    serialized_base = Serializer.execute(base_input, @base_batch_schema)

    [serialized_base, for_length_serialized]
  end

  def deserialize(<<input::binary>>) do
    with {:ok, {base_result, rest}} <- Deserializer.execute(input, @base_batch_schema),
         {:full_batch?, true} <- {:full_batch?, byte_size(rest) >= base_result.batch_length},
         <<curr_batch::binary-size(base_result.batch_length), total_rest::binary>> <- rest,
         {:ok, {rest_result, rest}} <- Deserializer.execute(curr_batch, @rest_schema),
         {:magic?, true} <- {:magic?, rest_result.magic in [2]},
         {:crc?, true} <- {:crc?, :crc32cer.nif(rest) == rest_result.crc},
         {:ok, {metadata_result, rest}} <- Deserializer.execute(rest, @records_metadata_schema),
         {:ok, records_bin} <- maybe_decompress(rest, metadata_result.attributes),
         {:ok, {records_result, <<>>}} <- Deserializer.execute(records_bin, @records_schema) do
      result =
        base_result
        |> Map.merge(rest_result)
        |> Map.merge(metadata_result)
        |> Map.merge(records_result)

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

  def encode_attributes(opts \\ []) do
    compression = encode_compression(Keyword.get(opts, :compression, :none))
    timestamp_type = encode_timestamp_type(Keyword.get(opts, :timestamp_type, :create_time))
    is_transactional = if Keyword.get(opts, :is_transactional, false), do: 1, else: 0
    is_control_batch = if Keyword.get(opts, :is_control_batch, false), do: 1, else: 0
    has_delete_horizon_ms = if Keyword.get(opts, :has_delete_horizon, false), do: 1, else: 0

    <<val::16-signed>> = <<
      0::9,
      has_delete_horizon_ms::1,
      is_control_batch::1,
      is_transactional::1,
      timestamp_type::1,
      compression::3
    >>

    val
  end

  def decode_attributes(val) do
    <<
      0::9,
      has_delete_horizon_ms::1,
      is_control_batch::1,
      is_transactional::1,
      timestamp_type::1,
      compression::3
    >> = <<val::16-signed>>

    %{
      compression: decode_compression(compression),
      timestamp_type: decode_timestamp_type(timestamp_type),
      is_transactional: is_transactional == 1,
      is_control_batch: is_control_batch == 1,
      has_delete_horizon: has_delete_horizon_ms == 1
    }
  end

  # TODO: Remove the io_list_to_binary call for compress/2
  defp compress(serialized_records, 1) do
    <<records_length::32-signed, records::binary>> = :erlang.iolist_to_binary(serialized_records)
    <<records_length::32-signed, :zlib.gzip(records)::binary>>
  end

  defp compress(serialized_records, 2) do
    <<records_length::32-signed, records::binary>> = :erlang.iolist_to_binary(serialized_records)
    {:ok, compressed_records} = :snappyer.compress(records)
    <<records_length::32-signed, compressed_records::binary>>
  end

  defp compress(_serialized_records, unkown) do
    raise "unsupported compression #{decode_compression(unkown)}"
  end

  defp maybe_decompress(serialized_records, attributes) when is_integer(attributes) do
    case Bitwise.band(attributes, 7) do
      0 ->
        {:ok, serialized_records}

      1 ->
        <<records_length::32-signed, records_values::binary>> = serialized_records
        z = :zlib.open()
        # :zlib.gzip/1 implementation always use 31 window bits
        # see: https://github.com/erlang/otp/blob/master/erts/preloaded/src/zlib.erl#L551
        :zlib.inflateInit(z, 31)
        [decompressed_records | []] = :zlib.inflate(z, records_values)
        :zlib.close(z)
        {:ok, <<records_length::32-signed, decompressed_records::binary>>}

      2 ->
        <<records_length::32-signed, records_values::binary>> = serialized_records
        {:ok, decompressed_records} = :snappyer.decompress(records_values)
        {:ok, <<records_length::32-signed, decompressed_records::binary>>}

      unkown ->
        raise "unsupported decompression #{decode_compression(unkown)}"
    end
  end

  defp encode_compression(:none), do: 0
  defp encode_compression(:gzip), do: 1
  defp encode_compression(:snappy), do: 2
  defp encode_compression(:lz4), do: 3
  defp encode_compression(:zstd), do: 4

  defp decode_compression(0), do: :none
  defp decode_compression(1), do: :gzip
  defp decode_compression(2), do: :snappy
  defp decode_compression(3), do: :lz4
  defp decode_compression(4), do: :zstd

  defp encode_timestamp_type(:create_time), do: 0
  defp encode_timestamp_type(:log_append_time), do: 1

  defp decode_timestamp_type(0), do: :create_time
  defp decode_timestamp_type(1), do: :log_append_time
end
