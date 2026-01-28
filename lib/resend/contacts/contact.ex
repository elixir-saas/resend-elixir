defmodule Resend.Contacts.Contact do
  @moduledoc """
  Resend Contact struct.
  """

  alias Resend.Util

  @behaviour Resend.Castable

  @type t() :: %__MODULE__{
          id: String.t(),
          email: String.t() | nil,
          first_name: String.t() | nil,
          last_name: String.t() | nil,
          unsubscribed: boolean() | nil,
          properties: map() | nil,
          created_at: DateTime.t() | nil,
          updated_at: DateTime.t() | nil
        }

  @enforce_keys [:id]
  defstruct [
    :id,
    :email,
    :first_name,
    :last_name,
    :unsubscribed,
    :properties,
    :created_at,
    :updated_at
  ]

  @impl true
  def cast(map) do
    %__MODULE__{
      id: map["id"],
      email: map["email"],
      first_name: map["first_name"],
      last_name: map["last_name"],
      unsubscribed: map["unsubscribed"],
      properties: map["properties"],
      created_at: Util.parse_iso8601(map["created_at"]),
      updated_at: Util.parse_iso8601(map["updated_at"])
    }
  end
end
