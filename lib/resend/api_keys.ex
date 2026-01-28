defmodule Resend.ApiKeys do
  @moduledoc """
  Manage API keys in Resend.
  """

  alias Resend.ApiKeys.ApiKey
  alias Resend.Util

  @doc """
  Creates a new API key.

  Parameter options:

    * `:name` - The API key name (required)
    * `:permission` - Access scope to assign to this key, one of: `["full_access", "sending_access"]`
    * `:domain_id` - Restrict sending to a specific domain. Only used when permission is set to `"sending_access"`

  The `:token` field in the response struct is the only time you will see the token, keep it somewhere safe.

  """
  @spec create(Keyword.t()) :: Resend.Client.response(ApiKey.t())
  @spec create(Resend.Client.t(), Keyword.t()) :: Resend.Client.response(ApiKey.t())
  def create(client \\ Resend.client(), opts) do
    body =
      %{
        name: opts[:name],
        permission: opts[:permission],
        domain_id: opts[:domain_id]
      }
      |> Util.compact()

    Resend.Client.post(client, ApiKey, "/api-keys", body)
  end

  @doc """
  Lists all API keys.
  """
  @spec list() :: Resend.Client.response(Resend.List.t(ApiKey.t()))
  @spec list(Resend.Client.t()) :: Resend.Client.response(Resend.List.t(ApiKey.t()))
  def list(client \\ Resend.client()) do
    Resend.Client.get(client, Resend.List.of(ApiKey), "/api-keys")
  end

  @doc """
  Removes an API key. Caution: This can't be undone!
  """
  @spec remove(String.t()) :: Resend.Client.response(Resend.Empty.t())
  @spec remove(Resend.Client.t(), String.t()) :: Resend.Client.response(Resend.Empty.t())
  def remove(client \\ Resend.client(), api_key_id) do
    Resend.Client.delete(client, Resend.Empty, "/api-keys/:id", %{},
      opts: [
        path_params: [id: api_key_id]
      ]
    )
  end
end
