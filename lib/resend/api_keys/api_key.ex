defmodule Resend.ApiKeys.ApiKey do
  @moduledoc """
  Resend API Key struct.
  """

  alias Resend.Util

  @behaviour Resend.Castable

  @type t() :: %__MODULE__{
          id: String.t(),
          name: String.t() | nil,
          token: String.t() | nil,
          created_at: DateTime.t() | nil
        }

  @enforce_keys [:id]
  defstruct [
    :id,
    :name,
    :token,
    :created_at
  ]

  @impl true
  def cast(map) do
    %__MODULE__{
      id: map["id"],
      name: map["name"],
      token: map["token"],
      created_at: Util.parse_iso8601(map["created_at"])
    }
  end
end
