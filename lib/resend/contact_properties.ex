defmodule Resend.ContactProperties do
  @moduledoc """
  Manage contact properties in Resend.
  """

  alias Resend.ContactProperties.ContactProperty
  alias Resend.Util

  @doc """
  Creates a new contact property.

  ## Options

    * `:key` - The key of the property (required, max 50 chars, alphanumeric + underscores)
    * `:type` - The type of the property (required)
    * `:fallback_value` - Default value when property is not set on a contact

  """
  @spec create(Keyword.t()) :: Resend.Client.response(ContactProperty.t())
  @spec create(Resend.Client.t(), Keyword.t()) :: Resend.Client.response(ContactProperty.t())
  def create(client \\ Resend.client(), opts) do
    body =
      %{
        key: opts[:key],
        type: opts[:type],
        fallback_value: opts[:fallback_value]
      }
      |> Util.compact()

    Resend.Client.post(client, ContactProperty, "/contact-properties", body)
  end

  @doc """
  Lists all contact properties.
  """
  @spec list() :: Resend.Client.response(Resend.List.t(ContactProperty.t()))
  @spec list(Resend.Client.t()) :: Resend.Client.response(Resend.List.t(ContactProperty.t()))
  def list(client \\ Resend.client()) do
    Resend.Client.get(client, Resend.List.of(ContactProperty), "/contact-properties")
  end

  @doc """
  Gets a contact property by ID.
  """
  @spec get(String.t()) :: Resend.Client.response(ContactProperty.t())
  @spec get(Resend.Client.t(), String.t()) :: Resend.Client.response(ContactProperty.t())
  def get(client \\ Resend.client(), property_id) do
    Resend.Client.get(client, ContactProperty, "/contact-properties/:id",
      opts: [path_params: [id: property_id]]
    )
  end

  @doc """
  Updates a contact property.

  ## Options

    * `:fallback_value` - Default value when property is not set on a contact

  """
  @spec update(String.t(), Keyword.t()) :: Resend.Client.response(ContactProperty.t())
  @spec update(Resend.Client.t(), String.t(), Keyword.t()) ::
          Resend.Client.response(ContactProperty.t())
  def update(client \\ Resend.client(), property_id, opts) do
    body =
      %{fallback_value: opts[:fallback_value]}
      |> Util.compact()

    Resend.Client.patch(
      client,
      ContactProperty,
      "/contact-properties/:id",
      body,
      opts: [path_params: [id: property_id]]
    )
  end

  @doc """
  Removes a contact property.
  """
  @spec remove(String.t()) :: Resend.Client.response(Resend.Empty.t())
  @spec remove(Resend.Client.t(), String.t()) :: Resend.Client.response(Resend.Empty.t())
  def remove(client \\ Resend.client(), property_id) do
    Resend.Client.delete(client, Resend.Empty, "/contact-properties/:id", %{},
      opts: [path_params: [id: property_id]]
    )
  end
end
