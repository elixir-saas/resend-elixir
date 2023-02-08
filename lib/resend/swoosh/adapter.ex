defmodule Resend.Swoosh.Adapter do
  @behaviour Swoosh.Adapter

  @impl true
  def deliver(%Swoosh.Email{} = email, config) do
    Resend.Email.send(config, %{
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
