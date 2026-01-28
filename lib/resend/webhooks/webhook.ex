defmodule Resend.Webhooks.Webhook do
  @moduledoc """
  Resend Webhook struct.
  """

  alias Resend.Util

  @behaviour Resend.Castable

  @type t() :: %__MODULE__{
          id: String.t(),
          name: String.t() | nil,
          endpoint: String.t() | nil,
          events: list(String.t()) | nil,
          signing_secret: String.t() | nil,
          created_at: DateTime.t() | nil,
          updated_at: DateTime.t() | nil
        }

  @enforce_keys [:id]
  defstruct [
    :id,
    :name,
    :endpoint,
    :events,
    :signing_secret,
    :created_at,
    :updated_at
  ]

  @impl true
  def cast(map) do
    %__MODULE__{
      id: map["id"],
      name: map["name"],
      endpoint: map["endpoint"],
      events: map["events"],
      signing_secret: map["signing_secret"],
      created_at: Util.parse_iso8601(map["created_at"]),
      updated_at: Util.parse_iso8601(map["updated_at"])
    }
  end
end
