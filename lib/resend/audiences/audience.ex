defmodule Resend.Audiences.Audience do
  @moduledoc """
  Resend Audience struct.

  Represents an audience, which is a group of contacts that you can send broadcasts to.
  Each audience has a unique ID that is used to reference it in other API calls.
  """

  alias Resend.Util

  @behaviour Resend.Castable

  @type t() :: %__MODULE__{
          id: String.t(),
          name: String.t() | nil,
          created_at: DateTime.t() | nil,
          deleted: boolean() | nil
        }

  @enforce_keys [:id]
  defstruct [
    :id,
    :name,
    :created_at,
    :deleted
  ]

  @doc """
  Casts a raw map from the API response into an Audience struct.

  This function is used internally by the Castable protocol to convert
  JSON responses from the Resend API into properly typed Elixir structs.
  """
  @impl true
  @spec cast(map()) :: t()
  def cast(map) do
    %__MODULE__{
      id: map["id"],
      name: map["name"],
      created_at: Util.parse_iso8601(map["created_at"]),
      deleted: map["deleted"]
    }
  end
end
