defmodule Resend.TestCase do
  defmacro __using__(_opts) do
    quote do
      use ExUnit.Case
      import Resend.TestCase
    end
  end

  def setup_env(_context) do
    %{
      to: System.get_env("RECIPIENT_EMAIL", "test@example.com"),
      from: System.get_env("SENDER_EMAIL", "sender@example.com"),
      api_key: System.get_env("RESEND_KEY", "re_123456789")
    }
  end
end
