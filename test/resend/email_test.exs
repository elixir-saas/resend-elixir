defmodule Resend.EmailTest do
  use Resend.TestCase

  alias Resend.ClientMock

  setup :setup_env

  describe "/email" do
    test "Sends an email with a text body", context do
      to = context.to
      from = context.from
      subject = "Test Email"
      text = "Testing Resend"

      opts = [to: to, subject: subject, from: from, text: text]
      ClientMock.mock_send_email(context, assert_fields: opts)

      assert {:ok, %Resend.Email{to: ^to, from: ^from}} = Resend.Email.send(Map.new(opts))
    end
  end
end
