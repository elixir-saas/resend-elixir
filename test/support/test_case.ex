defmodule Resend.TestCase do
  defmacro __using__(_opts) do
    quote do
      use ExUnit.Case
      import Resend.TestCase
    end
  end

  # Unit tests are never in live mode
  defmacro live_mode?() do
    false
  end

  def setup_env(_context) do
    # Always use the mock API key for unit tests (matches config/test.exs)
    %{
      to: "test@example.com",
      from: "sender@example.com",
      sent_email_id: "f524bc41-316b-45c6-99f3-c5d3bc193d12",
      api_key: "re_123456789"
    }
  end
end
