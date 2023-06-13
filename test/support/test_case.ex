defmodule Resend.TestCase do
  defmacro __using__(_opts) do
    quote do
      use ExUnit.Case
      import Resend.TestCase
    end
  end

  defmacro live_mode?() do
    quote do
      Application.compile_env!(:resend, :live_mode)
    end
  end

  def setup_env(_context) do
    %{
      to: System.get_env("RECIPIENT_EMAIL", "test@example.com"),
      from: System.get_env("SENDER_EMAIL", "sender@example.com"),
      sent_email_id: System.get_env("SENT_EMAIL_ID", "f524bc41-316b-45c6-99f3-c5d3bc193d12"),
      api_key: System.get_env("RESEND_KEY", "re_123456789")
    }
  end
end
