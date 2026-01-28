defmodule Resend.Segments.Segment do
  @moduledoc """
  Resend Segment struct.
  """

  alias Resend.Util

  @behaviour Resend.Castable

  @type t() :: %__MODULE__{
          id: String.t(),
          name: String.t() | nil,
          audience_id: String.t() | nil,
          created_at: DateTime.t() | nil,
          updated_at: DateTime.t() | nil
        }

  @enforce_keys [:id]
  defstruct [
    :id,
    :name,
    :audience_id,
    :created_at,
    :updated_at
  ]

  @impl true
  def cast(map) do
    %__MODULE__{
      id: map["id"],
      name: map["name"],
      audience_id: map["audience_id"],
      created_at: Util.parse_iso8601(map["created_at"]),
      updated_at: Util.parse_iso8601(map["updated_at"])
    }
  end
end
