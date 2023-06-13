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

      assert {:ok, %Resend.Email{}} = Resend.Email.send(Map.new(opts))
    end

    test "Gets an email by ID", context do
      email_id = context.sent_email_id
      to = context.to
      from = context.from

      ClientMock.mock_get_email(context)

      assert {:ok, %Resend.Email{id: ^email_id, to: [^to], from: ^from}} =
               Resend.Email.get(email_id)
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
                 Resend.Email.get(email_id)
      end
    end
  end
end
