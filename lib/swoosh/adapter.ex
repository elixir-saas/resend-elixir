defmodule Resend.Swoosh.Adapter do
  @behaviour Swoosh.Adapter

  @impl true
  def deliver(%Swoosh.Email{} = email, config) do
    Tesla.post(client(config), "/email", %{
      from: email.from,
      to: email.to,
      subject: email.subject,
      bcc: email.bcc,
      cc: email.cc,
      reply_to: email.reply_to,
      html: email.html_body,
      text: email.text_body
    })
    |> case do
      {:ok, %{status: 200, body: _body}} ->
        {:ok, email}

      {:ok, %{status: code, body: body}} ->
        {:error, {:api_error, code, body}}

      {:error, reason} ->
        {:error, {:client_error, reason}}
    end
  end

  @impl true
  def deliver_many(list, config) do
    Enum.reduce_while(list, {:ok, []}, fn email, {:ok, acc} ->
      case deliver(email, config) do
        {:ok, email} ->
          {:cont, {:ok, acc ++ [email]}}

        {:error, _reason} = error ->
          {:halt, error}
      end
    end)
  end

  @impl true
  def validate_config(config) do
    api_key =
      Keyword.get(config, :api_key) ||
        raise "Missing required config key for #{__MODULE__}: :api_key"

    String.starts_with?(api_key, "re_") ||
      raise "Resend API key should start with 're_', please check your configuration"

    :ok
  end

  defp client(config) do
    api_key = Keyword.fetch!(config, :api_key)

    Tesla.client([
      Tesla.Middleware.Logger,
      {Tesla.Middleware.BaseUrl, "https://api.resend.com"},
      Tesla.Middleware.JSON,
      {Tesla.Middleware.Headers, [{"Authorization", "Bearer #{api_key}"}]}
    ])
  end
end
