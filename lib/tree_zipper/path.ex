defmodule TreeZipper.Path do
  defstruct [
    l: [],
    r: [],
    pnodes: [],
    ppath: [],
    changed?: false
  ]
end
