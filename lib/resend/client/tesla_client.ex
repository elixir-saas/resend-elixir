defmodule Resend.Client.TeslaClient do
  @moduledoc """
  Tesla client for Resend. This is the default HTTP client used.
  """
  @behaviour Resend.Client

  @doc """
  Sends a POST request to a Resend API endpoint, given list of config options and
  a request body.
  """
  @spec post(Resend.config(), String.t(), map()) ::
          {:ok, %{body: map(), status: pos_integer()}} | {:error, any()}
  def post(config, path, body) do
    Tesla.post(new(config), path, body)
  end

  @doc """
  Returns a new `Tesla.Client`, configured for calling the Resend API.
  """
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
