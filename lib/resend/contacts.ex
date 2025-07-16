defmodule Resend.Contacts do
  @moduledoc """
  Manage contacts in Resend audiences.

  Contacts are individual email addresses within audiences. This module provides
  functions to create, list, retrieve, update, and delete contacts within specific
  audiences. Contacts can be referenced by either their ID or email address.

  ## Examples

      # Create a new contact
      {:ok, contact} = Resend.Contacts.create("audience-id", 
        email: "steve@example.com",
        first_name: "Steve",
        last_name: "Wozniak"
      )

      # List all contacts in an audience
      {:ok, contacts} = Resend.Contacts.list("audience-id")

      # Get a contact by ID
      {:ok, contact} = Resend.Contacts.get("audience-id", id: "contact-id")

      # Get a contact by email
      {:ok, contact} = Resend.Contacts.get("audience-id", email: "steve@example.com")

      # Update a contact
      {:ok, contact} = Resend.Contacts.update("audience-id", 
        id: "contact-id",
        unsubscribed: true
      )

      # Remove a contact
      {:ok, removed} = Resend.Contacts.remove("audience-id", id: "contact-id")
  """

  alias Resend.Contacts.Contact

  @doc """
  Creates a new contact inside an audience.

  ## Parameters

    * `audience_id` - The Audience ID (required)
    * `opts` - Keyword list of contact attributes:
      * `:email` - The email address of the contact (required)
      * `:first_name` - The first name of the contact (optional)
      * `:last_name` - The last name of the contact (optional)
      * `:unsubscribed` - The subscription status (optional)

  ## Examples

      iex> Resend.Contacts.create("78261eea-8f8b-4381-83c6-79fa7120f1cf",
      ...>   email: "steve@example.com",
      ...>   first_name: "Steve",
      ...>   last_name: "Wozniak",
      ...>   unsubscribed: false
      ...> )
      {:ok, %Resend.Contacts.Contact{id: "479e3145-dd38-476b-932c-529ceb705947"}}

  """
  @spec create(String.t(), Keyword.t()) :: Resend.Client.response(Contact.t())
  @spec create(Resend.Client.t(), String.t(), Keyword.t()) :: Resend.Client.response(Contact.t())
  def create(client \\ Resend.client(), audience_id, opts) do
    Resend.Client.post(
      client,
      Contact,
      "/audiences/:audience_id/contacts",
      %{
        email: opts[:email],
        first_name: opts[:first_name],
        last_name: opts[:last_name],
        unsubscribed: opts[:unsubscribed]
      },
      opts: [
        path_params: [audience_id: audience_id]
      ]
    )
  end

  @doc """
  Lists all contacts from an audience.

  ## Parameters

    * `audience_id` - The Audience ID (required)

  ## Examples

      iex> Resend.Contacts.list("78261eea-8f8b-4381-83c6-79fa7120f1cf")
      {:ok, %Resend.List{data: [%Resend.Contacts.Contact{email: "steve@example.com"}]}}

  """
  @spec list(String.t()) :: Resend.Client.response(Resend.List.t(Contact.t()))
  @spec list(Resend.Client.t(), String.t()) :: Resend.Client.response(Resend.List.t(Contact.t()))
  def list(client \\ Resend.client(), audience_id) do
    Resend.Client.get(client, Resend.List.of(Contact), "/audiences/:audience_id/contacts",
      opts: [
        path_params: [audience_id: audience_id]
      ]
    )
  end

  @doc """
  Gets details of a specific contact by ID or email.

  ## Parameters

    * `audience_id` - The Audience ID (required)
    * `opts` - Keyword list with one of:
      * `:id` - The Contact ID
      * `:email` - The Contact Email

  Either `:id` or `:email` must be provided.

  ## Examples

      # Get by contact ID
      iex> Resend.Contacts.get("78261eea-8f8b-4381-83c6-79fa7120f1cf",
      ...>   id: "e169aa45-1ecf-4183-9955-b1499d5701d3"
      ...> )
      {:ok, %Resend.Contacts.Contact{id: "e169aa45-1ecf-4183-9955-b1499d5701d3"}}

      # Get by contact email
      iex> Resend.Contacts.get("78261eea-8f8b-4381-83c6-79fa7120f1cf",
      ...>   email: "steve@example.com"
      ...> )
      {:ok, %Resend.Contacts.Contact{email: "steve@example.com"}}

  """
  @spec get(String.t(), Keyword.t()) :: Resend.Client.response(Contact.t())
  @spec get(Resend.Client.t(), String.t(), Keyword.t()) :: Resend.Client.response(Contact.t())
  def get(client \\ Resend.client(), audience_id, opts) do
    contact_id = opts[:id] || opts[:email]

    Resend.Client.get(client, Contact, "/audiences/:audience_id/contacts/:id",
      opts: [
        path_params: [audience_id: audience_id, id: contact_id]
      ]
    )
  end

  @doc """
  Updates an existing contact's information.

  ## Parameters

    * `audience_id` - The Audience ID (required)
    * `opts` - Keyword list with:
      * Either `:id` or `:email` to identify the contact (required)
      * `:first_name` - The first name of the contact (optional)
      * `:last_name` - The last name of the contact (optional)
      * `:unsubscribed` - The subscription status (optional)

  ## Examples

      # Update by contact ID
      iex> Resend.Contacts.update("78261eea-8f8b-4381-83c6-79fa7120f1cf",
      ...>   id: "e169aa45-1ecf-4183-9955-b1499d5701d3",
      ...>   unsubscribed: true
      ...> )
      {:ok, %Resend.Contacts.Contact{id: "e169aa45-1ecf-4183-9955-b1499d5701d3"}}

      # Update by contact email
      iex> Resend.Contacts.update("78261eea-8f8b-4381-83c6-79fa7120f1cf",
      ...>   email: "steve@example.com",
      ...>   first_name: "Steven"
      ...> )
      {:ok, %Resend.Contacts.Contact{email: "steve@example.com"}}

  """
  @spec update(String.t(), Keyword.t()) :: Resend.Client.response(Contact.t())
  @spec update(Resend.Client.t(), String.t(), Keyword.t()) :: Resend.Client.response(Contact.t())
  def update(client \\ Resend.client(), audience_id, opts) do
    contact_id = opts[:id] || opts[:email]

    body =
      %{
        first_name: opts[:first_name],
        last_name: opts[:last_name],
        unsubscribed: opts[:unsubscribed]
      }
      |> Enum.filter(fn {_k, v} -> !is_nil(v) end)
      |> Map.new()

    Resend.Client.patch(client, Contact, "/audiences/:audience_id/contacts/:id", body,
      opts: [
        path_params: [audience_id: audience_id, id: contact_id]
      ]
    )
  end

  @doc """
  Removes a contact from an audience.

  ## Parameters

    * `audience_id` - The Audience ID (required)
    * `opts` - Keyword list with one of:
      * `:id` - The Contact ID
      * `:email` - The Contact Email

  Either `:id` or `:email` must be provided.

  ## Examples

      # Remove by contact ID
      iex> Resend.Contacts.remove("78261eea-8f8b-4381-83c6-79fa7120f1cf",
      ...>   id: "520784e2-887d-4c25-b53c-4ad46ad38100"
      ...> )
      {:ok, %Resend.Contacts.Contact{id: "520784e2-887d-4c25-b53c-4ad46ad38100", deleted: true}}

      # Remove by contact email
      iex> Resend.Contacts.remove("78261eea-8f8b-4381-83c6-79fa7120f1cf",
      ...>   email: "steve@example.com"
      ...> )
      {:ok, %Resend.Contacts.Contact{deleted: true}}

  """
  @spec remove(String.t(), Keyword.t()) :: Resend.Client.response(Contact.t())
  @spec remove(Resend.Client.t(), String.t(), Keyword.t()) :: Resend.Client.response(Contact.t())
  def remove(client \\ Resend.client(), audience_id, opts) do
    contact_id = opts[:id] || opts[:email]

    Resend.Client.delete(client, Contact, "/audiences/:audience_id/contacts/:id", %{},
      opts: [
        path_params: [audience_id: audience_id, id: contact_id]
      ]
    )
  end
end
