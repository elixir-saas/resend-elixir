defmodule Resend.ReceivedEmails do
  @moduledoc """
  Manage received emails in Resend.
  """

  alias Resend.ReceivedEmails.ReceivedEmail
  alias Resend.Emails.Attachment

  @doc """
  Lists all received emails.
  """
  @spec list() :: Resend.Client.response(Resend.List.t(ReceivedEmail.t()))
  @spec list(Resend.Client.t()) :: Resend.Client.response(Resend.List.t(ReceivedEmail.t()))
  def list(client \\ Resend.client()) do
    Resend.Client.get(client, Resend.List.of(ReceivedEmail), "/received-emails")
  end

  @doc """
  Gets a received email by ID.
  """
  @spec get(String.t()) :: Resend.Client.response(ReceivedEmail.t())
  @spec get(Resend.Client.t(), String.t()) :: Resend.Client.response(ReceivedEmail.t())
  def get(client \\ Resend.client(), email_id) do
    Resend.Client.get(client, ReceivedEmail, "/received-emails/:id",
      opts: [path_params: [id: email_id]]
    )
  end

  @doc """
  Lists all attachments for a received email.
  """
  @spec list_attachments(String.t()) :: Resend.Client.response(Resend.List.t(Attachment.t()))
  @spec list_attachments(Resend.Client.t(), String.t()) ::
          Resend.Client.response(Resend.List.t(Attachment.t()))
  def list_attachments(client \\ Resend.client(), email_id) do
    Resend.Client.get(client, Resend.List.of(Attachment), "/received-emails/:id/attachments",
      opts: [path_params: [id: email_id]]
    )
  end

  @doc """
  Gets a specific attachment for a received email.
  """
  @spec get_attachment(String.t(), String.t()) :: Resend.Client.response(Attachment.t())
  @spec get_attachment(Resend.Client.t(), String.t(), String.t()) ::
          Resend.Client.response(Attachment.t())
  def get_attachment(client \\ Resend.client(), email_id, attachment_id) do
    Resend.Client.get(client, Attachment, "/received-emails/:id/attachments/:attachment_id",
      opts: [path_params: [id: email_id, attachment_id: attachment_id]]
    )
  end
end
