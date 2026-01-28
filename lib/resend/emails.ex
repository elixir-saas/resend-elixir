defmodule Resend.Emails do
  @moduledoc """
  Send emails via Resend.
  """

  alias Resend.Emails.Email
  alias Resend.Emails.Attachment
  alias Resend.Emails.BatchResponse

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
    * `:tags` - List of tags to add to the email
    * `:scheduled_at` - Schedule the email to be sent at a specific time (ISO 8601 string)
    * `:topic_id` - The topic ID for subscription-based sending
    * `:template` - Template object with `:id` and optional `:variables` map for template-based emails

  You must include one or both of the `:html` and `:text` options, unless using a template.

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
      tags: opts[:tags],
      scheduled_at: opts[:scheduled_at],
      topic_id: opts[:topic_id],
      template: opts[:template]
    })
  end

  @doc """
  Sends a batch of emails (up to 100).

  Takes a list of email parameter maps, each with the same options as `send/2`.
  """
  @spec send_batch(list(map())) :: Resend.Client.response(BatchResponse.t())
  @spec send_batch(Resend.Client.t(), list(map())) :: Resend.Client.response(BatchResponse.t())
  def send_batch(client \\ Resend.client(), emails) when is_list(emails) do
    batch =
      Enum.map(emails, fn opts ->
        %{
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
          tags: opts[:tags],
          scheduled_at: opts[:scheduled_at],
          topic_id: opts[:topic_id],
          template: opts[:template]
        }
      end)

    Resend.Client.post(client, BatchResponse, "/emails/batch", batch)
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

  @doc """
  Lists all sent emails.
  """
  @spec list() :: Resend.Client.response(Resend.List.t(Email.t()))
  @spec list(Resend.Client.t()) :: Resend.Client.response(Resend.List.t(Email.t()))
  def list(client \\ Resend.client()) do
    Resend.Client.get(client, Resend.List.of(Email), "/emails")
  end

  @doc """
  Updates a scheduled email.

  ## Options

    * `:scheduled_at` - The new scheduled time (ISO 8601 string)

  """
  @spec update(String.t(), Keyword.t()) :: Resend.Client.response(Email.t())
  @spec update(Resend.Client.t(), String.t(), Keyword.t()) :: Resend.Client.response(Email.t())
  def update(client \\ Resend.client(), email_id, opts) do
    Resend.Client.patch(
      client,
      Email,
      "/emails/:id",
      %{
        scheduled_at: opts[:scheduled_at]
      },
      opts: [path_params: [id: email_id]]
    )
  end

  @doc """
  Cancels a scheduled email.
  """
  @spec cancel(String.t()) :: Resend.Client.response(Email.t())
  @spec cancel(Resend.Client.t(), String.t()) :: Resend.Client.response(Email.t())
  def cancel(client \\ Resend.client(), email_id) do
    Resend.Client.post(client, Email, "/emails/:id/cancel", %{},
      opts: [path_params: [id: email_id]]
    )
  end

  @doc """
  Lists all attachments for an email.
  """
  @spec list_attachments(String.t()) :: Resend.Client.response(Resend.List.t(Attachment.t()))
  @spec list_attachments(Resend.Client.t(), String.t()) ::
          Resend.Client.response(Resend.List.t(Attachment.t()))
  def list_attachments(client \\ Resend.client(), email_id) do
    Resend.Client.get(client, Resend.List.of(Attachment), "/emails/:id/attachments",
      opts: [path_params: [id: email_id]]
    )
  end

  @doc """
  Gets a specific attachment for an email.
  """
  @spec get_attachment(String.t(), String.t()) :: Resend.Client.response(Attachment.t())
  @spec get_attachment(Resend.Client.t(), String.t(), String.t()) ::
          Resend.Client.response(Attachment.t())
  def get_attachment(client \\ Resend.client(), email_id, attachment_id) do
    Resend.Client.get(client, Attachment, "/emails/:id/attachments/:attachment_id",
      opts: [path_params: [id: email_id, attachment_id: attachment_id]]
    )
  end
end
