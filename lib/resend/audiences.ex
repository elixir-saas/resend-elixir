defmodule Resend.Audiences do
  @moduledoc """
  Manage audiences in Resend.

  Audiences are groups of contacts that you can send broadcasts to. This module
  provides functions to create, list, retrieve, and delete audiences.

  ## Examples

      # Create a new audience
      {:ok, audience} = Resend.Audiences.create(name: "Newsletter Subscribers")

      # List all audiences
      {:ok, audiences} = Resend.Audiences.list()

      # Get a specific audience
      {:ok, audience} = Resend.Audiences.get("78261eea-8f8b-4381-83c6-79fa7120f1cf")

      # Remove an audience
      {:ok, removed_audience} = Resend.Audiences.remove("78261eea-8f8b-4381-83c6-79fa7120f1cf")
  """

  alias Resend.Audiences.Audience

  @doc """
  Creates a new audience.

  ## Parameters

    * `:name` - The name of the audience you want to create (required)

  ## Examples

      iex> Resend.Audiences.create(name: "Newsletter Subscribers")
      {:ok, %Resend.Audiences.Audience{id: "78261eea-8f8b-4381-83c6-79fa7120f1cf", name: "Newsletter Subscribers"}}

      iex> Resend.Audiences.create(name: "")
      {:error, %Resend.Error{message: "Audience name is required"}}

  """
  @spec create(Keyword.t()) :: Resend.Client.response(Audience.t())
  @spec create(Resend.Client.t(), Keyword.t()) :: Resend.Client.response(Audience.t())
  def create(client \\ Resend.client(), opts) do
    Resend.Client.post(client, Audience, "/audiences", %{
      name: opts[:name]
    })
  end

  @doc """
  Lists all audiences in your account.

  ## Examples

      iex> Resend.Audiences.list()
      {:ok, %Resend.List{data: [%Resend.Audiences.Audience{id: "78261eea-8f8b-4381-83c6-79fa7120f1cf", name: "Newsletter Subscribers"}]}}

  """
  @spec list() :: Resend.Client.response(Resend.List.t(Audience.t()))
  @spec list(Resend.Client.t()) :: Resend.Client.response(Resend.List.t(Audience.t()))
  def list(client \\ Resend.client()) do
    Resend.Client.get(client, Resend.List.of(Audience), "/audiences")
  end

  @doc """
  Gets details of a specific audience by its ID.

  ## Parameters

    * `audience_id` - The Audience ID (required)

  ## Examples

      iex> Resend.Audiences.get("78261eea-8f8b-4381-83c6-79fa7120f1cf")
      {:ok, %Resend.Audiences.Audience{id: "78261eea-8f8b-4381-83c6-79fa7120f1cf", name: "Newsletter Subscribers"}}

      iex> Resend.Audiences.get("non-existent-id")
      {:error, %Resend.Error{message: "Audience not found"}}

  """
  @spec get(String.t()) :: Resend.Client.response(Audience.t())
  @spec get(Resend.Client.t(), String.t()) :: Resend.Client.response(Audience.t())
  def get(client \\ Resend.client(), audience_id) do
    Resend.Client.get(client, Audience, "/audiences/:id",
      opts: [
        path_params: [id: audience_id]
      ]
    )
  end

  @doc """
  Removes an audience permanently. This action cannot be undone.

  Deleting an audience will also delete all associated contacts.

  ## Parameters

    * `audience_id` - The Audience ID (required)

  ## Examples

      iex> Resend.Audiences.remove("78261eea-8f8b-4381-83c6-79fa7120f1cf")
      {:ok, %Resend.Audiences.Audience{id: "78261eea-8f8b-4381-83c6-79fa7120f1cf", deleted: true}}

      iex> Resend.Audiences.remove("non-existent-id")
      {:error, %Resend.Error{message: "Audience not found"}}

  """
  @spec remove(String.t()) :: Resend.Client.response(Audience.t())
  @spec remove(Resend.Client.t(), String.t()) :: Resend.Client.response(Audience.t())
  def remove(client \\ Resend.client(), audience_id) do
    Resend.Client.delete(client, Audience, "/audiences/:id", %{},
      opts: [
        path_params: [id: audience_id]
      ]
    )
  end
end
