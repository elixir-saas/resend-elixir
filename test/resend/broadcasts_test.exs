defmodule Resend.BroadcastsTest do
  use Resend.TestCase, async: true

  alias Resend.Broadcasts.Broadcast

  setup :setup_env

  describe "/broadcasts" do
    test "creates a broadcast", context do
      audience_id = "78261eea-8f8b-4381-83c6-79fa7120f1cf"
      broadcast_id = "b6d24b8e-af0b-4c3c-be0c-359bbd97381e"
      name = "Monthly Newsletter"
      from = "news@example.com"
      subject = "Your Monthly Update"

      Tesla.Mock.mock(fn request ->
        %{api_key: api_key} = context

        assert request.method == :post
        assert request.url == "https://api.resend.com/broadcasts"

        assert Enum.find(request.headers, &(elem(&1, 0) == "Authorization")) ==
                 {"Authorization", "Bearer #{api_key}"}

        body = Jason.decode!(request.body)
        assert body["audience_id"] == audience_id
        assert body["name"] == name
        assert body["from"] == from
        assert body["subject"] == subject

        success_body = %{
          "object" => "broadcast",
          "id" => broadcast_id,
          "audience_id" => audience_id,
          "name" => name,
          "from" => from,
          "subject" => subject,
          "status" => "draft",
          "created_at" => "2023-10-06T22:59:55.977Z"
        }

        %Tesla.Env{status: 200, body: success_body}
      end)

      assert {:ok,
              %Broadcast{
                id: ^broadcast_id,
                audience_id: ^audience_id,
                name: ^name,
                from: ^from,
                subject: ^subject,
                status: "draft"
              }} =
               Resend.Broadcasts.create(
                 audience_id: audience_id,
                 name: name,
                 from: from,
                 subject: subject
               )
    end

    test "creates a broadcast with reply_to as string", context do
      audience_id = "78261eea-8f8b-4381-83c6-79fa7120f1cf"
      broadcast_id = "b6d24b8e-af0b-4c3c-be0c-359bbd97381e"
      reply_to = "support@example.com"

      Tesla.Mock.mock(fn request ->
        %{api_key: api_key} = context

        assert request.method == :post
        assert request.url == "https://api.resend.com/broadcasts"

        assert Enum.find(request.headers, &(elem(&1, 0) == "Authorization")) ==
                 {"Authorization", "Bearer #{api_key}"}

        body = Jason.decode!(request.body)
        assert body["reply_to"] == reply_to

        success_body = %{
          "object" => "broadcast",
          "id" => broadcast_id,
          "audience_id" => audience_id,
          "name" => "Test Broadcast",
          "from" => "test@example.com",
          "subject" => "Test Subject",
          "reply_to" => reply_to,
          "status" => "draft"
        }

        %Tesla.Env{status: 200, body: success_body}
      end)

      assert {:ok, %Broadcast{id: ^broadcast_id, reply_to: ^reply_to}} =
               Resend.Broadcasts.create(
                 audience_id: audience_id,
                 name: "Test Broadcast",
                 from: "test@example.com",
                 subject: "Test Subject",
                 reply_to: reply_to
               )
    end

    test "creates a broadcast with reply_to as list", context do
      audience_id = "78261eea-8f8b-4381-83c6-79fa7120f1cf"
      broadcast_id = "b6d24b8e-af0b-4c3c-be0c-359bbd97381e"
      reply_to = ["support@example.com", "help@example.com"]

      Tesla.Mock.mock(fn request ->
        %{api_key: api_key} = context

        assert request.method == :post
        assert request.url == "https://api.resend.com/broadcasts"

        assert Enum.find(request.headers, &(elem(&1, 0) == "Authorization")) ==
                 {"Authorization", "Bearer #{api_key}"}

        body = Jason.decode!(request.body)
        assert body["reply_to"] == reply_to

        success_body = %{
          "object" => "broadcast",
          "id" => broadcast_id,
          "audience_id" => audience_id,
          "name" => "Test Broadcast",
          "from" => "test@example.com",
          "subject" => "Test Subject",
          "reply_to" => reply_to,
          "status" => "draft"
        }

        %Tesla.Env{status: 200, body: success_body}
      end)

      assert {:ok, %Broadcast{id: ^broadcast_id, reply_to: ^reply_to}} =
               Resend.Broadcasts.create(
                 audience_id: audience_id,
                 name: "Test Broadcast",
                 from: "test@example.com",
                 subject: "Test Subject",
                 reply_to: reply_to
               )
    end

    test "creates a broadcast with all optional fields", context do
      audience_id = "78261eea-8f8b-4381-83c6-79fa7120f1cf"
      broadcast_id = "b6d24b8e-af0b-4c3c-be0c-359bbd97381e"
      preview_text = "Check out our latest updates"
      html = "<h1>Newsletter</h1><p>Content here</p>"
      text = "Newsletter\n\nContent here"
      headers = %{"X-Custom" => "value"}
      attachments = [%{filename: "report.pdf", content: "base64content"}]
      tags = [%{name: "category", value: "newsletter"}]

      Tesla.Mock.mock(fn request ->
        %{api_key: api_key} = context

        assert request.method == :post
        assert request.url == "https://api.resend.com/broadcasts"

        assert Enum.find(request.headers, &(elem(&1, 0) == "Authorization")) ==
                 {"Authorization", "Bearer #{api_key}"}

        body = Jason.decode!(request.body)
        assert body["preview_text"] == preview_text
        assert body["html"] == html
        assert body["text"] == text
        assert body["headers"] == headers
        # Attachments are sent as atoms but returned as strings in JSON
        assert body["attachments"] == [
                 %{"filename" => "report.pdf", "content" => "base64content"}
               ]

        # Tags are sent as atoms but returned as strings in JSON
        assert body["tags"] == [%{"name" => "category", "value" => "newsletter"}]

        success_body = %{
          "object" => "broadcast",
          "id" => broadcast_id,
          "audience_id" => audience_id,
          "name" => "Full Broadcast",
          "from" => "test@example.com",
          "subject" => "Test Subject",
          "preview_text" => preview_text,
          "status" => "draft"
        }

        %Tesla.Env{status: 200, body: success_body}
      end)

      assert {:ok, %Broadcast{id: ^broadcast_id, preview_text: ^preview_text}} =
               Resend.Broadcasts.create(
                 audience_id: audience_id,
                 name: "Full Broadcast",
                 from: "test@example.com",
                 subject: "Test Subject",
                 preview_text: preview_text,
                 html: html,
                 text: text,
                 headers: headers,
                 attachments: attachments,
                 tags: tags
               )
    end

    test "lists all broadcasts", context do
      broadcast_id_1 = "b6d24b8e-af0b-4c3c-be0c-359bbd97381e"
      broadcast_id_2 = "a5d24b8e-af0b-4c3c-be0c-359bbd97382f"

      Tesla.Mock.mock(fn request ->
        %{api_key: api_key} = context

        assert request.method == :get
        assert request.url == "https://api.resend.com/broadcasts"

        assert Enum.find(request.headers, &(elem(&1, 0) == "Authorization")) ==
                 {"Authorization", "Bearer #{api_key}"}

        success_body = %{
          "object" => "list",
          "data" => [
            %{
              "id" => broadcast_id_1,
              "audience_id" => "78261eea-8f8b-4381-83c6-79fa7120f1cf",
              "name" => "Monthly Newsletter",
              "from" => "news@example.com",
              "subject" => "October Update",
              "status" => "sent",
              "created_at" => "2023-10-06T22:59:55.977Z",
              "sent_at" => "2023-10-07T09:00:00.000Z"
            },
            %{
              "id" => broadcast_id_2,
              "audience_id" => "78261eea-8f8b-4381-83c6-79fa7120f1cf",
              "name" => "Weekly Digest",
              "from" => "digest@example.com",
              "subject" => "This Week's Highlights",
              "status" => "draft",
              "created_at" => "2023-10-08T10:30:00.000Z"
            }
          ]
        }

        %Tesla.Env{status: 200, body: success_body}
      end)

      assert {:ok,
              %Resend.List{
                data: [
                  %Broadcast{id: ^broadcast_id_1, status: "sent"},
                  %Broadcast{id: ^broadcast_id_2, status: "draft"}
                ]
              }} = Resend.Broadcasts.list()
    end

    test "gets a broadcast by ID", context do
      broadcast_id = "b6d24b8e-af0b-4c3c-be0c-359bbd97381e"
      audience_id = "78261eea-8f8b-4381-83c6-79fa7120f1cf"
      name = "Monthly Newsletter"

      Tesla.Mock.mock(fn request ->
        %{api_key: api_key} = context

        assert request.method == :get
        assert request.url == "https://api.resend.com/broadcasts/#{broadcast_id}"

        assert Enum.find(request.headers, &(elem(&1, 0) == "Authorization")) ==
                 {"Authorization", "Bearer #{api_key}"}

        success_body = %{
          "object" => "broadcast",
          "id" => broadcast_id,
          "audience_id" => audience_id,
          "name" => name,
          "from" => "news@example.com",
          "subject" => "October Update",
          "status" => "sent",
          "created_at" => "2023-10-06T22:59:55.977Z",
          "sent_at" => "2023-10-07T09:00:00.000Z"
        }

        %Tesla.Env{status: 200, body: success_body}
      end)

      assert {:ok,
              %Broadcast{
                id: ^broadcast_id,
                audience_id: ^audience_id,
                name: ^name,
                status: "sent"
              }} = Resend.Broadcasts.get(broadcast_id)
    end

    test "updates a broadcast", context do
      broadcast_id = "b6d24b8e-af0b-4c3c-be0c-359bbd97381e"
      new_subject = "Updated Newsletter Subject"
      new_preview_text = "New preview text"

      Tesla.Mock.mock(fn request ->
        %{api_key: api_key} = context

        assert request.method == :patch
        assert request.url == "https://api.resend.com/broadcasts/#{broadcast_id}"

        assert Enum.find(request.headers, &(elem(&1, 0) == "Authorization")) ==
                 {"Authorization", "Bearer #{api_key}"}

        body = Jason.decode!(request.body)
        assert body["subject"] == new_subject
        assert body["preview_text"] == new_preview_text
        # Should not include nil values
        refute Map.has_key?(body, "name")
        refute Map.has_key?(body, "from")

        success_body = %{
          "object" => "broadcast",
          "id" => broadcast_id,
          "audience_id" => "78261eea-8f8b-4381-83c6-79fa7120f1cf",
          "name" => "Monthly Newsletter",
          "from" => "news@example.com",
          "subject" => new_subject,
          "preview_text" => new_preview_text,
          "status" => "draft"
        }

        %Tesla.Env{status: 200, body: success_body}
      end)

      assert {:ok,
              %Broadcast{
                id: ^broadcast_id,
                subject: ^new_subject,
                preview_text: ^new_preview_text
              }} =
               Resend.Broadcasts.update(broadcast_id,
                 subject: new_subject,
                 preview_text: new_preview_text
               )
    end

    test "updates a broadcast with reply_to", context do
      broadcast_id = "b6d24b8e-af0b-4c3c-be0c-359bbd97381e"
      new_reply_to = ["noreply@example.com", "support@example.com"]

      Tesla.Mock.mock(fn request ->
        %{api_key: api_key} = context

        assert request.method == :patch
        assert request.url == "https://api.resend.com/broadcasts/#{broadcast_id}"

        assert Enum.find(request.headers, &(elem(&1, 0) == "Authorization")) ==
                 {"Authorization", "Bearer #{api_key}"}

        body = Jason.decode!(request.body)
        assert body["reply_to"] == new_reply_to
        assert Map.keys(body) == ["reply_to"]

        success_body = %{
          "object" => "broadcast",
          "id" => broadcast_id,
          "audience_id" => "78261eea-8f8b-4381-83c6-79fa7120f1cf",
          "name" => "Monthly Newsletter",
          "from" => "news@example.com",
          "subject" => "October Update",
          "reply_to" => new_reply_to,
          "status" => "draft"
        }

        %Tesla.Env{status: 200, body: success_body}
      end)

      assert {:ok, %Broadcast{id: ^broadcast_id, reply_to: ^new_reply_to}} =
               Resend.Broadcasts.update(broadcast_id, reply_to: new_reply_to)
    end

    test "sends a broadcast immediately", context do
      broadcast_id = "b6d24b8e-af0b-4c3c-be0c-359bbd97381e"

      Tesla.Mock.mock(fn request ->
        %{api_key: api_key} = context

        assert request.method == :post
        assert request.url == "https://api.resend.com/broadcasts/#{broadcast_id}/send"

        assert Enum.find(request.headers, &(elem(&1, 0) == "Authorization")) ==
                 {"Authorization", "Bearer #{api_key}"}

        body = Jason.decode!(request.body)
        assert body == %{}

        success_body = %{
          "object" => "broadcast",
          "id" => broadcast_id,
          "audience_id" => "78261eea-8f8b-4381-83c6-79fa7120f1cf",
          "name" => "Monthly Newsletter",
          "from" => "news@example.com",
          "subject" => "October Update",
          "status" => "sending",
          "sent_at" => "2023-10-07T09:00:00.000Z"
        }

        %Tesla.Env{status: 200, body: success_body}
      end)

      assert {:ok, %Broadcast{id: ^broadcast_id, status: "sending"}} =
               Resend.Broadcasts.send(broadcast_id)
    end

    test "schedules a broadcast for later", context do
      broadcast_id = "b6d24b8e-af0b-4c3c-be0c-359bbd97381e"
      scheduled_at = ~U[2024-12-25 09:00:00Z]

      Tesla.Mock.mock(fn request ->
        %{api_key: api_key} = context

        assert request.method == :post
        assert request.url == "https://api.resend.com/broadcasts/#{broadcast_id}/send"

        assert Enum.find(request.headers, &(elem(&1, 0) == "Authorization")) ==
                 {"Authorization", "Bearer #{api_key}"}

        body = Jason.decode!(request.body)
        assert body["scheduled_at"] == DateTime.to_iso8601(scheduled_at)

        success_body = %{
          "object" => "broadcast",
          "id" => broadcast_id,
          "audience_id" => "78261eea-8f8b-4381-83c6-79fa7120f1cf",
          "name" => "Christmas Newsletter",
          "from" => "news@example.com",
          "subject" => "Happy Holidays!",
          "status" => "scheduled",
          "scheduled_at" => DateTime.to_iso8601(scheduled_at)
        }

        %Tesla.Env{status: 200, body: success_body}
      end)

      # Fix: The function signature is send(client \\ Resend.client(), broadcast_id, opts \\ [])
      # When called with 2 args, the second arg is interpreted as broadcast_id
      # So we need to use the default client and pass broadcast_id and opts
      assert {:ok, %Broadcast{id: ^broadcast_id, status: "scheduled"}} =
               Resend.Broadcasts.send(Resend.client(), broadcast_id, scheduled_at: scheduled_at)
    end

    test "cancels a scheduled broadcast", context do
      broadcast_id = "b6d24b8e-af0b-4c3c-be0c-359bbd97381e"

      Tesla.Mock.mock(fn request ->
        %{api_key: api_key} = context

        assert request.method == :post
        assert request.url == "https://api.resend.com/broadcasts/#{broadcast_id}/send"

        assert Enum.find(request.headers, &(elem(&1, 0) == "Authorization")) ==
                 {"Authorization", "Bearer #{api_key}"}

        body = Jason.decode!(request.body)
        assert body["scheduled_at"] == nil

        success_body = %{
          "object" => "broadcast",
          "id" => broadcast_id,
          "audience_id" => "78261eea-8f8b-4381-83c6-79fa7120f1cf",
          "name" => "Cancelled Newsletter",
          "from" => "news@example.com",
          "subject" => "This was cancelled",
          "status" => "cancelled"
        }

        %Tesla.Env{status: 200, body: success_body}
      end)

      # Fix: Same issue here, need to use proper argument order
      assert {:ok, %Broadcast{id: ^broadcast_id, status: "cancelled"}} =
               Resend.Broadcasts.send(Resend.client(), broadcast_id, scheduled_at: nil)
    end

    test "removes a broadcast by ID", context do
      broadcast_id = "b6d24b8e-af0b-4c3c-be0c-359bbd97381e"

      Tesla.Mock.mock(fn request ->
        %{api_key: api_key} = context

        assert request.method == :delete
        assert request.url == "https://api.resend.com/broadcasts/#{broadcast_id}"

        assert Enum.find(request.headers, &(elem(&1, 0) == "Authorization")) ==
                 {"Authorization", "Bearer #{api_key}"}

        success_body = %{
          "object" => "broadcast",
          "id" => broadcast_id,
          "deleted" => true
        }

        %Tesla.Env{status: 200, body: success_body}
      end)

      assert {:ok, %Broadcast{id: ^broadcast_id, deleted: true}} =
               Resend.Broadcasts.remove(broadcast_id)
    end

    if not live_mode?() do
      test "returns an error when creating broadcast fails", context do
        Tesla.Mock.mock(fn request ->
          %{api_key: api_key} = context

          assert request.method == :post
          assert request.url == "https://api.resend.com/broadcasts"

          assert Enum.find(request.headers, &(elem(&1, 0) == "Authorization")) ==
                   {"Authorization", "Bearer #{api_key}"}

          error_body = %{
            "message" => "Audience ID is required",
            "name" => "validation_error",
            "statusCode" => 400
          }

          %Tesla.Env{status: 400, body: error_body}
        end)

        assert {:error, %Resend.Error{name: "validation_error", status_code: 400}} =
                 Resend.Broadcasts.create(
                   audience_id: nil,
                   name: "Test",
                   from: "test@example.com",
                   subject: "Test"
                 )
      end

      test "returns an error when broadcast not found", context do
        broadcast_id = "non-existent-id"

        Tesla.Mock.mock(fn request ->
          %{api_key: api_key} = context

          assert request.method == :get
          assert request.url == "https://api.resend.com/broadcasts/#{broadcast_id}"

          assert Enum.find(request.headers, &(elem(&1, 0) == "Authorization")) ==
                   {"Authorization", "Bearer #{api_key}"}

          error_body = %{
            "message" => "Broadcast not found",
            "name" => "not_found",
            "statusCode" => 404
          }

          %Tesla.Env{status: 404, body: error_body}
        end)

        assert {:error, %Resend.Error{name: "not_found", status_code: 404}} =
                 Resend.Broadcasts.get(broadcast_id)
      end

      test "returns an error when updating a sent broadcast", context do
        broadcast_id = "b6d24b8e-af0b-4c3c-be0c-359bbd97381e"

        Tesla.Mock.mock(fn request ->
          %{api_key: api_key} = context

          assert request.method == :patch
          assert request.url == "https://api.resend.com/broadcasts/#{broadcast_id}"

          assert Enum.find(request.headers, &(elem(&1, 0) == "Authorization")) ==
                   {"Authorization", "Bearer #{api_key}"}

          error_body = %{
            "message" => "Cannot update a broadcast that has been sent",
            "name" => "invalid_request_error",
            "statusCode" => 400
          }

          %Tesla.Env{status: 400, body: error_body}
        end)

        assert {:error, %Resend.Error{name: "invalid_request_error", status_code: 400}} =
                 Resend.Broadcasts.update(broadcast_id, subject: "New subject")
      end

      test "returns an error when sending a broadcast that's already sent", context do
        broadcast_id = "b6d24b8e-af0b-4c3c-be0c-359bbd97381e"

        Tesla.Mock.mock(fn request ->
          %{api_key: api_key} = context

          assert request.method == :post
          assert request.url == "https://api.resend.com/broadcasts/#{broadcast_id}/send"

          assert Enum.find(request.headers, &(elem(&1, 0) == "Authorization")) ==
                   {"Authorization", "Bearer #{api_key}"}

          error_body = %{
            "message" => "Broadcast has already been sent",
            "name" => "invalid_request_error",
            "statusCode" => 400
          }

          %Tesla.Env{status: 400, body: error_body}
        end)

        assert {:error, %Resend.Error{name: "invalid_request_error", status_code: 400}} =
                 Resend.Broadcasts.send(broadcast_id)
      end

      test "returns an error when removing a sent broadcast", context do
        broadcast_id = "b6d24b8e-af0b-4c3c-be0c-359bbd97381e"

        Tesla.Mock.mock(fn request ->
          %{api_key: api_key} = context

          assert request.method == :delete
          assert request.url == "https://api.resend.com/broadcasts/#{broadcast_id}"

          assert Enum.find(request.headers, &(elem(&1, 0) == "Authorization")) ==
                   {"Authorization", "Bearer #{api_key}"}

          error_body = %{
            "message" => "Cannot delete a broadcast that has been sent",
            "name" => "invalid_request_error",
            "statusCode" => 400
          }

          %Tesla.Env{status: 400, body: error_body}
        end)

        assert {:error, %Resend.Error{name: "invalid_request_error", status_code: 400}} =
                 Resend.Broadcasts.remove(broadcast_id)
      end
    end
  end

  describe "with custom client" do
    test "creates a broadcast with custom client", _context do
      audience_id = "78261eea-8f8b-4381-83c6-79fa7120f1cf"
      broadcast_id = "b6d24b8e-af0b-4c3c-be0c-359bbd97381e"
      custom_client = Resend.client(api_key: "re_custom_key")

      Tesla.Mock.mock(fn request ->
        assert request.method == :post
        assert request.url == "https://api.resend.com/broadcasts"

        assert Enum.find(request.headers, &(elem(&1, 0) == "Authorization")) ==
                 {"Authorization", "Bearer re_custom_key"}

        body = Jason.decode!(request.body)
        assert body["audience_id"] == audience_id

        success_body = %{
          "object" => "broadcast",
          "id" => broadcast_id,
          "audience_id" => audience_id,
          "name" => "Test Broadcast",
          "from" => "test@example.com",
          "subject" => "Test Subject",
          "status" => "draft"
        }

        %Tesla.Env{status: 200, body: success_body}
      end)

      assert {:ok, %Broadcast{id: ^broadcast_id}} =
               Resend.Broadcasts.create(custom_client,
                 audience_id: audience_id,
                 name: "Test Broadcast",
                 from: "test@example.com",
                 subject: "Test Subject"
               )
    end

    test "lists broadcasts with custom client", _context do
      custom_client = Resend.client(api_key: "re_custom_key")

      Tesla.Mock.mock(fn request ->
        assert request.method == :get
        assert request.url == "https://api.resend.com/broadcasts"

        assert Enum.find(request.headers, &(elem(&1, 0) == "Authorization")) ==
                 {"Authorization", "Bearer re_custom_key"}

        success_body = %{
          "object" => "list",
          "data" => []
        }

        %Tesla.Env{status: 200, body: success_body}
      end)

      assert {:ok, %Resend.List{data: []}} = Resend.Broadcasts.list(custom_client)
    end

    test "gets a broadcast with custom client", _context do
      broadcast_id = "b6d24b8e-af0b-4c3c-be0c-359bbd97381e"
      custom_client = Resend.client(api_key: "re_custom_key")

      Tesla.Mock.mock(fn request ->
        assert request.method == :get
        assert request.url == "https://api.resend.com/broadcasts/#{broadcast_id}"

        assert Enum.find(request.headers, &(elem(&1, 0) == "Authorization")) ==
                 {"Authorization", "Bearer re_custom_key"}

        success_body = %{
          "object" => "broadcast",
          "id" => broadcast_id,
          "audience_id" => "78261eea-8f8b-4381-83c6-79fa7120f1cf",
          "name" => "Test Broadcast",
          "from" => "test@example.com",
          "subject" => "Test Subject",
          "status" => "draft"
        }

        %Tesla.Env{status: 200, body: success_body}
      end)

      assert {:ok, %Broadcast{id: ^broadcast_id}} =
               Resend.Broadcasts.get(custom_client, broadcast_id)
    end

    test "updates a broadcast with custom client", _context do
      broadcast_id = "b6d24b8e-af0b-4c3c-be0c-359bbd97381e"
      custom_client = Resend.client(api_key: "re_custom_key")

      Tesla.Mock.mock(fn request ->
        assert request.method == :patch
        assert request.url == "https://api.resend.com/broadcasts/#{broadcast_id}"

        assert Enum.find(request.headers, &(elem(&1, 0) == "Authorization")) ==
                 {"Authorization", "Bearer re_custom_key"}

        success_body = %{
          "object" => "broadcast",
          "id" => broadcast_id,
          "audience_id" => "78261eea-8f8b-4381-83c6-79fa7120f1cf",
          "name" => "Updated Broadcast",
          "from" => "test@example.com",
          "subject" => "Updated Subject",
          "status" => "draft"
        }

        %Tesla.Env{status: 200, body: success_body}
      end)

      assert {:ok, %Broadcast{id: ^broadcast_id}} =
               Resend.Broadcasts.update(custom_client, broadcast_id, subject: "Updated Subject")
    end

    test "sends a broadcast with custom client", _context do
      broadcast_id = "b6d24b8e-af0b-4c3c-be0c-359bbd97381e"
      custom_client = Resend.client(api_key: "re_custom_key")

      Tesla.Mock.mock(fn request ->
        assert request.method == :post
        assert request.url == "https://api.resend.com/broadcasts/#{broadcast_id}/send"

        assert Enum.find(request.headers, &(elem(&1, 0) == "Authorization")) ==
                 {"Authorization", "Bearer re_custom_key"}

        success_body = %{
          "object" => "broadcast",
          "id" => broadcast_id,
          "audience_id" => "78261eea-8f8b-4381-83c6-79fa7120f1cf",
          "name" => "Test Broadcast",
          "from" => "test@example.com",
          "subject" => "Test Subject",
          "status" => "sending"
        }

        %Tesla.Env{status: 200, body: success_body}
      end)

      assert {:ok, %Broadcast{id: ^broadcast_id, status: "sending"}} =
               Resend.Broadcasts.send(custom_client, broadcast_id)
    end

    test "removes a broadcast with custom client", _context do
      broadcast_id = "b6d24b8e-af0b-4c3c-be0c-359bbd97381e"
      custom_client = Resend.client(api_key: "re_custom_key")

      Tesla.Mock.mock(fn request ->
        assert request.method == :delete
        assert request.url == "https://api.resend.com/broadcasts/#{broadcast_id}"

        assert Enum.find(request.headers, &(elem(&1, 0) == "Authorization")) ==
                 {"Authorization", "Bearer re_custom_key"}

        success_body = %{
          "object" => "broadcast",
          "id" => broadcast_id,
          "deleted" => true
        }

        %Tesla.Env{status: 200, body: success_body}
      end)

      assert {:ok, %Broadcast{id: ^broadcast_id, deleted: true}} =
               Resend.Broadcasts.remove(custom_client, broadcast_id)
    end
  end
end
