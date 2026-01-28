defmodule Resend.Contacts do
  @moduledoc """
  Manage contacts in Resend.

  Note: Contact endpoints support lookup by email OR id (e.g., `contact_id` can be
  "user@example.com" or "ct_123").
  """

  alias Resend.Contacts.Contact
  alias Resend.Contacts.TopicSubscription
  alias Resend.Segments.Segment

  @doc """
  Creates a new contact.

  ## Options

    * `:email` - The contact's email address (required)
    * `:first_name` - The contact's first name
    * `:last_name` - The contact's last name
    * `:unsubscribed` - Whether the contact is unsubscribed
    * `:properties` - Object of custom property key-value pairs
    * `:segments` - Array of segment IDs to add contact to
    * `:topics` - Array of topic subscriptions with `:id` and `:subscription` (`opt_in`/`opt_out`)

  """
  @spec create(Keyword.t()) :: Resend.Client.response(Contact.t())
  @spec create(Resend.Client.t(), Keyword.t()) :: Resend.Client.response(Contact.t())
  def create(client \\ Resend.client(), opts) do
    Resend.Client.post(
      client,
      Contact,
      "/contacts",
      %{
        email: opts[:email],
        first_name: opts[:first_name],
        last_name: opts[:last_name],
        unsubscribed: opts[:unsubscribed],
        properties: opts[:properties],
        segments: opts[:segments],
        topics: opts[:topics]
      }
    )
  end

  @doc """
  Lists all contacts.

  ## Options

    * `:segment_id` - Filter contacts by segment ID

  """
  @spec list() :: Resend.Client.response(Resend.List.t(Contact.t()))
  @spec list(Keyword.t()) :: Resend.Client.response(Resend.List.t(Contact.t()))
  @spec list(Resend.Client.t(), Keyword.t()) :: Resend.Client.response(Resend.List.t(Contact.t()))
  def list(client_or_opts \\ [])

  def list(%Resend.Client{} = client), do: do_list(client, [])
  def list(opts) when is_list(opts), do: do_list(Resend.client(), opts)

  def list(%Resend.Client{} = client, opts) when is_list(opts), do: do_list(client, opts)

  defp do_list(client, opts) do
    query = if opts[:segment_id], do: [segment_id: opts[:segment_id]], else: []
    Resend.Client.get(client, Resend.List.of(Contact), "/contacts", query: query)
  end

  @doc """
  Gets a contact by ID or email.

  The `contact_id` can be a contact ID (e.g., "ct_123") or an email address.
  """
  @spec get(String.t()) :: Resend.Client.response(Contact.t())
  @spec get(Resend.Client.t(), String.t()) :: Resend.Client.response(Contact.t())
  def get(client \\ Resend.client(), contact_id) do
    Resend.Client.get(client, Contact, "/contacts/:id", opts: [path_params: [id: contact_id]])
  end

  @doc """
  Updates a contact.

  ## Options

    * `:first_name` - The contact's first name
    * `:last_name` - The contact's last name
    * `:unsubscribed` - Whether the contact is unsubscribed
    * `:properties` - Object of custom property key-value pairs

  """
  @spec update(String.t(), Keyword.t()) :: Resend.Client.response(Contact.t())
  @spec update(Resend.Client.t(), String.t(), Keyword.t()) ::
          Resend.Client.response(Contact.t())
  def update(client \\ Resend.client(), contact_id, opts) do
    Resend.Client.patch(
      client,
      Contact,
      "/contacts/:id",
      %{
        first_name: opts[:first_name],
        last_name: opts[:last_name],
        unsubscribed: opts[:unsubscribed],
        properties: opts[:properties]
      },
      opts: [path_params: [id: contact_id]]
    )
  end

  @doc """
  Removes a contact.
  """
  @spec remove(String.t()) :: Resend.Client.response(Resend.Empty.t())
  @spec remove(Resend.Client.t(), String.t()) ::
          Resend.Client.response(Resend.Empty.t())
  def remove(client \\ Resend.client(), contact_id) do
    Resend.Client.delete(client, Resend.Empty, "/contacts/:id", %{},
      opts: [path_params: [id: contact_id]]
    )
  end

  @doc """
  Adds a contact to a segment.
  """
  @spec add_to_segment(String.t(), String.t()) ::
          Resend.Client.response(Resend.Empty.t())
  @spec add_to_segment(Resend.Client.t(), String.t(), String.t()) ::
          Resend.Client.response(Resend.Empty.t())
  def add_to_segment(client \\ Resend.client(), contact_id, segment_id) do
    Resend.Client.post(
      client,
      Resend.Empty,
      "/contacts/:contact_id/segments/:segment_id",
      %{},
      opts: [path_params: [contact_id: contact_id, segment_id: segment_id]]
    )
  end

  @doc """
  Removes a contact from a segment.
  """
  @spec remove_from_segment(String.t(), String.t()) ::
          Resend.Client.response(Resend.Empty.t())
  @spec remove_from_segment(Resend.Client.t(), String.t(), String.t()) ::
          Resend.Client.response(Resend.Empty.t())
  def remove_from_segment(client \\ Resend.client(), contact_id, segment_id) do
    Resend.Client.delete(
      client,
      Resend.Empty,
      "/contacts/:contact_id/segments/:segment_id",
      %{},
      opts: [path_params: [contact_id: contact_id, segment_id: segment_id]]
    )
  end

  @doc """
  Lists all segments for a contact.
  """
  @spec list_segments(String.t()) ::
          Resend.Client.response(Resend.List.t(Segment.t()))
  @spec list_segments(Resend.Client.t(), String.t()) ::
          Resend.Client.response(Resend.List.t(Segment.t()))
  def list_segments(client \\ Resend.client(), contact_id) do
    Resend.Client.get(
      client,
      Resend.List.of(Segment),
      "/contacts/:id/segments",
      opts: [path_params: [id: contact_id]]
    )
  end

  @doc """
  Lists all topic subscriptions for a contact.
  """
  @spec list_topics(String.t()) ::
          Resend.Client.response(Resend.List.t(TopicSubscription.t()))
  @spec list_topics(Resend.Client.t(), String.t()) ::
          Resend.Client.response(Resend.List.t(TopicSubscription.t()))
  def list_topics(client \\ Resend.client(), contact_id) do
    Resend.Client.get(
      client,
      Resend.List.of(TopicSubscription),
      "/contacts/:contact_id/topics",
      opts: [path_params: [contact_id: contact_id]]
    )
  end

  @doc """
  Updates topic subscriptions for a contact.

  ## Options

    * `:topics` - A list of maps with `:topic_id` and `:subscribed` keys

  """
  @spec update_topics(String.t(), Keyword.t()) ::
          Resend.Client.response(Resend.List.t(TopicSubscription.t()))
  @spec update_topics(Resend.Client.t(), String.t(), Keyword.t()) ::
          Resend.Client.response(Resend.List.t(TopicSubscription.t()))
  def update_topics(client \\ Resend.client(), contact_id, opts) do
    Resend.Client.patch(
      client,
      Resend.List.of(TopicSubscription),
      "/contacts/:contact_id/topics",
      %{
        topics: opts[:topics]
      },
      opts: [path_params: [contact_id: contact_id]]
    )
  end
end
