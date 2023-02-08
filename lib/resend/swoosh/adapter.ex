defmodule Resend.Swoosh.Adapter do
  @moduledoc """
  Adapter module to configure Swoosh to send emails via Resend.

  Using this adapter, we can configure a new Phoenix application to send mail
  via Resend by default. If the project generated authentication with `phx.gen.auth`,
  then all auth communication will work with Resend out of the box.

  To configure your Mailer, specify the adapter and a Resend API key:

  ```ex
  config :my_app, MyApp.Mailer,
    adapter: Resend.Swoosh.Adapter,
    api_key: "re_1234567"
  ```

  If you're configuring your app for production, configure your adapter in `prod.exs`, and
  your API key from the environment in `runtime.exs`:

  ```ex
  # prod.exs
  config :my_app, MyApp.Mailer, adapter: Resend.Swoosh.Adapter
  ```

  ```ex
  # runtime.exs
  config :my_app, MyApp.Mailer, api_key: "re_1234567"
  ```

  And just like that, you should be all set to send emails with Resend!
  """

  @behaviour Swoosh.Adapter

  @impl true
  def deliver(%Swoosh.Email{} = email, config) do
    Resend.Email.send(Resend.client(config), %{
      subject: email.subject,
      from: format_sender(email.from),
      to: format_recipients(email.to),
      bcc: format_recipients(email.bcc),
      cc: format_recipients(email.cc),
      reply_to: email.reply_to,
      html: email.html_body,
      text: email.text_body
    })
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
    Resend.validate_config!(config)
    :ok
  end

  defp format_sender(from) when is_binary(from), do: from
  defp format_sender({"", from}), do: from
  defp format_sender({from_name, from}), do: "#{from_name} <#{from}>"

  defp format_recipients(to) when is_binary(to), do: to
  defp format_recipients({_ignore, to}), do: to
  defp format_recipients(xs) when is_list(xs), do: Enum.map(xs, &format_recipients/1)
end
