defmodule Resend.Topics do
  @moduledoc """
  Manage topics in Resend.
  """

  alias Resend.Topics.Topic

  @doc """
  Creates a new topic.

  ## Options

    * `:name` - The name of the topic (required)
    * `:audience_id` - The audience ID (required)
    * `:default_subscription` - Required. Values: `opt_in` or `opt_out`. Cannot be changed after creation.
    * `:description` - Description of the topic (max 200 characters)
    * `:visibility` - `public` or `private` (default: `private`)

  """
  @spec create(Keyword.t()) :: Resend.Client.response(Topic.t())
  @spec create(Resend.Client.t(), Keyword.t()) :: Resend.Client.response(Topic.t())
  def create(client \\ Resend.client(), opts) do
    Resend.Client.post(
      client,
      Topic,
      "/topics",
      %{
        name: opts[:name],
        audience_id: opts[:audience_id],
        default_subscription: opts[:default_subscription],
        description: opts[:description],
        visibility: opts[:visibility]
      }
    )
  end

  @doc """
  Lists all topics.

  ## Options

    * `:audience_id` - Filter topics by audience ID

  """
  @spec list() :: Resend.Client.response(Resend.List.t(Topic.t()))
  @spec list(Keyword.t()) :: Resend.Client.response(Resend.List.t(Topic.t()))
  @spec list(Resend.Client.t(), Keyword.t()) :: Resend.Client.response(Resend.List.t(Topic.t()))
  def list(client_or_opts \\ [])

  def list(%Resend.Client{} = client), do: do_list(client, [])
  def list(opts) when is_list(opts), do: do_list(Resend.client(), opts)

  def list(%Resend.Client{} = client, opts) when is_list(opts), do: do_list(client, opts)

  defp do_list(client, opts) do
    query = if opts[:audience_id], do: [audience_id: opts[:audience_id]], else: []
    Resend.Client.get(client, Resend.List.of(Topic), "/topics", query: query)
  end

  @doc """
  Gets a topic by ID.
  """
  @spec get(String.t()) :: Resend.Client.response(Topic.t())
  @spec get(Resend.Client.t(), String.t()) :: Resend.Client.response(Topic.t())
  def get(client \\ Resend.client(), topic_id) do
    Resend.Client.get(client, Topic, "/topics/:id", opts: [path_params: [id: topic_id]])
  end

  @doc """
  Updates a topic.

  ## Options

    * `:name` - The name of the topic
    * `:description` - Description of the topic (max 200 characters)
    * `:visibility` - `public` or `private`

  Note: `default_subscription` cannot be changed after creation.
  """
  @spec update(String.t(), Keyword.t()) :: Resend.Client.response(Topic.t())
  @spec update(Resend.Client.t(), String.t(), Keyword.t()) ::
          Resend.Client.response(Topic.t())
  def update(client \\ Resend.client(), topic_id, opts) do
    Resend.Client.patch(
      client,
      Topic,
      "/topics/:id",
      %{
        name: opts[:name],
        description: opts[:description],
        visibility: opts[:visibility]
      },
      opts: [path_params: [id: topic_id]]
    )
  end

  @doc """
  Removes a topic.
  """
  @spec remove(String.t()) :: Resend.Client.response(Resend.Empty.t())
  @spec remove(Resend.Client.t(), String.t()) ::
          Resend.Client.response(Resend.Empty.t())
  def remove(client \\ Resend.client(), topic_id) do
    Resend.Client.delete(client, Resend.Empty, "/topics/:id", %{},
      opts: [path_params: [id: topic_id]]
    )
  end
end
