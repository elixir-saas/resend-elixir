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

    test "Sends an email with a template", context do
      to = context.to
      from = context.from
      template_id = "order-confirmation"
      variables = %{PRODUCT: "Vintage Macintosh", PRICE: 499}

      opts = [
        to: to,
        from: from,
        template: %{
          id: template_id,
          variables: variables
        }
      ]

      Tesla.Mock.mock(fn request ->
        assert request.method == :post
        assert request.url == "https://api.resend.com/emails"

        body = Jason.decode!(request.body)

        # Assert template fields are present
        assert body["template"]["id"] == template_id
        assert body["template"]["variables"]["PRODUCT"] == "Vintage Macintosh"
        assert body["template"]["variables"]["PRICE"] == 499

        %Tesla.Env{status: 200, body: %{"id" => context.sent_email_id}}
      end)

      assert {:ok, %Resend.Emails.Email{}} = Resend.Emails.send(Map.new(opts))
    end

    test "Sends email with template via Swoosh adapter", context do
      # Create Swoosh email with template in provider_options
      email =
        Swoosh.Email.new()
        |> Swoosh.Email.to(context.to)
        |> Swoosh.Email.from(context.from)
        |> Swoosh.Email.put_provider_option(:template, %{
          id: "welcome-email",
          variables: %{
            NAME: "John Doe",
            COMPANY: "Acme Corp"
          }
        })

      # Mock the API call and assert template is sent
      Tesla.Mock.mock(fn request ->
        assert request.method == :post
        assert request.url == "https://api.resend.com/emails"

        body = Jason.decode!(request.body)

        # Assert template fields are present
        assert body["template"]["id"] == "welcome-email"
        assert body["template"]["variables"]["NAME"] == "John Doe"
        assert body["template"]["variables"]["COMPANY"] == "Acme Corp"

        %Tesla.Env{status: 200, body: %{"id" => context.sent_email_id}}
      end)

      # Deliver via Swoosh adapter
      config = [api_key: context.api_key]
      assert {:ok, _} = Resend.Swoosh.Adapter.deliver(email, config)
    end

    test "Sends email without template when not present in Swoosh email", context do
      # Create regular Swoosh email without template
      email =
        Swoosh.Email.new()
        |> Swoosh.Email.to(context.to)
        |> Swoosh.Email.from(context.from)
        |> Swoosh.Email.subject("Regular Email")
        |> Swoosh.Email.text_body("This is a regular email")

      # Mock the API call
      Tesla.Mock.mock(fn request ->
        body = Jason.decode!(request.body)

        # Assert template field is not present
        refute Map.has_key?(body, "template")
        assert body["text"] == "This is a regular email"

        %Tesla.Env{status: 200, body: %{"id" => context.sent_email_id}}
      end)

      # Deliver via Swoosh adapter
      config = [api_key: context.api_key]
      assert {:ok, _} = Resend.Swoosh.Adapter.deliver(email, config)
    end

    test "Attachment struct accepts content_id field" do
      attachment = %Resend.Emails.Attachment{
        filename: "logo.jpg",
        content: "base64data",
        content_type: "image/jpeg",
        content_id: "logo-image"
      }

      assert attachment.content_id == "logo-image"
    end

    test "Attachment.cast/1 includes content_id from map" do
      map = %{
        "filename" => "logo.jpg",
        "content" => "base64data",
        "content_type" => "image/jpeg",
        "content_id" => "logo-image"
      }

      attachment = Resend.Emails.Attachment.cast(map)

      assert attachment.content_id == "logo-image"
    end

    test "Jason encoding includes content_id" do
      attachment = %Resend.Emails.Attachment{
        filename: "logo.jpg",
        content: "base64data",
        content_id: "logo-image"
      }

      json = Jason.encode!(attachment)
      decoded = Jason.decode!(json)

      assert decoded["content_id"] == "logo-image"
    end

    test "Handles nil content_id gracefully" do
      attachment = %Resend.Emails.Attachment{
        filename: "document.pdf",
        content: "base64data"
        # content_id is nil
      }

      json = Jason.encode!(attachment)
      # Should encode without errors
      assert is_binary(json)

      decoded = Jason.decode!(json)
      # nil fields are encoded as null in JSON
      assert decoded["content_id"] == nil
    end

    test "Sends email with inline attachment via Swoosh adapter", context do
      # Create Swoosh email with inline attachment
      email =
        Swoosh.Email.new()
        |> Swoosh.Email.to(context.to)
        |> Swoosh.Email.from(context.from)
        |> Swoosh.Email.subject("Test Inline Image")
        |> Swoosh.Email.html_body(~s|<img src="cid:test-logo">|)
        |> Swoosh.Email.attachment(
          Swoosh.Attachment.new(
            {:data, "fake_binary_data"},
            filename: "logo.jpg",
            content_type: "image/jpeg",
            type: :inline,
            cid: "test-logo"
          )
        )

      # Mock the API call and assert content_id is sent
      Tesla.Mock.mock(fn request ->
        assert request.method == :post
        assert request.url == "https://api.resend.com/emails"

        body = Jason.decode!(request.body)

        # Assert attachment has content_id from Swoosh cid
        assert [attachment] = body["attachments"]
        assert attachment["content_id"] == "test-logo"
        assert attachment["filename"] == "logo.jpg"
        assert attachment["content_type"] == "image/jpeg"

        %Tesla.Env{status: 200, body: %{"id" => context.sent_email_id}}
      end)

      # Deliver via Swoosh adapter
      config = [api_key: context.api_key]
      assert {:ok, _} = Resend.Swoosh.Adapter.deliver(email, config)
    end
  end
end
