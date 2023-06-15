defmodule Resend.Empty do
  @moduledoc """
  Empty response.
  """

  @behaviour Resend.Castable

  @type t() :: %__MODULE__{}

  defstruct []

  @impl true
  def cast(_map), do: %__MODULE__{}
end
