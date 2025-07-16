defmodule Resend.Broadcasts do
  @moduledoc """
  Manage broadcasts in Resend.

  Broadcasts are email campaigns that can be sent to an entire audience. This module
  provides functions to create, list, retrieve, update, send, and delete broadcasts.

  ## Examples

      # Create a new broadcast
      {:ok, broadcast} = Resend.Broadcasts.create(
        audience_id: "78261eea-8f8b-4381-83c6-79fa7120f1cf",
        name: "Monthly Newsletter",
        from: "newsletter@example.com",
        subject: "Our Monthly Update"
      )

      # List all broadcasts
      {:ok, broadcasts} = Resend.Broadcasts.list()

      # Get a specific broadcast
      {:ok, broadcast} = Resend.Broadcasts.get("b6d24b8e-af0b-4c3c-be0c-359bbd97381e")

      # Update a broadcast
      {:ok, broadcast} = Resend.Broadcasts.update("b6d24b8e-af0b-4c3c-be0c-359bbd97381e",
        subject: "Updated Subject Line"
      )

      # Send a broadcast immediately
      {:ok, broadcast} = Resend.Broadcasts.send("b6d24b8e-af0b-4c3c-be0c-359bbd97381e")

      # Schedule a broadcast for later
      {:ok, broadcast} = Resend.Broadcasts.send("b6d24b8e-af0b-4c3c-be0c-359bbd97381e",
        scheduled_at: ~U[2024-12-25 09:00:00Z]
      )

      # Remove a broadcast
      {:ok, removed_broadcast} = Resend.Broadcasts.remove("b6d24b8e-af0b-4c3c-be0c-359bbd97381e")
  """

  alias Resend.Broadcasts.Broadcast

  @doc """
  Creates a new broadcast.

  ## Parameters

    * `:audience_id` - The ID of the audience to send to (required)
    * `:name` - The name of the broadcast (required)
    * `:from` - The sender email address (required)
    * `:subject` - The subject line of the broadcast (required)
    * `:reply_to` - The reply-to email address(es). Can be a single string or list of strings (optional)
    * `:preview_text` - The preview text that appears in email clients (optional)
    * `:html` - The HTML content of the broadcast (optional)
    * `:text` - The plain text content of the broadcast (optional)
    * `:headers` - Map of custom headers to include (optional)
    * `:attachments` - List of attachments to include (optional)
    * `:tags` - List of tags for analytics (optional)

  ## Examples

      iex> Resend.Broadcasts.create(
      ...>   audience_id: "78261eea-8f8b-4381-83c6-79fa7120f1cf",
      ...>   name: "Welcome Campaign",
      ...>   from: "hello@example.com",
      ...>   subject: "Welcome to our newsletter!",
      ...>   html: "<p>Thank you for subscribing!</p>"
      ...> )
      {:ok, %Resend.Broadcasts.Broadcast{id: "b6d24b8e-af0b-4c3c-be0c-359bbd97381e", status: "draft"}}

      iex> Resend.Broadcasts.create(
      ...>   audience_id: "78261eea-8f8b-4381-83c6-79fa7120f1cf",
      ...>   name: "Newsletter",
      ...>   from: "news@example.com",
      ...>   subject: "Monthly Update",
      ...>   reply_to: ["support@example.com", "help@example.com"],
      ...>   preview_text: "Check out our latest updates...",
      ...>   html: "<h1>Newsletter</h1>"
      ...> )
      {:ok, %Resend.Broadcasts.Broadcast{id: "b6d24b8e-af0b-4c3c-be0c-359bbd97381e"}}

  """
  @spec create(Keyword.t()) :: Resend.Client.response(Broadcast.t())
  @spec create(Resend.Client.t(), Keyword.t()) :: Resend.Client.response(Broadcast.t())
  def create(client \\ Resend.client(), opts) do
    Resend.Client.post(client, Broadcast, "/broadcasts", %{
      audience_id: opts[:audience_id],
      name: opts[:name],
      from: opts[:from],
      subject: opts[:subject],
      reply_to: opts[:reply_to],
      preview_text: opts[:preview_text],
      html: opts[:html],
      text: opts[:text],
      headers: opts[:headers],
      attachments: opts[:attachments],
      tags: opts[:tags]
    })
  end

  @doc """
  Lists all broadcasts in your account.

  ## Examples

      iex> Resend.Broadcasts.list()
      {:ok, %Resend.List{data: [%Resend.Broadcasts.Broadcast{id: "b6d24b8e-af0b-4c3c-be0c-359bbd97381e"}]}}

  """
  @spec list() :: Resend.Client.response(Resend.List.t(Broadcast.t()))
  @spec list(Resend.Client.t()) :: Resend.Client.response(Resend.List.t(Broadcast.t()))
  def list(client \\ Resend.client()) do
    Resend.Client.get(client, Resend.List.of(Broadcast), "/broadcasts")
  end

  @doc """
  Gets details of a specific broadcast by its ID.

  ## Parameters

    * `broadcast_id` - The Broadcast ID (required)

  ## Examples

      iex> Resend.Broadcasts.get("b6d24b8e-af0b-4c3c-be0c-359bbd97381e")
      {:ok, %Resend.Broadcasts.Broadcast{id: "b6d24b8e-af0b-4c3c-be0c-359bbd97381e", name: "Monthly Newsletter"}}

      iex> Resend.Broadcasts.get("non-existent-id")
      {:error, %Resend.Error{message: "Broadcast not found"}}

  """
  @spec get(String.t()) :: Resend.Client.response(Broadcast.t())
  @spec get(Resend.Client.t(), String.t()) :: Resend.Client.response(Broadcast.t())
  def get(client \\ Resend.client(), broadcast_id) do
    Resend.Client.get(client, Broadcast, "/broadcasts/:id",
      opts: [
        path_params: [id: broadcast_id]
      ]
    )
  end

  @doc """
  Updates an existing broadcast.

  Only broadcasts with status "draft" can be updated. Once a broadcast is sent or scheduled,
  it cannot be modified.

  ## Parameters

    * `broadcast_id` - The Broadcast ID (required)
    * `opts` - Keyword list with update parameters:
      * `:name` - The name of the broadcast (optional)
      * `:from` - The sender email address (optional)
      * `:subject` - The subject line of the broadcast (optional)
      * `:reply_to` - The reply-to email address(es). Can be a single string or list of strings (optional)
      * `:preview_text` - The preview text that appears in email clients (optional)
      * `:html` - The HTML content of the broadcast (optional)
      * `:text` - The plain text content of the broadcast (optional)
      * `:headers` - Map of custom headers to include (optional)
      * `:attachments` - List of attachments to include (optional)
      * `:tags` - List of tags for analytics (optional)

  ## Examples

      iex> Resend.Broadcasts.update("b6d24b8e-af0b-4c3c-be0c-359bbd97381e",
      ...>   subject: "Updated Newsletter Subject",
      ...>   preview_text: "New preview text"
      ...> )
      {:ok, %Resend.Broadcasts.Broadcast{id: "b6d24b8e-af0b-4c3c-be0c-359bbd97381e", subject: "Updated Newsletter Subject"}}

      iex> Resend.Broadcasts.update("b6d24b8e-af0b-4c3c-be0c-359bbd97381e",
      ...>   reply_to: "noreply@example.com"
      ...> )
      {:ok, %Resend.Broadcasts.Broadcast{id: "b6d24b8e-af0b-4c3c-be0c-359bbd97381e"}}

  """
  @spec update(String.t(), Keyword.t()) :: Resend.Client.response(Broadcast.t())
  @spec update(Resend.Client.t(), String.t(), Keyword.t()) ::
          Resend.Client.response(Broadcast.t())
  def update(client \\ Resend.client(), broadcast_id, opts) do
    body =
      %{
        name: opts[:name],
        from: opts[:from],
        subject: opts[:subject],
        reply_to: opts[:reply_to],
        preview_text: opts[:preview_text],
        html: opts[:html],
        text: opts[:text],
        headers: opts[:headers],
        attachments: opts[:attachments],
        tags: opts[:tags]
      }
      |> Enum.filter(fn {_k, v} -> !is_nil(v) end)
      |> Map.new()

    Resend.Client.patch(client, Broadcast, "/broadcasts/:id", body,
      opts: [
        path_params: [id: broadcast_id]
      ]
    )
  end

  @doc """
  Sends or schedules a broadcast.

  ## Parameters

    * `broadcast_id` - The Broadcast ID (required)
    * `opts` - Keyword list with optional parameters:
      * `:scheduled_at` - DateTime to schedule the broadcast. If not provided, sends immediately (optional)

  ## Examples

      # Send immediately
      iex> Resend.Broadcasts.send("b6d24b8e-af0b-4c3c-be0c-359bbd97381e")
      {:ok, %Resend.Broadcasts.Broadcast{id: "b6d24b8e-af0b-4c3c-be0c-359bbd97381e", status: "sending"}}

      # Schedule for later
      iex> Resend.Broadcasts.send("b6d24b8e-af0b-4c3c-be0c-359bbd97381e",
      ...>   scheduled_at: ~U[2024-12-25 09:00:00Z]
      ...> )
      {:ok, %Resend.Broadcasts.Broadcast{id: "b6d24b8e-af0b-4c3c-be0c-359bbd97381e", status: "scheduled"}}

      # Cancel a scheduled broadcast by sending nil
      iex> Resend.Broadcasts.send("b6d24b8e-af0b-4c3c-be0c-359bbd97381e",
      ...>   scheduled_at: nil
      ...> )
      {:ok, %Resend.Broadcasts.Broadcast{id: "b6d24b8e-af0b-4c3c-be0c-359bbd97381e", status: "cancelled"}}

  """
  @spec send(String.t()) :: Resend.Client.response(Broadcast.t())
  @spec send(String.t(), Keyword.t()) :: Resend.Client.response(Broadcast.t())
  @spec send(Resend.Client.t(), String.t()) :: Resend.Client.response(Broadcast.t())
  @spec send(Resend.Client.t(), String.t(), Keyword.t()) :: Resend.Client.response(Broadcast.t())
  def send(client \\ Resend.client(), broadcast_id, opts \\ []) do
    body =
      case Keyword.has_key?(opts, :scheduled_at) do
        true -> %{scheduled_at: opts[:scheduled_at]}
        false -> %{}
      end

    Resend.Client.post(client, Broadcast, "/broadcasts/:id/send", body,
      opts: [
        path_params: [id: broadcast_id]
      ]
    )
  end

  @doc """
  Removes a broadcast permanently. This action cannot be undone.

  Only broadcasts with status "draft" or "cancelled" can be removed.
  Broadcasts that have been sent or are currently sending cannot be deleted.

  ## Parameters

    * `broadcast_id` - The Broadcast ID (required)

  ## Examples

      iex> Resend.Broadcasts.remove("b6d24b8e-af0b-4c3c-be0c-359bbd97381e")
      {:ok, %Resend.Broadcasts.Broadcast{id: "b6d24b8e-af0b-4c3c-be0c-359bbd97381e", deleted: true}}

      iex> Resend.Broadcasts.remove("non-existent-id")
      {:error, %Resend.Error{message: "Broadcast not found"}}

  """
  @spec remove(String.t()) :: Resend.Client.response(Broadcast.t())
  @spec remove(Resend.Client.t(), String.t()) :: Resend.Client.response(Broadcast.t())
  def remove(client \\ Resend.client(), broadcast_id) do
    Resend.Client.delete(client, Broadcast, "/broadcasts/:id", %{},
      opts: [
        path_params: [id: broadcast_id]
      ]
    )
  end
end
