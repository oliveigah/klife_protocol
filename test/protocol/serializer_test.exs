defmodule Klife.Protocol.SerializerTest do
  use ExUnit.Case

  alias Klife.Protocol.Serializer

  test "int16" do
    input = %{a: 31, b: 123, c: 4}
    schema = [a: :int16, b: :int16, c: :int16]
    assert <<31::16-signed, 123::16-signed, 4::16-signed>> = Serializer.execute(input, schema)
  end

  test "int32" do
    input = %{a: 31, b: 123, c: 4}
    schema = [a: :int32, b: :int32, c: :int32]
    assert <<31::32-signed, 123::32-signed, 4::32-signed>> = Serializer.execute(input, schema)
  end

  test "string" do
    input = %{a: "abc", b: "defgh", d: "ij"}
    schema = [a: :string, b: :string, c: :string, d: :string]

    [size_a, size_b, size_d] = [byte_size(input.a), byte_size(input.b), byte_size(input.d)]

    assert <<^size_a::16-signed>> <>
             "abc" <>
             <<^size_b::16-signed>> <>
             "defgh" <>
             <<-1::16-signed>> <>
             <<^size_d::16-signed>> <> "ij" = Serializer.execute(input, schema)
  end

  test "array - simple" do
    input = %{a: [10, 20], b: ["a", "b", "c"]}
    schema = [a: {:array, :int16}, b: {:array, :string}]

    size_a = byte_size("a")
    size_b = byte_size("b")
    size_c = byte_size("c")

    assert <<2::32-signed>> <>
             <<10::16-signed>> <>
             <<20::16-signed>> <>
             <<3::32-signed>> <>
             <<^size_a::16-signed>> <>
             "a" <>
             <<^size_b::16-signed>> <>
             "b" <>
             <<^size_c::16-signed>> <>
             "c" = Serializer.execute(input, schema)
  end

  test "array - nested" do
    input = %{
      a: [%{a_a: 10, a_b: 20}, %{a_a: 30, a_b: 40}],
      b: [
        %{
          b_a: [%{b_b: "a", b_c: 1}]
        },
        %{
          b_a: [%{b_b: "b", b_c: 2}, %{b_b: "c", b_c: 3}]
        }
      ],
      d: []
    }

    schema = [
      a: {:array, [a_a: :int16, a_b: :int32]},
      b: {:array, [b_a: {:array, [b_b: :string, b_c: :int16]}]},
      c: {:array, [c_a: :int16]},
      d: {:array, [d_a: :int16]}
    ]

    size_a = byte_size("a")
    size_b = byte_size("b")
    size_c = byte_size("c")

    assert <<2::32-signed>> <>
             <<10::16-signed>> <>
             <<20::32-signed>> <>
             <<30::16-signed>> <>
             <<40::32-signed>> <>
             <<2::32-signed>> <>
             <<1::32-signed>> <>
             <<^size_a::16-signed>> <>
             "a" <>
             <<1::16-signed>> <>
             <<2::32-signed>> <>
             <<^size_b::16-signed>> <>
             "b" <>
             <<2::16-signed>> <>
             <<^size_c::16-signed>> <>
             "c" <>
             <<3::16-signed>> <>
             <<-1::32-signed>> <>
             <<0::32-signed>> = Serializer.execute(input, schema)
  end
end
