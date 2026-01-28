defmodule Resend.WebhooksTest do
  use Resend.TestCase

  alias Resend.ClientMock

  setup :setup_env

  @webhook_id "wh_123456789"

  describe "Webhooks" do
    test "create/2 creates a new webhook", context do
      ClientMock.mock_request(context,
        method: :post,
        path: "/webhooks",
        response: %{
          "id" => @webhook_id,
          "endpoint" => "https://example.com/webhook",
          "events" => ["email.sent", "email.delivered"],
          "signing_secret" => "whsec_xxx"
        },
        assert_body: fn body ->
          assert body["endpoint"] == "https://example.com/webhook"
          assert body["events"] == ["email.sent", "email.delivered"]
        end
      )

      assert {:ok, %Resend.Webhooks.Webhook{id: @webhook_id, signing_secret: "whsec_xxx"}} =
               Resend.Webhooks.create(
                 endpoint: "https://example.com/webhook",
                 events: ["email.sent", "email.delivered"]
               )
    end

    test "list/1 lists all webhooks", context do
      ClientMock.mock_request(context,
        method: :get,
        path: "/webhooks",
        response: %{
          "data" => [
            %{"id" => @webhook_id, "endpoint" => "https://example.com/webhook"},
            %{"id" => "wh_987654321", "endpoint" => "https://other.com/webhook"}
          ]
        }
      )

      assert {:ok, %Resend.List{data: webhooks}} = Resend.Webhooks.list()
      assert length(webhooks) == 2
    end

    test "get/2 gets a webhook by ID", context do
      ClientMock.mock_request(context,
        method: :get,
        path: "/webhooks/#{@webhook_id}",
        response: %{
          "id" => @webhook_id,
          "endpoint" => "https://example.com/webhook",
          "events" => ["email.sent"],
          "created_at" => "2023-06-01T00:00:00.000Z"
        }
      )

      assert {:ok, %Resend.Webhooks.Webhook{id: @webhook_id, events: ["email.sent"]}} =
               Resend.Webhooks.get(@webhook_id)
    end

    test "update/3 updates a webhook", context do
      ClientMock.mock_request(context,
        method: :patch,
        path: "/webhooks/#{@webhook_id}",
        response: %{
          "id" => @webhook_id,
          "endpoint" => "https://new-url.com/webhook",
          "events" => ["email.sent", "email.bounced"]
        },
        assert_body: fn body ->
          assert body["endpoint"] == "https://new-url.com/webhook"
        end
      )

      assert {:ok, %Resend.Webhooks.Webhook{endpoint: "https://new-url.com/webhook"}} =
               Resend.Webhooks.update(@webhook_id, endpoint: "https://new-url.com/webhook")
    end

    test "remove/2 removes a webhook", context do
      ClientMock.mock_request(context,
        method: :delete,
        path: "/webhooks/#{@webhook_id}",
        response: %{}
      )

      assert {:ok, %Resend.Empty{}} = Resend.Webhooks.remove(@webhook_id)
    end
  end
end
