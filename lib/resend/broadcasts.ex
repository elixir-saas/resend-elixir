defmodule Resend.Broadcasts do
  @moduledoc """
  Manage broadcasts in Resend.
  """

  alias Resend.Broadcasts.Broadcast

  @doc """
  Creates a new broadcast.

  ## Options

    * `:name` - The name of the broadcast (required)
    * `:segment_id` - The segment ID to send to (required)
    * `:from` - The sender email address (required)
    * `:subject` - The email subject (required)
    * `:reply_to` - Reply-to email addresses
    * `:html` - The HTML content
    * `:text` - The plain text content
    * `:preview_text` - Preview text for email clients
    * `:topic_id` - Scope broadcast to a specific topic

  """
  @spec create(Keyword.t()) :: Resend.Client.response(Broadcast.t())
  @spec create(Resend.Client.t(), Keyword.t()) :: Resend.Client.response(Broadcast.t())
  def create(client \\ Resend.client(), opts) do
    Resend.Client.post(client, Broadcast, "/broadcasts", %{
      name: opts[:name],
      segment_id: opts[:segment_id],
      from: opts[:from],
      subject: opts[:subject],
      reply_to: opts[:reply_to],
      html: opts[:html],
      text: opts[:text],
      preview_text: opts[:preview_text],
      topic_id: opts[:topic_id]
    })
  end

  @doc """
  Lists all broadcasts.
  """
  @spec list() :: Resend.Client.response(Resend.List.t(Broadcast.t()))
  @spec list(Resend.Client.t()) :: Resend.Client.response(Resend.List.t(Broadcast.t()))
  def list(client \\ Resend.client()) do
    Resend.Client.get(client, Resend.List.of(Broadcast), "/broadcasts")
  end

  @doc """
  Gets a broadcast by ID.
  """
  @spec get(String.t()) :: Resend.Client.response(Broadcast.t())
  @spec get(Resend.Client.t(), String.t()) :: Resend.Client.response(Broadcast.t())
  def get(client \\ Resend.client(), broadcast_id) do
    Resend.Client.get(client, Broadcast, "/broadcasts/:id",
      opts: [path_params: [id: broadcast_id]]
    )
  end

  @doc """
  Updates a broadcast.

  ## Options

    * `:name` - The name of the broadcast
    * `:segment_id` - The segment ID
    * `:from` - The sender email address
    * `:subject` - The email subject
    * `:reply_to` - Reply-to email addresses
    * `:html` - The HTML content
    * `:text` - The plain text content
    * `:preview_text` - Preview text for email clients
    * `:topic_id` - Scope broadcast to a specific topic

  """
  @spec update(String.t(), Keyword.t()) :: Resend.Client.response(Broadcast.t())
  @spec update(Resend.Client.t(), String.t(), Keyword.t()) ::
          Resend.Client.response(Broadcast.t())
  def update(client \\ Resend.client(), broadcast_id, opts) do
    Resend.Client.patch(
      client,
      Broadcast,
      "/broadcasts/:id",
      %{
        name: opts[:name],
        segment_id: opts[:segment_id],
        from: opts[:from],
        subject: opts[:subject],
        reply_to: opts[:reply_to],
        html: opts[:html],
        text: opts[:text],
        preview_text: opts[:preview_text],
        topic_id: opts[:topic_id]
      },
      opts: [path_params: [id: broadcast_id]]
    )
  end

  @doc """
  Removes a broadcast.
  """
  @spec remove(String.t()) :: Resend.Client.response(Resend.Empty.t())
  @spec remove(Resend.Client.t(), String.t()) :: Resend.Client.response(Resend.Empty.t())
  def remove(client \\ Resend.client(), broadcast_id) do
    Resend.Client.delete(client, Resend.Empty, "/broadcasts/:id", %{},
      opts: [path_params: [id: broadcast_id]]
    )
  end

  @doc """
  Sends a broadcast.

  ## Options

    * `:scheduled_at` - Optional datetime to schedule the broadcast

  """
  @spec send(String.t()) :: Resend.Client.response(Broadcast.t())
  @spec send(String.t(), Keyword.t()) :: Resend.Client.response(Broadcast.t())
  @spec send(Resend.Client.t(), String.t()) :: Resend.Client.response(Broadcast.t())
  @spec send(Resend.Client.t(), String.t(), Keyword.t()) :: Resend.Client.response(Broadcast.t())
  def send(client \\ Resend.client(), broadcast_id, opts \\ []) do
    Resend.Client.post(
      client,
      Broadcast,
      "/broadcasts/:id/send",
      %{
        scheduled_at: opts[:scheduled_at]
      },
      opts: [path_params: [id: broadcast_id]]
    )
  end
end
