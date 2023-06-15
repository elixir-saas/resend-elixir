defmodule Resend.Emails.Email do
  @moduledoc """
  Resend Email struct.
  """

  alias Resend.Util

  @behaviour Resend.Castable

  @type t() :: %__MODULE__{
          id: String.t(),
          from: String.t() | nil,
          to: list(String.t()) | nil,
          bcc: list(String.t()) | nil,
          cc: list(String.t()) | nil,
          reply_to: String.t() | nil,
          subject: String.t() | nil,
          text: String.t() | nil,
          html: String.t() | nil,
          last_event: String.t() | nil,
          created_at: DateTime.t() | nil
        }

  @enforce_keys [:id]
  defstruct [
    :id,
    :from,
    :to,
    :bcc,
    :cc,
    :reply_to,
    :subject,
    :text,
    :html,
    :last_event,
    :created_at
  ]

  @impl true
  def cast(map) do
    %__MODULE__{
      id: map["id"],
      from: map["from"],
      to: map["to"],
      bcc: map["bcc"],
      cc: map["cc"],
      reply_to: map["reply_to"],
      subject: map["subject"],
      text: map["text"],
      html: map["html"],
      last_event: map["last_event"],
      created_at: Util.parse_iso8601(map["created_at"])
    }
  end
end
