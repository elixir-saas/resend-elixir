defmodule Resend.Audiences do
  @moduledoc """
  Manage audiences in Resend.

  > #### Deprecation Notice {: .warning}
  >
  > Audiences are deprecated in favor of Segments. The API documentation notes:
  > "Audiences are now called Segments. Follow the Migration Guide."
  >
  > These endpoints still function, and an `audience_id` is required for filtering
  > Contacts, Segments, and Topics by audience. However, consider using Segments
  > for new implementations.
  """

  alias Resend.Audiences.Audience

  @doc """
  Creates a new audience.

  ## Options

    * `:name` - The name of the audience (required)

  """
  @spec create(Keyword.t()) :: Resend.Client.response(Audience.t())
  @spec create(Resend.Client.t(), Keyword.t()) :: Resend.Client.response(Audience.t())
  def create(client \\ Resend.client(), opts) do
    Resend.Client.post(client, Audience, "/audiences", %{
      name: opts[:name]
    })
  end

  @doc """
  Lists all audiences.
  """
  @spec list() :: Resend.Client.response(Resend.List.t(Audience.t()))
  @spec list(Resend.Client.t()) :: Resend.Client.response(Resend.List.t(Audience.t()))
  def list(client \\ Resend.client()) do
    Resend.Client.get(client, Resend.List.of(Audience), "/audiences")
  end

  @doc """
  Gets an audience by ID.
  """
  @spec get(String.t()) :: Resend.Client.response(Audience.t())
  @spec get(Resend.Client.t(), String.t()) :: Resend.Client.response(Audience.t())
  def get(client \\ Resend.client(), audience_id) do
    Resend.Client.get(client, Audience, "/audiences/:id", opts: [path_params: [id: audience_id]])
  end

  @doc """
  Removes an audience.
  """
  @spec remove(String.t()) :: Resend.Client.response(Resend.Empty.t())
  @spec remove(Resend.Client.t(), String.t()) :: Resend.Client.response(Resend.Empty.t())
  def remove(client \\ Resend.client(), audience_id) do
    Resend.Client.delete(client, Resend.Empty, "/audiences/:id", %{},
      opts: [path_params: [id: audience_id]]
    )
  end
end
