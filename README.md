# Zipper

**TODO: Add description**

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `zipper` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:zipper, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/zipper>.

## Description

https://www.youtube.com/watch?v=6c4DJX2Xr3k

An Elixir implementation of a clojure zipper

## Test

z = Zipper.new
z = Zipper.insert(z, Zipper.make_node(%{name: "root"}))
z = Zipper.append_child(z, Zipper.make_node(%{name: "koko"}))
z = Zipper.append_child(z, Zipper.make_node(%{name: "kiki"}))

z |> Zipper.traverse() |> Enum.map(& &1.attrs.name)
["root", "koko", "kiki"]
