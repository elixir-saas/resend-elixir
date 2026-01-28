defmodule Resend.Webhooks do
  @moduledoc """
  Manage webhooks in Resend.
  """

  alias Resend.Webhooks.Webhook

  @doc """
  Creates a new webhook.

  ## Options

    * `:endpoint` - The webhook endpoint URL (required)
    * `:events` - List of events to subscribe to (required)
    * `:name` - A name for the webhook

  """
  @spec create(Keyword.t()) :: Resend.Client.response(Webhook.t())
  @spec create(Resend.Client.t(), Keyword.t()) :: Resend.Client.response(Webhook.t())
  def create(client \\ Resend.client(), opts) do
    Resend.Client.post(client, Webhook, "/webhooks", %{
      endpoint: opts[:endpoint],
      events: opts[:events],
      name: opts[:name]
    })
  end

  @doc """
  Lists all webhooks.
  """
  @spec list() :: Resend.Client.response(Resend.List.t(Webhook.t()))
  @spec list(Resend.Client.t()) :: Resend.Client.response(Resend.List.t(Webhook.t()))
  def list(client \\ Resend.client()) do
    Resend.Client.get(client, Resend.List.of(Webhook), "/webhooks")
  end

  @doc """
  Gets a webhook by ID.
  """
  @spec get(String.t()) :: Resend.Client.response(Webhook.t())
  @spec get(Resend.Client.t(), String.t()) :: Resend.Client.response(Webhook.t())
  def get(client \\ Resend.client(), webhook_id) do
    Resend.Client.get(client, Webhook, "/webhooks/:id", opts: [path_params: [id: webhook_id]])
  end

  @doc """
  Updates a webhook.

  ## Options

    * `:endpoint` - The webhook endpoint URL
    * `:events` - List of events to subscribe to
    * `:name` - A name for the webhook

  """
  @spec update(String.t(), Keyword.t()) :: Resend.Client.response(Webhook.t())
  @spec update(Resend.Client.t(), String.t(), Keyword.t()) :: Resend.Client.response(Webhook.t())
  def update(client \\ Resend.client(), webhook_id, opts) do
    Resend.Client.patch(
      client,
      Webhook,
      "/webhooks/:id",
      %{
        endpoint: opts[:endpoint],
        events: opts[:events],
        name: opts[:name]
      },
      opts: [path_params: [id: webhook_id]]
    )
  end

  @doc """
  Removes a webhook.
  """
  @spec remove(String.t()) :: Resend.Client.response(Resend.Empty.t())
  @spec remove(Resend.Client.t(), String.t()) :: Resend.Client.response(Resend.Empty.t())
  def remove(client \\ Resend.client(), webhook_id) do
    Resend.Client.delete(client, Resend.Empty, "/webhooks/:id", %{},
      opts: [path_params: [id: webhook_id]]
    )
  end
end
