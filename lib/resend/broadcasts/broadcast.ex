defmodule Resend.Broadcasts.Broadcast do
  @moduledoc """
  Resend Broadcast struct.
  """

  alias Resend.Util

  @behaviour Resend.Castable

  @type t() :: %__MODULE__{
          id: String.t(),
          name: String.t() | nil,
          segment_id: String.t() | nil,
          from: String.t() | nil,
          subject: String.t() | nil,
          reply_to: list(String.t()) | nil,
          preview_text: String.t() | nil,
          status: String.t() | nil,
          created_at: DateTime.t() | nil,
          scheduled_at: DateTime.t() | nil,
          sent_at: DateTime.t() | nil
        }

  @enforce_keys [:id]
  defstruct [
    :id,
    :name,
    :segment_id,
    :from,
    :subject,
    :reply_to,
    :preview_text,
    :status,
    :created_at,
    :scheduled_at,
    :sent_at
  ]

  @impl true
  def cast(map) do
    %__MODULE__{
      id: map["id"],
      name: map["name"],
      segment_id: map["segment_id"],
      from: map["from"],
      subject: map["subject"],
      reply_to: map["reply_to"],
      preview_text: map["preview_text"],
      status: map["status"],
      created_at: Util.parse_iso8601(map["created_at"]),
      scheduled_at: Util.parse_iso8601(map["scheduled_at"]),
      sent_at: Util.parse_iso8601(map["sent_at"])
    }
  end
end
