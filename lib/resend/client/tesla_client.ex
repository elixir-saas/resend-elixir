defmodule Resend.Client.TeslaClient do
  @moduledoc """
  Tesla client for Resend. This is the default HTTP client used.
  """
  @behaviour Resend.Client

  @doc """
  Sends a request to a Resend API endpoint, given list of request opts.
  """
  @spec request(Resend.Client.t(), Keyword.t()) ::
          {:ok, %{body: map(), status: pos_integer()}} | {:error, any()}
  def request(client, opts) do
    opts = Keyword.take(opts, [:method, :url, :query, :headers, :body, :opts])
    Tesla.request(new(client), opts)
  end

  @doc """
  Returns a new `Tesla.Client`, configured for calling the Resend API.
  """
  @spec new(Resend.Client.t()) :: Tesla.Client.t()
  def new(client) do
    Tesla.client([
      Tesla.Middleware.Logger,
      {Tesla.Middleware.BaseUrl, client.base_url},
      Tesla.Middleware.PathParams,
      Tesla.Middleware.JSON,
      {Tesla.Middleware.Headers, [{"Authorization", "Bearer #{client.api_key}"}]}
    ])
  end
end
