defmodule Resend.Client.TeslaClient do
  @behaviour Resend.Client

  @spec post(String.t(), map()) ::
          {:ok, %{body: map(), status: pos_integer()}} | {:error, any()}
  def post(path, body) do
    client = new(Resend.config())
    Tesla.post(client, path, body)
  end

  @spec new(Resend.config()) :: Tesla.Client.t()
  def new(config) do
    api_key = Keyword.fetch!(config, :api_key)
    base_url = Keyword.get(config, :base_url, "https://api.resend.com")

    Tesla.client([
      Tesla.Middleware.Logger,
      {Tesla.Middleware.BaseUrl, base_url},
      Tesla.Middleware.JSON,
      {Tesla.Middleware.Headers, [{"Authorization", "Bearer #{api_key}"}]}
    ])
  end
end
