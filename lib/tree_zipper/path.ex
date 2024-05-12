defmodule TreeZipper.Path do
  defstruct [
    l: [],  # left siblings
    r: [],  # right siblings
    pnodes: [], # previous nodes
    ppath: [],  # previous location path
    # changed?: false
  ]
end
