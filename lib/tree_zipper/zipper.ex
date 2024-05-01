defmodule TreeZipper.Zipper do
  @moduledoc """
  Documentation for `Zipper`.
  """

  alias TreeZipper.Node

  defstruct [
    focus: nil,
    l: [],
    r: [],
    pnodes: [],
    ppath: [],
    changed?: false
  ]

  def branch?(%{children: []} = _node), do: false
  def branch?(_node), do: true

  # Editing

  def replace do

  end

  def make_node(name) do
    %Node{name: name}
  end

  def append_child(node, child) do
    %{node | children: [child | node.children]}
  end

  def insert do

  end

  def insert_left do

  end

  def insert_right do

  end

  def edit do

  end

  def remove do

  end

  # Movement

  def up do

  end

  def root do

  end

  def down do

  end

  def left do

  end

  def left_most do

  end

  def previous do

  end

  def right do

  end

  def right_most do

  end

  def next do

  end
end
