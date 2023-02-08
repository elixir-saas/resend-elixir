defmodule Resend.Email do
  @moduledoc """
  Send emails via Resend.
  """

  @behaviour Resend.Castable

  @type t() :: %__MODULE__{
          id: String.t(),
          from: String.t(),
          to: String.t()
        }

  defstruct [:id, :from, :to]

  @impl true
  def cast(map) do
    %__MODULE__{
      id: map["id"],
      from: map["from"],
      to: map["to"]
    }
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
  @spec send(Resend.confg(), map()) :: Resend.Client.response(t())
  def send(config \\ Resend.config(), opts) do
    Resend.Client.post(config, "/email", __MODULE__, %{
      subject: opts[:subject],
      to: opts[:to],
      from: opts[:from],
      cc: opts[:cc],
      bcc: opts[:bcc],
      reply_to: opts[:reply_to],
      html: opts[:html],
      text: opts[:text]
    })
  end
end
