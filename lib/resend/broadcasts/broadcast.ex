defmodule Resend.Broadcasts.Broadcast do
  @moduledoc """
  Resend Broadcast struct.

  Represents a broadcast email campaign that can be sent to an audience.
  Broadcasts support scheduling, drafts, and rich content including HTML and attachments.
  """

  alias Resend.Util

  @behaviour Resend.Castable

  @type t() :: %__MODULE__{
          id: String.t(),
          audience_id: String.t() | nil,
          name: String.t() | nil,
          from: String.t() | nil,
          subject: String.t() | nil,
          reply_to: String.t() | list(String.t()) | nil,
          preview_text: String.t() | nil,
          status: String.t() | nil,
          created_at: DateTime.t() | nil,
          scheduled_at: DateTime.t() | nil,
          sent_at: DateTime.t() | nil,
          deleted: boolean() | nil
        }

  @enforce_keys [:id]
  defstruct [
    :id,
    :audience_id,
    :name,
    :from,
    :subject,
    :reply_to,
    :preview_text,
    :status,
    :created_at,
    :scheduled_at,
    :sent_at,
    :deleted
  ]

  @doc """
  Casts a raw map from the API response into a Broadcast struct.

  This function is used internally by the Castable protocol to convert
  JSON responses from the Resend API into properly typed Elixir structs.

  Handles the reply_to field which can be either a string or list of strings.
  """
  @impl true
  @spec cast(map()) :: t()
  def cast(map) do
    %__MODULE__{
      id: map["id"],
      audience_id: map["audience_id"],
      name: map["name"],
      from: map["from"],
      subject: map["subject"],
      reply_to: map["reply_to"],
      preview_text: map["preview_text"],
      status: map["status"],
      created_at: Util.parse_iso8601(map["created_at"]),
      scheduled_at: Util.parse_iso8601(map["scheduled_at"]),
      sent_at: Util.parse_iso8601(map["sent_at"]),
      deleted: map["deleted"]
    }
  end
end
