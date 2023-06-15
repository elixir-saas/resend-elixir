defmodule Resend.Domains do
  alias Resend.Domains.Domain

  @doc """
  TODO: Documentation.
  """
  @spec create(Keyword.t()) :: Resend.Client.response(Domain.t())
  @spec create(Resend.Client.t(), Keyword.t()) :: Resend.Client.response(Domain.t())
  def create(client \\ Resend.client(), opts) do
    Resend.Client.post(client, Domain, "/domains", %{
      name: opts[:name],
      region: opts[:region]
    })
  end

  @doc """
  TODO: Documentation.
  """
  @spec get(String.t()) :: Resend.Client.response(Domain.t())
  @spec get(Resend.Client.t(), String.t()) :: Resend.Client.response(Domain.t())
  def get(client \\ Resend.client(), domain_id) do
    Resend.Client.get(client, Domain, "/domains/:id",
      opts: [
        path_params: [id: domain_id]
      ]
    )
  end

  @doc """
  TODO: Documentation.
  """
  @spec verify(String.t()) :: Resend.Client.response(Domain.t())
  @spec verify(Resend.Client.t(), String.t()) :: Resend.Client.response(Domain.t())
  def verify(client \\ Resend.client(), domain_id) do
    Resend.Client.post(client, Domain, "/domains/:id/verify", %{},
      opts: [
        path_params: [id: domain_id]
      ]
    )
  end

  @doc """
  TODO: Documentation.
  """
  @spec list() :: Resend.Client.response(Resend.List.t(Domain.t()))
  @spec list(Resend.Client.t()) :: Resend.Client.response(Resend.List.t(Domain.t()))
  def list(client \\ Resend.client()) do
    Resend.Client.get(client, Resend.List.of(Domain), "/domains")
  end

  @doc """
  TODO: Documentation.
  """
  @spec remove(String.t()) :: Resend.Client.response(Domain.t())
  @spec remove(Resend.Client.t(), String.t()) :: Resend.Client.response(Domain.t())
  def remove(client \\ Resend.client(), domain_id) do
    Resend.Client.delete(client, Domain, "/domains/:id", %{},
      opts: [
        path_params: [id: domain_id]
      ]
    )
  end
end
