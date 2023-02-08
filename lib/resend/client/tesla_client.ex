defmodule Resend.Client.TeslaClient do
  @moduledoc """
  Tesla client for Resend. This is the default HTTP client used.
  """
  @behaviour Resend.Client

  @doc """
  Sends a POST request to a Resend API endpoint, given list of config options and
  a request body.
  """
  @spec post(Resend.Client.t(), String.t(), map()) ::
          {:ok, %{body: map(), status: pos_integer()}} | {:error, any()}
  def post(client, path, body) do
    Tesla.post(new(client), path, body)
  end

  @doc """
  Returns a new `Tesla.Client`, configured for calling the Resend API.
  """
  @spec new(Resend.Client.t()) :: Tesla.Client.t()
  def new(client) do
    Tesla.client([
      Tesla.Middleware.Logger,
      {Tesla.Middleware.BaseUrl, client.base_url},
      Tesla.Middleware.JSON,
      {Tesla.Middleware.Headers, [{"Authorization", "Bearer #{client.api_key}"}]}
    ])
  end
end
