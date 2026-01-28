defmodule Resend.ContactProperties.ContactProperty do
  @moduledoc """
  Resend Contact Property struct.
  """

  alias Resend.Util

  @behaviour Resend.Castable

  @type t() :: %__MODULE__{
          id: String.t(),
          key: String.t() | nil,
          fallback_value: String.t() | nil,
          type: String.t() | nil,
          created_at: DateTime.t() | nil,
          updated_at: DateTime.t() | nil
        }

  @enforce_keys [:id]
  defstruct [
    :id,
    :key,
    :fallback_value,
    :type,
    :created_at,
    :updated_at
  ]

  @impl true
  def cast(map) do
    %__MODULE__{
      id: map["id"],
      key: map["key"],
      fallback_value: map["fallback_value"],
      type: map["type"],
      created_at: Util.parse_iso8601(map["created_at"]),
      updated_at: Util.parse_iso8601(map["updated_at"])
    }
  end
end
