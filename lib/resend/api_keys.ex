defmodule Resend.ApiKeys do
  alias Resend.ApiKeys.ApiKey

  @doc """
  TODO: Documentation.
  """
  @spec create(Keyword.t()) :: Resend.Client.response(ApiKey.t())
  @spec create(Resend.Client.t(), Keyword.t()) :: Resend.Client.response(ApiKey.t())
  def create(client \\ Resend.client(), opts) do
    Resend.Client.post(client, ApiKey, "/api-keys", %{
      name: opts[:name],
      permission: opts[:permission],
      domain_id: opts[:domain_id]
    })
  end

  @doc """
  TODO: Documentation.
  """
  @spec list() :: Resend.Client.response(Resend.List.t(ApiKey.t()))
  @spec list(Resend.Client.t()) :: Resend.Client.response(Resend.List.t(ApiKey.t()))
  def list(client \\ Resend.client()) do
    Resend.Client.get(client, Resend.List.of(ApiKey), "/api-keys")
  end

  @doc """
  TODO: Documentation.
  """
  @spec remove(String.t()) :: Resend.Client.response(ApiKey.t())
  @spec remove(Resend.Client.t(), String.t()) :: Resend.Client.response(ApiKey.t())
  def remove(client \\ Resend.client(), api_key_id) do
    Resend.Client.delete(client, Resend.Empty, "/api-keys/:id", %{},
      opts: [
        path_params: [id: api_key_id]
      ]
    )
  end
end
