defmodule Resend.BroadcastsTest do
  use Resend.TestCase

  alias Resend.ClientMock

  setup :setup_env

  @broadcast_id "bc_123456789"
  @segment_id "seg_123456789"

  describe "Broadcasts" do
    test "create/2 creates a new broadcast", context do
      ClientMock.mock_request(context,
        method: :post,
        path: "/broadcasts",
        response: %{
          "id" => @broadcast_id,
          "name" => "My Broadcast",
          "segment_id" => @segment_id,
          "status" => "draft"
        },
        assert_body: fn body ->
          assert body["name"] == "My Broadcast"
          assert body["segment_id"] == @segment_id
        end
      )

      assert {:ok, %Resend.Broadcasts.Broadcast{id: @broadcast_id, name: "My Broadcast"}} =
               Resend.Broadcasts.create(
                 name: "My Broadcast",
                 segment_id: @segment_id,
                 from: "sender@example.com",
                 subject: "Test Subject"
               )
    end

    test "list/1 lists all broadcasts", context do
      ClientMock.mock_request(context,
        method: :get,
        path: "/broadcasts",
        response: %{
          "data" => [
            %{"id" => @broadcast_id, "name" => "Broadcast 1", "status" => "draft"},
            %{"id" => "bc_987654321", "name" => "Broadcast 2", "status" => "sent"}
          ]
        }
      )

      assert {:ok, %Resend.List{data: broadcasts}} = Resend.Broadcasts.list()
      assert length(broadcasts) == 2
      assert [%Resend.Broadcasts.Broadcast{id: @broadcast_id} | _] = broadcasts
    end

    test "get/2 gets a broadcast by ID", context do
      ClientMock.mock_request(context,
        method: :get,
        path: "/broadcasts/#{@broadcast_id}",
        response: %{
          "id" => @broadcast_id,
          "name" => "My Broadcast",
          "status" => "draft",
          "created_at" => "2023-06-01T00:00:00.000Z"
        }
      )

      assert {:ok, %Resend.Broadcasts.Broadcast{id: @broadcast_id, name: "My Broadcast"}} =
               Resend.Broadcasts.get(@broadcast_id)
    end

    test "update/3 updates a broadcast", context do
      ClientMock.mock_request(context,
        method: :patch,
        path: "/broadcasts/#{@broadcast_id}",
        response: %{
          "id" => @broadcast_id,
          "name" => "Updated Broadcast",
          "status" => "draft"
        },
        assert_body: fn body ->
          assert body["name"] == "Updated Broadcast"
        end
      )

      assert {:ok, %Resend.Broadcasts.Broadcast{name: "Updated Broadcast"}} =
               Resend.Broadcasts.update(@broadcast_id, name: "Updated Broadcast")
    end

    test "remove/2 removes a broadcast", context do
      ClientMock.mock_request(context,
        method: :delete,
        path: "/broadcasts/#{@broadcast_id}",
        response: %{}
      )

      assert {:ok, %Resend.Empty{}} = Resend.Broadcasts.remove(@broadcast_id)
    end

    test "send/2 sends a broadcast", context do
      ClientMock.mock_request(context,
        method: :post,
        path: "/broadcasts/#{@broadcast_id}/send",
        response: %{
          "id" => @broadcast_id,
          "status" => "sending"
        }
      )

      assert {:ok, %Resend.Broadcasts.Broadcast{status: "sending"}} =
               Resend.Broadcasts.send(@broadcast_id)
    end

    test "send/3 schedules a broadcast", context do
      scheduled_at = "2024-12-25T10:00:00.000Z"

      ClientMock.mock_request(context,
        method: :post,
        path: "/broadcasts/#{@broadcast_id}/send",
        response: %{
          "id" => @broadcast_id,
          "status" => "scheduled",
          "scheduled_at" => scheduled_at
        },
        assert_body: fn body ->
          assert body["scheduled_at"] == scheduled_at
        end
      )

      # Note: With default args (client \\ Resend.client(), broadcast_id, opts \\ []),
      # calling with 2 args matches (client, broadcast_id), so we pass all 3 args
      client = Resend.client(api_key: context.api_key)

      assert {:ok, %Resend.Broadcasts.Broadcast{status: "scheduled"}} =
               Resend.Broadcasts.send(client, @broadcast_id, scheduled_at: scheduled_at)
    end
  end
end
