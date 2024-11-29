defmodule Resend.Emails do
  @moduledoc """
  Send emails via Resend.
  """

  alias Resend.Emails.Email

  @doc """
  Sends an email given a map of parameters.

  Parameter options:

    * `:to` - Recipient email address (required)
    * `:from` - Sender email address (required)
    * `:cc` - Additional email addresses to copy, may be a single address or a list of addresses
    * `:bcc` - Additional email addresses to blind-copy, may be a single address or a list of addresses
    * `:reply_to` - Specify the email that recipients will reply to
    * `:subject` - Subject line of the email
    * `:headers` - Map of headers to add to the email with corresponding string values
    * `:html` - The HTML-formatted body of the email
    * `:text` - The text-formatted body of the email
    * `:attachments` - List of attachments to include in the email

  You must include one or both of the `:html` and `:text` options.

  """
  @spec send(map()) :: Resend.Client.response(Email.t())
  @spec send(Resend.Client.t(), map()) :: Resend.Client.response(Email.t())
  def send(client \\ Resend.client(), opts) do
    Resend.Client.post(client, Email, "/emails", %{
      subject: opts[:subject],
      to: opts[:to],
      from: opts[:from],
      cc: opts[:cc],
      bcc: opts[:bcc],
      reply_to: opts[:reply_to],
      headers: opts[:headers],
      html: opts[:html],
      text: opts[:text],
      attachments: opts[:attachments],
      scheduled_at: opts[:scheduled_at]
    })
  end

  @doc """
  Gets an email given an ID.

  """
  @spec get(String.t()) :: Resend.Client.response(Email.t())
  @spec get(Resend.Client.t(), String.t()) :: Resend.Client.response(Email.t())
  def get(client \\ Resend.client(), email_id) do
    Resend.Client.get(client, Email, "/emails/:id",
      opts: [
        path_params: [id: email_id]
      ]
    )
  end
end
