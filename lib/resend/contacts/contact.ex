defmodule Resend.Contacts.Contact do
  @moduledoc """
  Resend Contact struct.

  Represents an individual contact within an audience. Contacts have email addresses
  and can have additional metadata like names and subscription status.
  """

  alias Resend.Util

  @behaviour Resend.Castable

  @type t() :: %__MODULE__{
          id: String.t(),
          email: String.t() | nil,
          first_name: String.t() | nil,
          last_name: String.t() | nil,
          created_at: DateTime.t() | nil,
          unsubscribed: boolean() | nil,
          deleted: boolean() | nil
        }

  @enforce_keys [:id]
  defstruct [
    :id,
    :email,
    :first_name,
    :last_name,
    :created_at,
    :unsubscribed,
    :deleted
  ]

  @doc """
  Casts a raw map from the API response into a Contact struct.

  This function is used internally by the Castable protocol to convert
  JSON responses from the Resend API into properly typed Elixir structs.
  """
  @impl true
  @spec cast(map()) :: t()
  def cast(map) do
    %__MODULE__{
      id: map["id"] || map["contact"],
      email: map["email"],
      first_name: map["first_name"],
      last_name: map["last_name"],
      created_at: Util.parse_iso8601(map["created_at"]),
      unsubscribed: map["unsubscribed"],
      deleted: map["deleted"]
    }
  end
end
