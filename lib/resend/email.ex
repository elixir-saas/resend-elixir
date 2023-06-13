defmodule Resend.Email do
  @moduledoc """
  Send emails via Resend.
  """

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
      created_at: parse_iso8601(map["created_at"])
    }
  end

  defp parse_iso8601(nil), do: nil

  defp parse_iso8601(date_string) do
    {:ok, date_time, 0} = DateTime.from_iso8601(date_string)
    date_time
  end

  @doc """
  Sends an email given a map of parameters.

  Parameter options:

    * `:to` - Recipient email address (required)
    * `:from` - Sender email address (required)
    * `:cc` - Additional email addresses to copy, may be a single address or a list of addresses
    * `:bcc` - Additional email addresses to blind-copy, may be a single address or a list of addresses
    * `:reply_to` - Specify the email that recipients will reply to
    * `:subject` - Subject line of the email
    * `:html` - The HTML-formatted body of the email
    * `:text` - The text-formatted body of the email

  You are required to include one or both of the `:html` and `:text` options.
  """
  @spec send(map()) :: Resend.Client.response(t())
  @spec send(Resend.Client.t(), map()) :: Resend.Client.response(t())

  def send(client \\ Resend.client(), opts) do
    body = %{
      subject: opts[:subject],
      to: opts[:to],
      from: opts[:from],
      cc: opts[:cc],
      bcc: opts[:bcc],
      reply_to: opts[:reply_to],
      html: opts[:html],
      text: opts[:text]
    }

    Resend.Client.post(client, __MODULE__, "/emails", body, [])
  end

  @spec get(String.t()) :: Resend.Client.response(t())
  @spec get(Resend.Client.t(), String.t()) :: Resend.Client.response(t())
  def get(client \\ Resend.client(), email_id) do
    Resend.Client.get(client, __MODULE__, "/emails/:id",
      opts: [
        path_params: [id: email_id]
      ]
    )
  end
end
