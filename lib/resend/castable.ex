defmodule Resend.Castable do
  @type generic_map :: %{String.t() => any()}

  @callback cast(generic_map() | nil) :: struct() | nil

  @spec cast(module() | :raw, generic_map() | nil) :: struct() | generic_map() | nil
  def cast(_implementation, nil) do
    nil
  end

  def cast(:raw, generic_map) do
    generic_map
  end

  def cast(implementation, generic_map) when is_map(generic_map) do
    implementation.cast(generic_map)
  end

  @spec cast_list(module(), [generic_map()] | nil) :: [struct()] | nil
  def cast_list(_implementation, nil) do
    nil
  end

  def cast_list(implementation, list_of_generic_maps) when is_list(list_of_generic_maps) do
    Enum.map(list_of_generic_maps, &cast(implementation, &1))
  end
end
