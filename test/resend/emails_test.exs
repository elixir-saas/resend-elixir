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

      ClientMock.mock_request(context,
        method: :post,
        path: "/emails",
        response: %{"id" => context.sent_email_id},
        assert_body: fn body ->
          assert body["to"] == to
          assert body["from"] == from
          assert body["subject"] == subject
          assert body["text"] == text
          assert body["headers"] == headers
        end
      )

      opts = %{
        to: to,
        subject: subject,
        from: from,
        text: text,
        headers: headers
      }

      assert {:ok, %Resend.Emails.Email{}} = Resend.Emails.send(opts)
    end

    test "Gets an email by ID", context do
      email_id = context.sent_email_id
      to = context.to
      from = context.from

      ClientMock.mock_request(context,
        method: :get,
        path: "/emails/#{email_id}",
        response: %{
          "id" => email_id,
          "from" => from,
          "to" => [to],
          "subject" => "Test Email",
          "text" => "Testing Resend",
          "last_event" => "delivered",
          "created_at" => "2023-06-01T00:00:00.000Z"
        }
      )

      assert {:ok, %Resend.Emails.Email{id: ^email_id, to: [^to], from: ^from}} =
               Resend.Emails.get(email_id)
    end

    if not live_mode?() do
      test "Returns an error", context do
        email_id = context.sent_email_id

        ClientMock.mock_request(context,
          method: :get,
          path: "/emails/#{email_id}",
          status: 401,
          response: %{
            "message" => "This API key is restricted to only send emails",
            "name" => "restricted_api_key",
            "statusCode" => 401
          }
        )

        assert {:error, %Resend.Error{name: "restricted_api_key", status_code: 401}} =
                 Resend.Emails.get(email_id)
      end
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

    test "list/1 lists all sent emails", context do
      ClientMock.mock_request(context,
        method: :get,
        path: "/emails",
        response: %{
          "data" => [
            %{
              "id" => context.sent_email_id,
              "from" => context.from,
              "to" => [context.to],
              "subject" => "Test Email"
            },
            %{
              "id" => "email_987654321",
              "from" => context.from,
              "to" => ["other@example.com"],
              "subject" => "Another Email"
            }
          ]
        }
      )

      assert {:ok, %Resend.List{data: emails}} = Resend.Emails.list()
      assert length(emails) == 2
    end

    test "send_batch/2 sends multiple emails", context do
      Tesla.Mock.mock(fn request ->
        assert request.method == :post
        assert request.url == "https://api.resend.com/emails/batch"

        body = Jason.decode!(request.body)
        assert is_list(body)
        assert length(body) == 2

        %Tesla.Env{
          status: 200,
          body: %{
            "data" => [
              %{"id" => "email_1"},
              %{"id" => "email_2"}
            ]
          }
        }
      end)

      emails = [
        %{to: "user1@example.com", from: context.from, subject: "Email 1", text: "Hello 1"},
        %{to: "user2@example.com", from: context.from, subject: "Email 2", text: "Hello 2"}
      ]

      assert {:ok, %Resend.Emails.BatchResponse{data: [%{id: "email_1"}, %{id: "email_2"}]}} =
               Resend.Emails.send_batch(emails)
    end

    test "update/3 updates a scheduled email", context do
      scheduled_at = "2024-12-25T10:00:00.000Z"

      ClientMock.mock_request(context,
        method: :patch,
        path: "/emails/#{context.sent_email_id}",
        response: %{
          "id" => context.sent_email_id,
          "scheduled_at" => scheduled_at
        },
        assert_body: fn body ->
          assert body["scheduled_at"] == scheduled_at
        end
      )

      assert {:ok, %Resend.Emails.Email{id: id}} =
               Resend.Emails.update(context.sent_email_id, scheduled_at: scheduled_at)

      assert id == context.sent_email_id
    end

    test "cancel/2 cancels a scheduled email", context do
      ClientMock.mock_request(context,
        method: :post,
        path: "/emails/#{context.sent_email_id}/cancel",
        response: %{
          "id" => context.sent_email_id,
          "last_event" => "cancelled"
        }
      )

      assert {:ok, %Resend.Emails.Email{last_event: "cancelled"}} =
               Resend.Emails.cancel(context.sent_email_id)
    end

    test "list_attachments/2 lists attachments for an email", context do
      ClientMock.mock_request(context,
        method: :get,
        path: "/emails/#{context.sent_email_id}/attachments",
        response: %{
          "data" => [
            %{"filename" => "doc.pdf", "content_type" => "application/pdf"},
            %{"filename" => "image.png", "content_type" => "image/png"}
          ]
        }
      )

      assert {:ok, %Resend.List{data: attachments}} =
               Resend.Emails.list_attachments(context.sent_email_id)

      assert length(attachments) == 2
    end

    test "get_attachment/3 gets a specific attachment", context do
      attachment_id = "att_123456789"

      ClientMock.mock_request(context,
        method: :get,
        path: "/emails/#{context.sent_email_id}/attachments/#{attachment_id}",
        response: %{
          "filename" => "document.pdf",
          "content_type" => "application/pdf",
          "content" => "base64content"
        }
      )

      assert {:ok, %Resend.Emails.Attachment{filename: "document.pdf"}} =
               Resend.Emails.get_attachment(context.sent_email_id, attachment_id)
    end
  end
end
