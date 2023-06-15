defmodule Resend.Empty do
  @behaviour Resend.Castable

  @type t() :: %__MODULE__{}

  defstruct []

  @impl true
  def cast(_map), do: %__MODULE__{}
end
