defmodule Resend.EmailsTest do
  use Resend.TestCase

  alias Resend.ClientMock

  setup :setup_env

  describe "/emails" do
    test "Sends an email with a text body", context do
      to = context.to
      from = context.from
      subject = "Test Email"
      text = "Testing Resend"
      headers = %{"x-test-header" => "resend-elixir"}

      opts = [
        to: to,
        subject: subject,
        from: from,
        text: text,
        headers: headers
      ]

      ClientMock.mock_send_email(context, assert_fields: opts)

      assert {:ok, %Resend.Emails.Email{}} = Resend.Emails.send(Map.new(opts))
    end

    test "Gets an email by ID", context do
      email_id = context.sent_email_id
      to = context.to
      from = context.from

      ClientMock.mock_get_email(context)

      assert {:ok, %Resend.Emails.Email{id: ^email_id, to: [^to], from: ^from}} =
               Resend.Emails.get(email_id)
    end

    if not live_mode?() do
      test "Returns an error", context do
        email_id = context.sent_email_id

        ClientMock.mock_get_email(context,
          respond_with:
            {401,
             %{
               "message" => "This API key is restricted to only send emails",
               "name" => "restricted_api_key",
               "statusCode" => 401
             }}
        )

        assert {:error, %Resend.Error{name: "restricted_api_key", status_code: 401}} =
                 Resend.Emails.get(email_id)
      end
    end
  end
end
