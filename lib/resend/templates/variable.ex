defmodule Resend.Templates.Variable do
  @moduledoc """
  Resend Template Variable struct.
  """

  @behaviour Resend.Castable

  @type t() :: %__MODULE__{
          name: String.t(),
          default_value: String.t() | nil,
          required: boolean() | nil
        }

  @enforce_keys [:name]
  defstruct [
    :name,
    :default_value,
    :required
  ]

  @impl true
  def cast(map) do
    %__MODULE__{
      name: map["name"],
      default_value: map["default_value"],
      required: map["required"]
    }
  end
end
