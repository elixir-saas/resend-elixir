defmodule Resend.Emails.Tag do
  @moduledoc """
  Resend Email Tag struct.
  """

  @behaviour Resend.Castable
  @derive Jason.Encoder

  @type t() :: %__MODULE__{
          name: String.t(),
          value: String.t() | nil
        }

  @enforce_keys [:name]
  defstruct [
    :name,
    :value
  ]

  @impl true
  def cast(map) do
    %__MODULE__{
      name: map["name"],
      value: map["value"]
    }
  end
end
