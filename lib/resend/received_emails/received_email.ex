defmodule Resend.ReceivedEmails.ReceivedEmail do
  @moduledoc """
  Resend Received Email struct.
  """

  alias Resend.Util
  alias Resend.Castable
  alias Resend.Emails.Attachment

  @behaviour Resend.Castable

  @type t() :: %__MODULE__{
          id: String.t(),
          from: String.t() | nil,
          to: list(String.t()) | nil,
          cc: list(String.t()) | nil,
          bcc: list(String.t()) | nil,
          subject: String.t() | nil,
          text: String.t() | nil,
          html: String.t() | nil,
          attachments: list(Attachment.t()) | nil,
          created_at: DateTime.t() | nil
        }

  @enforce_keys [:id]
  defstruct [
    :id,
    :from,
    :to,
    :cc,
    :bcc,
    :subject,
    :text,
    :html,
    :attachments,
    :created_at
  ]

  @impl true
  def cast(map) do
    %__MODULE__{
      id: map["id"],
      from: map["from"],
      to: map["to"],
      cc: map["cc"],
      bcc: map["bcc"],
      subject: map["subject"],
      text: map["text"],
      html: map["html"],
      attachments: cast_attachments(map["attachments"]),
      created_at: Util.parse_iso8601(map["created_at"])
    }
  end

  defp cast_attachments(nil), do: nil
  defp cast_attachments(attachments), do: Castable.cast_list(Attachment, attachments)
end
