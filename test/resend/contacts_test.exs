defmodule Resend.ContactsTest do
  use Resend.TestCase

  alias Resend.ClientMock

  setup :setup_env

  @contact_id "ct_123456789"
  @segment_id "seg_123456789"

  describe "Contacts" do
    test "create/2 creates a new contact", context do
      ClientMock.mock_request(context,
        method: :post,
        path: "/contacts",
        response: %{
          "id" => @contact_id,
          "email" => "john@example.com",
          "first_name" => "John",
          "last_name" => "Doe"
        },
        assert_body: fn body ->
          assert body["email"] == "john@example.com"
          assert body["first_name"] == "John"
        end
      )

      assert {:ok, %Resend.Contacts.Contact{id: @contact_id, email: "john@example.com"}} =
               Resend.Contacts.create(
                 email: "john@example.com",
                 first_name: "John",
                 last_name: "Doe"
               )
    end

    test "list/1 lists all contacts", context do
      ClientMock.mock_request(context,
        method: :get,
        path: "/contacts",
        response: %{
          "data" => [
            %{"id" => @contact_id, "email" => "john@example.com"},
            %{"id" => "ct_987654321", "email" => "jane@example.com"}
          ]
        }
      )

      assert {:ok, %Resend.List{data: contacts}} = Resend.Contacts.list()
      assert length(contacts) == 2
    end

    test "list/2 lists contacts filtered by segment_id", _context do
      Req.Test.stub(Resend.ReqStub, fn conn ->
        assert conn.method == "GET"
        assert conn.request_path == "/contacts"
        assert conn.query_string == "segment_id=#{@segment_id}"

        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.send_resp(
          200,
          Jason.encode!(%{
            "data" => [
              %{"id" => @contact_id, "email" => "john@example.com"}
            ]
          })
        )
      end)

      assert {:ok, %Resend.List{data: contacts}} =
               Resend.Contacts.list(segment_id: @segment_id)

      assert length(contacts) == 1
    end

    test "get/2 gets a contact by ID", context do
      ClientMock.mock_request(context,
        method: :get,
        path: "/contacts/#{@contact_id}",
        response: %{
          "id" => @contact_id,
          "email" => "john@example.com",
          "first_name" => "John",
          "created_at" => "2023-06-01T00:00:00.000Z"
        }
      )

      assert {:ok, %Resend.Contacts.Contact{id: @contact_id, first_name: "John"}} =
               Resend.Contacts.get(@contact_id)
    end

    test "get/2 gets a contact by email", context do
      email = "john@example.com"
      # Tesla URL-encodes path parameters
      encoded_email = URI.encode_www_form(email)

      ClientMock.mock_request(context,
        method: :get,
        path: "/contacts/#{encoded_email}",
        response: %{
          "id" => @contact_id,
          "email" => email,
          "first_name" => "John"
        }
      )

      assert {:ok, %Resend.Contacts.Contact{id: @contact_id, email: ^email}} =
               Resend.Contacts.get(email)
    end

    test "update/3 updates a contact", context do
      ClientMock.mock_request(context,
        method: :patch,
        path: "/contacts/#{@contact_id}",
        response: %{
          "id" => @contact_id,
          "email" => "john@example.com",
          "first_name" => "Johnny"
        },
        assert_body: fn body ->
          assert body["first_name"] == "Johnny"
        end
      )

      assert {:ok, %Resend.Contacts.Contact{first_name: "Johnny"}} =
               Resend.Contacts.update(@contact_id, first_name: "Johnny")
    end

    test "remove/2 removes a contact", context do
      ClientMock.mock_request(context,
        method: :delete,
        path: "/contacts/#{@contact_id}",
        response: %{}
      )

      assert {:ok, %Resend.Empty{}} = Resend.Contacts.remove(@contact_id)
    end

    test "add_to_segment/3 adds contact to segment", context do
      ClientMock.mock_request(context,
        method: :post,
        path: "/contacts/#{@contact_id}/segments/#{@segment_id}",
        response: %{}
      )

      assert {:ok, %Resend.Empty{}} =
               Resend.Contacts.add_to_segment(@contact_id, @segment_id)
    end

    test "remove_from_segment/3 removes contact from segment", context do
      ClientMock.mock_request(context,
        method: :delete,
        path: "/contacts/#{@contact_id}/segments/#{@segment_id}",
        response: %{}
      )

      assert {:ok, %Resend.Empty{}} =
               Resend.Contacts.remove_from_segment(@contact_id, @segment_id)
    end

    test "list_segments/2 lists segments for a contact", context do
      ClientMock.mock_request(context,
        method: :get,
        path: "/contacts/#{@contact_id}/segments",
        response: %{
          "data" => [
            %{"id" => @segment_id, "name" => "VIP Customers"}
          ]
        }
      )

      assert {:ok, %Resend.List{data: segments}} =
               Resend.Contacts.list_segments(@contact_id)

      assert [%Resend.Segments.Segment{id: @segment_id}] = segments
    end

    test "list_topics/2 lists topic subscriptions for a contact", context do
      ClientMock.mock_request(context,
        method: :get,
        path: "/contacts/#{@contact_id}/topics",
        response: %{
          "data" => [
            %{"topic_id" => "topic_123", "topic_name" => "Newsletter", "subscribed" => true}
          ]
        }
      )

      assert {:ok, %Resend.List{data: topics}} =
               Resend.Contacts.list_topics(@contact_id)

      assert [%Resend.Contacts.TopicSubscription{subscribed: true}] = topics
    end

    test "update_topics/3 updates topic subscriptions", context do
      topics = [%{id: "topic_123", subscription: "opt_out"}]

      ClientMock.mock_request(context,
        method: :patch,
        path: "/contacts/#{@contact_id}/topics",
        response: %{
          "data" => [
            %{"topic_id" => "topic_123", "subscribed" => false}
          ]
        },
        assert_body: fn body ->
          assert body == [%{"id" => "topic_123", "subscription" => "opt_out"}]
        end
      )

      assert {:ok, %Resend.List{}} =
               Resend.Contacts.update_topics(@contact_id, topics)
    end
  end
end
