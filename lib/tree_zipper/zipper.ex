defmodule TreeZipper.Zipper do
  @moduledoc """
  Documentation for `Zipper`.
  """

  alias TreeZipper.{Node, Path}

  defstruct [
    node: nil,      # The focus node
    path: %Path{},  # The location path
  ]

  @doc """
  Returns a new zipper
  """
  def new, do: %__MODULE__{}

  @doc """
  Return a tree from the zipper
  """
  def to_tree(nil), do: nil
  def to_tree(%__MODULE__{node: node} = zipper) do
    %{node | children: do_build_children(zipper)}
  end

  defp children_zippers(zipper) do
    # Create children zippers
    first = down(zipper)
    do_children_zippers(first, [])
  end

  defp do_children_zippers(nil, acc), do: Enum.reverse(acc)
  defp do_children_zippers(zipper, acc) do
    right = right(zipper)
    do_children_zippers(right, [zipper | acc])
  end

  defp do_build_children(zipper) do
    if is_branch?(zipper) do
      zipper
      |> children_zippers()
      # Map children zippers with a recursive task builder
      |> Enum.map(fn %{node: node} = child ->
        %{node | children: do_build_children(child)}
      end)
    else
      []
    end
  end

  @doc """
  Return a zipper from a tree
  """
  def from_tree(tree) do
    %__MODULE__{node: tree}
  end

  @doc """
  Traverse the zipper
  """
  def traverse(nil), do: []
  def traverse(%__MODULE__{node: node} = zipper) do
    do_traverse(zipper, [node])
  end

  defp do_traverse(zipper, acc) do
    if next_node = next(zipper) do
      %{node: node} = next_node
      acc = [node | acc]
      do_traverse(next_node, acc)
    else
      Enum.reverse(acc)
    end
  end

  # Predicates

  def is_branch?(%__MODULE__{node: %{children: []}} = _zipper), do: false
  def is_branch?(%__MODULE__{} = _zipper), do: true
  def is_branch?(_), do: false

  def is_leaf?(%__MODULE__{node: %{children: []}} = _zipper), do: true
  def is_leaf?(%__MODULE__{} = _zipper), do: false
  def is_leaf?(_), do: false

  def has_parent?(%__MODULE__{path: %{pnodes: []}} = _zipper), do: false
  def has_parent?(%__MODULE__{} = _zipper), do: true
  def has_parent?(_), do: false

  def has_children?(%__MODULE__{} = zipper), do: is_branch?(zipper)

  def has_next_parent?(%__MODULE__{path: %{ppath: []}} = _zipper), do: false
  def has_next_parent?(%__MODULE__{path: %{ppath: [r: []]}} = _zipper), do: false
  def has_next_parent?(%__MODULE__{} = _zipper), do: true
  def has_next_parent?(_), do: false

  def has_previous_parent?(%__MODULE__{path: %{ppath: []}} = _zipper), do: false
  def has_previous_parent?(%__MODULE__{path: %{ppath: [l: []]}} = _zipper), do: false
  def has_previous_parent?(%__MODULE__{} = _zipper), do: true
  def has_previous_parent?(_), do: false

  def has_left?(%__MODULE__{path: %{l: []}} = _zipper), do: false
  def has_left?(%__MODULE__{} = _zipper), do: true
  def has_left?(_), do: false

  def has_right?(%__MODULE__{path: %{r: []}} = _zipper), do: false
  def has_right?(%__MODULE__{} = _zipper), do: true
  def has_right?(_), do: false

  # Editing

  def replace(%__MODULE__{} = zipper, node) do
    %{zipper | node: node}
  end

  def make_node(attrs \\ %{}) do
    %Node{attrs: attrs}
  end

  def append_child(%__MODULE__{node: node} = zipper, child) do
    %{zipper | node: %{node | children: node.children ++ [child]}}
  end

  def insert(%__MODULE__{} = zipper, node) do
    %{zipper | node: node}
  end

  def insert_left(%__MODULE__{path: %{l: l} = path} = zipper, node) do
    %{zipper | path: %{path | l: [node | l]}}
  end

  def insert_right(%__MODULE__{path: %{r: r} = path} = zipper, node) do
    %{zipper | path: %{path | r: [node | r]}}
  end

  def edit(%__MODULE__{node: node} = zipper, updater) do
    %{zipper | node: updater.(node)}
  end

  # Movement

  def up(%__MODULE__{} = zipper) do
    if has_parent?(zipper) do
      %{path: path} = zipper
      %{pnodes: pnodes, ppath: ppath} = path
      [new_node | _] = pnodes
      [new_path | _] = ppath
      %{zipper | node: new_node, path: new_path}
    end
  end

  def root(%__MODULE__{} = zipper) do
    if has_parent?(zipper) do
      %{path: path} = zipper
      %{pnodes: pnodes, ppath: ppath} = path
      [new_node | _] = Enum.reverse(pnodes)
      [new_path | _] = Enum.reverse(ppath)
      %{zipper | node: new_node, path: new_path}
    end
  end

  def down(%__MODULE__{} = zipper) do
    if is_branch?(zipper) do
      %{node: node, path: %{pnodes: pnodes, ppath: ppath} = path} = zipper
      %{children: [new_node | new_right]} = node
      new_path = %{l: [], r: new_right, pnodes: [node | pnodes], ppath: [path | ppath]}
      %{zipper | node: new_node, path: new_path}
    end
  end

  def left(%__MODULE__{} = zipper) do
    if has_left?(zipper) do
      %{node: node, path: %{l: left, r: right} = path} = zipper
      [new_node | new_left] = left
      %{zipper | node: new_node, path: %{path | l: new_left, r: [node | right]}}
    end
  end

  def left_most(%__MODULE__{} = zipper) do
    if has_left?(zipper) do
      %{node: node, path: %{l: left, r: right} = path} = zipper
      [new_node | reversed_left] = Enum.reverse(left)
      new_right = reversed_left ++ [node] ++ right
      %{zipper | node: new_node, path: %{path | l: [], r: new_right}}
    end
  end

  def previous(%__MODULE__{} = zipper) do
    cond do
      has_left?(zipper) -> left(zipper)
      previous = previous_parent_last_child(zipper) -> previous
      previous_level = previous_level_last_child(zipper) -> previous_level
      has_parent?(zipper) -> up(zipper)
      true -> nil
    end
  end

  def right(%__MODULE__{} = zipper) do
    if has_right?(zipper) do
      %{node: node, path: %{l: left, r: right}} = zipper
      [new_node | new_right] = right
      %{zipper | node: new_node, path: %{zipper.path | l: [node | left], r: new_right}}
    end
  end

  def right_most(%__MODULE__{} = zipper) do
    if has_right?(zipper) do
      %{node: node, path: %{l: left, r: right} = path} = zipper
      [new_node | reversed_right] = Enum.reverse(right)
      new_left = left ++ [node] ++ Enum.reverse(reversed_right)
      %{zipper | node: new_node, path: %{path | l: new_left, r: []}}
    end
  end

  def next(%__MODULE__{} = zipper) do
    cond do
      has_right?(zipper) -> right(zipper)
      next = next_parent_first_child(zipper) -> next
      next_level = next_level_first_child(zipper) -> next_level
      is_branch?(zipper) -> down(zipper)
      true -> nil
    end
  end

  defp next_parent_first_child(zipper) do
    if has_next_parent?(zipper) do
      zipper
      |> up()
      |> right()
      |> do_next_child()
    end
  end

  defp previous_parent_last_child(zipper) do
    if has_next_parent?(zipper) do
      zipper
      |> up()
      |> left()
      |> do_previous_child()
    end
  end

  defp next_level_first_child(zipper) do
    if has_previous_parent?(zipper) do
      zipper
      |> up()
      |> left_most()
      |> do_next_child()
      # Twice!
      |> do_next_child()
    else
      if has_left?(zipper) do
        zipper
        |> left_most()
        |> do_next_child()
      end
    end
  end

  defp previous_level_last_child(zipper) do
    if has_previous_parent?(zipper) do
      zipper
      |> up()
      |> right_most()
      |> do_previous_child()
      # Twice!
      |> do_previous_child()
    else
      if has_right?(zipper) do
        zipper
        |> right_most()
        |> do_previous_child()
      end
    end
  end

  defp do_next_child(zipper) do
    cond do
      is_branch?(zipper) ->
        down(zipper)
      has_right?(zipper) ->
        zipper
        |> right()
        |> do_next_child()
      true ->
        nil
    end
  end

  defp do_previous_child(zipper) do
    cond do
      is_branch?(zipper) ->
        new_zipper = down(zipper)
        if has_right?(new_zipper), do: right_most(new_zipper), else: new_zipper

      has_left?(zipper) ->
        zipper
        |> left()
        |> do_previous_child()
      true ->
        nil
    end
  end
end
