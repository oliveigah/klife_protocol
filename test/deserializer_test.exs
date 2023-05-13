defmodule KlifeProtocol.DeserializerTest do
  use ExUnit.Case

  alias KlifeProtocol.Deserializer

  @default_metadata %{is_nullable?: false}

  test "boolean" do
    input = <<1, 0, 1>>

    schema = [
      a: {:boolean, @default_metadata},
      b: {:boolean, @default_metadata},
      c: {:boolean, @default_metadata}
    ]

    assert {:ok, {response, <<>>}} = Deserializer.execute(input, schema)
    assert %{a: true, b: false, c: true} = response
  end

  test "int8" do
    input = <<31, 123, 4>>

    schema = [
      a: {:int8, @default_metadata},
      b: {:int8, @default_metadata},
      c: {:int8, @default_metadata}
    ]

    assert {:ok, {response, <<>>}} = Deserializer.execute(input, schema)
    assert %{a: 31, b: 123, c: 4} = response
  end

  test "int16" do
    input = <<31::16-signed, 123::16-signed, 4::16-signed>>

    schema = [
      a: {:int16, %{is_nullable?: false}},
      b: {:int16, %{is_nullable?: false}},
      c: {:int16, %{is_nullable?: false}}
    ]

    assert {:ok, {response, <<>>}} = Deserializer.execute(input, schema)
    assert %{a: 31, b: 123, c: 4} = response
  end

  test "int32" do
    input = <<31::32-signed, 123::32-signed, 4::32-signed>>

    schema = [
      a: {:int32, %{is_nullable?: false}},
      b: {:int32, %{is_nullable?: false}},
      c: {:int32, %{is_nullable?: false}}
    ]

    assert {:ok, {response, <<>>}} = Deserializer.execute(input, schema)
    assert %{a: 31, b: 123, c: 4} = response
  end

  test "unsigned_int32" do
    input = <<0::32-signed, 2::8-signed, 4_223_817_021::32>>

    schema = [
      a: {:int32, %{is_nullable?: false}},
      b: {:int8, %{is_nullable?: false}},
      c: {:unsigned_int32, %{is_nullable?: false}}
    ]

    assert {:ok, {response, <<>>}} = Deserializer.execute(input, schema)
    assert %{a: 0, b: 2, c: 4_223_817_021} = response
  end

  test "int64" do
    input = <<31::64-signed, 123::64-signed, 4::64-signed>>

    schema = [
      a: {:int64, @default_metadata},
      b: {:int64, @default_metadata},
      c: {:int64, @default_metadata}
    ]

    assert {:ok, {response, <<>>}} = Deserializer.execute(input, schema)
    assert %{a: 31, b: 123, c: 4} = response
  end

  test "string" do
    input = <<
      byte_size("abc")::16-signed,
      "abc",
      byte_size("defgh")::16-signed,
      "defgh",
      -1::16-signed,
      byte_size("ij")::16-signed,
      "ij"
    >>

    schema = [
      a: {:string, %{is_nullable?: false}},
      b: {:string, %{is_nullable?: false}},
      c: {:string, %{is_nullable?: false}},
      d: {:string, %{is_nullable?: false}}
    ]

    assert {:ok, {response, <<>>}} = Deserializer.execute(input, schema)
    assert %{a: "abc", b: "defgh", c: nil, d: "ij"} = response
  end

  test "array - simple" do
    input = <<
      2::32-signed,
      10::16-signed,
      20::16-signed,
      3::32-signed,
      byte_size("a")::16-signed,
      "a",
      byte_size("b")::16-signed,
      "b",
      byte_size("c")::16-signed,
      "c"
    >>

    schema = [
      a: {{:array, :int16}, %{is_nullable?: false}},
      b: {{:array, :string}, %{is_nullable?: false}}
    ]

    assert {:ok, {response, <<>>}} = Deserializer.execute(input, schema)
    assert %{a: [10, 20], b: ["a", "b", "c"]} = response
  end

  test "array - nested" do
    input = <<
      2::32-signed,
      10::16-signed,
      20::32-signed,
      30::16-signed,
      40::32-signed,
      2::32-signed,
      1::32-signed,
      byte_size("a")::16-signed,
      "a",
      1::16-signed,
      2::32-signed,
      byte_size("b")::16-signed,
      "b",
      2::16-signed,
      byte_size("c")::16-signed,
      "c",
      3::16-signed,
      -1::32-signed,
      0::32-signed
    >>

    schema = [
      a:
        {{:array, [a_a: {:int16, %{is_nullable?: false}}, a_b: {:int32, %{is_nullable?: false}}]},
         %{is_nullable?: false}},
      b:
        {{:array,
          [
            b_a:
              {{:array,
                [
                  b_b: {:string, %{is_nullable?: false}},
                  b_c: {:int16, %{is_nullable?: false}}
                ]}, %{is_nullable?: false}}
          ]}, %{is_nullable?: false}},
      c: {{:array, [c_a: {:int32, %{is_nullable?: false}}]}, %{is_nullable?: false}},
      d: {{:array, [d_a: {:int32, %{is_nullable?: false}}]}, %{is_nullable?: false}}
    ]

    assert {:ok, {response, <<>>}} = Deserializer.execute(input, schema)

    assert %{
             a: [%{a_a: 10, a_b: 20}, %{a_a: 30, a_b: 40}],
             b: [
               %{
                 b_a: [%{b_b: "a", b_c: 1}]
               },
               %{
                 b_a: [%{b_b: "b", b_c: 2}, %{b_b: "c", b_c: 3}]
               }
             ],
             c: nil,
             d: []
           } = response
  end

  test "compact_bytes" do
    input = <<4, 1, 2, 3, 0, 5, 7, 8, 9, 10>>

    schema = [
      a: {:compact_bytes, @default_metadata},
      b: {:compact_bytes, %{is_nullable?: true}},
      c: {:compact_bytes, @default_metadata}
    ]

    assert {:ok, {response, <<>>}} = Deserializer.execute(input, schema)

    assert %{a: <<1, 2, 3>>, b: nil, c: <<7, 8, 9, 10>>} = response
  end

  test "compact_string" do
    input = <<4, "aaa", 0, 10, "abcabcabc">>

    schema = [
      a: {:compact_string, @default_metadata},
      b: {:compact_string, %{is_nullable?: true}},
      c: {:compact_string, @default_metadata}
    ]

    assert {:ok, {response, <<>>}} = Deserializer.execute(input, schema)

    assert %{a: "aaa", b: nil, c: "abcabcabc"} = response
  end

  test "compact_array - simple" do
    input =
      <<3, 10::16-signed, 20::16-signed>> <>
        <<4, 2, "a", 2, "b", 2, "c">> <>
        <<0>>

    schema = [
      a: {{:compact_array, :int16}, @default_metadata},
      b: {{:compact_array, :compact_string}, @default_metadata},
      c: {{:compact_array, :string}, %{is_nullable?: true}}
    ]

    assert {:ok, {response, <<>>}} = Deserializer.execute(input, schema)

    assert %{a: [10, 20], b: ["a", "b", "c"], c: nil} = response
  end

  test "compact_array - nested" do
    input =
      <<3, 2, 10::16-signed, 3, 20::16-signed, 30::16-signed>> <>
        <<3, 4, 2, "a", 3, "bb", 4, "ccc", 40::32-signed, 3, 2, "d", 3, "ee", 50::32-signed>>

    schema = [
      a: {{:compact_array, {:compact_array, :int16}}, @default_metadata},
      b:
        {{:compact_array,
          [
            b_1: {
              {:compact_array, :compact_string},
              @default_metadata
            },
            b_2: {:int32, %{is_nullable?: false}}
          ]}, @default_metadata}
    ]

    assert {:ok, {response, <<>>}} = Deserializer.execute(input, schema)

    assert %{
             a: [[10], [20, 30]],
             b: [%{b_1: ["a", "bb", "ccc"], b_2: 40}, %{b_1: ["d", "ee"], b_2: 50}]
           } = response
  end

  test "unsigned_varint" do
    input = <<10, 120, 172, 2, 192, 132, 61>>

    schema = [
      a: {:unsigned_varint, @default_metadata},
      b: {:unsigned_varint, @default_metadata},
      c: {:unsigned_varint, @default_metadata},
      d: {:unsigned_varint, @default_metadata}
    ]

    assert {:ok, {response, <<>>}} = Deserializer.execute(input, schema)

    assert %{a: 10, b: 120, c: 300, d: 1_000_000} = response
  end

  test "varint" do
    input = <<19, 239, 1, 215, 4, 160, 156, 1>>

    schema = [
      a: {:varint, @default_metadata},
      b: {:varint, @default_metadata},
      c: {:varint, @default_metadata},
      d: {:varint, @default_metadata}
    ]

    assert {:ok, {%{a: -10, b: -120, c: -300, d: 10_000}, <<>>}} =
             Deserializer.execute(input, schema)
  end

  test "tag_buffer" do
    input = <<3, 0, 5, 4, "aaa", 2, 3, 123::16-signed, 3, 12, 11, "unkown tag">>

    schema = [
      tag_buffer:
        {:tag_buffer,
         %{
           0 => {{:a, :compact_string}, @default_metadata},
           1 => {{:b, :int16}, @default_metadata},
           2 => {{:c, :int16}, @default_metadata}
         }}
    ]

    assert {:ok, {response, <<>>}} = Deserializer.execute(input, schema)

    assert %{a: "aaa", c: 123} = response
  end

  test "empty tag_buffer" do
    input = <<0>>

    schema = [tag_buffer: {:tag_buffer, %{}}]

    assert {:ok, {response, <<>>}} = Deserializer.execute(input, schema)

    assert %{} = response
  end
end
