defmodule Resend.TopicsTest do
  use Resend.TestCase

  alias Resend.ClientMock

  setup :setup_env

  @topic_id "topic_123456789"

  describe "Topics" do
    test "create/2 creates a new topic", context do
      ClientMock.mock_request(context,
        method: :post,
        path: "/topics",
        response: %{
          "id" => @topic_id,
          "name" => "Newsletter",
          "default_subscription" => "opt_in"
        },
        assert_body: fn body ->
          assert body["name"] == "Newsletter"
          assert body["default_subscription"] == "opt_in"
        end
      )

      assert {:ok,
              %Resend.Topics.Topic{
                id: @topic_id,
                name: "Newsletter",
                default_subscription: "opt_in"
              }} =
               Resend.Topics.create(
                 name: "Newsletter",
                 default_subscription: "opt_in"
               )
    end

    test "list/1 lists all topics", context do
      ClientMock.mock_request(context,
        method: :get,
        path: "/topics",
        response: %{
          "data" => [
            %{"id" => @topic_id, "name" => "Newsletter"},
            %{"id" => "topic_987654321", "name" => "Product Updates"}
          ]
        }
      )

      assert {:ok, %Resend.List{data: topics}} = Resend.Topics.list()
      assert length(topics) == 2
    end

    test "list/2 lists topics with pagination", _context do
      Req.Test.stub(Resend.ReqStub, fn conn ->
        assert conn.method == "GET"
        assert conn.request_path == "/topics"
        assert conn.query_string == "limit=10"

        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.send_resp(
          200,
          Jason.encode!(%{
            "data" => [
              %{"id" => @topic_id, "name" => "Newsletter"}
            ]
          })
        )
      end)

      assert {:ok, %Resend.List{data: topics}} =
               Resend.Topics.list(limit: 10)

      assert length(topics) == 1
    end

    test "get/2 gets a topic by ID", context do
      ClientMock.mock_request(context,
        method: :get,
        path: "/topics/#{@topic_id}",
        response: %{
          "id" => @topic_id,
          "name" => "Newsletter",
          "default_subscription" => "opt_in",
          "created_at" => "2023-06-01T00:00:00.000Z"
        }
      )

      assert {:ok, %Resend.Topics.Topic{id: @topic_id, name: "Newsletter"}} =
               Resend.Topics.get(@topic_id)
    end

    test "update/3 updates a topic", context do
      ClientMock.mock_request(context,
        method: :patch,
        path: "/topics/#{@topic_id}",
        response: %{
          "id" => @topic_id,
          "name" => "Weekly Newsletter"
        },
        assert_body: fn body ->
          assert body["name"] == "Weekly Newsletter"
        end
      )

      assert {:ok, %Resend.Topics.Topic{name: "Weekly Newsletter"}} =
               Resend.Topics.update(@topic_id, name: "Weekly Newsletter")
    end

    test "remove/2 removes a topic", context do
      ClientMock.mock_request(context,
        method: :delete,
        path: "/topics/#{@topic_id}",
        response: %{}
      )

      assert {:ok, %Resend.Empty{}} = Resend.Topics.remove(@topic_id)
    end
  end
end
