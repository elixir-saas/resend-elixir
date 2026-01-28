defmodule Resend.ReceivedEmailsTest do
  use Resend.TestCase

  alias Resend.ClientMock

  setup :setup_env

  @email_id "recv_123456789"
  @attachment_id "att_123456789"

  describe "ReceivedEmails" do
    test "list/1 lists all received emails", context do
      ClientMock.mock_request(context,
        method: :get,
        path: "/received-emails",
        response: %{
          "data" => [
            %{
              "id" => @email_id,
              "from" => "sender@example.com",
              "to" => ["recipient@example.com"],
              "subject" => "Hello"
            },
            %{
              "id" => "recv_987654321",
              "from" => "other@example.com",
              "to" => ["recipient@example.com"],
              "subject" => "Hi there"
            }
          ]
        }
      )

      assert {:ok, %Resend.List{data: emails}} = Resend.ReceivedEmails.list()
      assert length(emails) == 2
      assert [%Resend.ReceivedEmails.ReceivedEmail{id: @email_id} | _] = emails
    end

    test "get/2 gets a received email by ID", context do
      ClientMock.mock_request(context,
        method: :get,
        path: "/received-emails/#{@email_id}",
        response: %{
          "id" => @email_id,
          "from" => "sender@example.com",
          "to" => ["recipient@example.com"],
          "subject" => "Test Email",
          "text" => "Hello world",
          "html" => "<p>Hello world</p>",
          "created_at" => "2023-06-01T00:00:00.000Z"
        }
      )

      assert {:ok,
              %Resend.ReceivedEmails.ReceivedEmail{
                id: @email_id,
                subject: "Test Email",
                text: "Hello world"
              }} = Resend.ReceivedEmails.get(@email_id)
    end

    test "list_attachments/2 lists attachments for a received email", context do
      ClientMock.mock_request(context,
        method: :get,
        path: "/received-emails/#{@email_id}/attachments",
        response: %{
          "data" => [
            %{
              "filename" => "document.pdf",
              "content_type" => "application/pdf"
            },
            %{
              "filename" => "image.png",
              "content_type" => "image/png"
            }
          ]
        }
      )

      assert {:ok, %Resend.List{data: attachments}} =
               Resend.ReceivedEmails.list_attachments(@email_id)

      assert length(attachments) == 2
    end

    test "get_attachment/3 gets a specific attachment", context do
      ClientMock.mock_request(context,
        method: :get,
        path: "/received-emails/#{@email_id}/attachments/#{@attachment_id}",
        response: %{
          "filename" => "document.pdf",
          "content_type" => "application/pdf",
          "content" => "base64encodedcontent"
        }
      )

      assert {:ok, %Resend.Emails.Attachment{filename: "document.pdf"}} =
               Resend.ReceivedEmails.get_attachment(@email_id, @attachment_id)
    end
  end
end
