defmodule Resend.SegmentsTest do
  use Resend.TestCase

  alias Resend.ClientMock

  setup :setup_env

  @segment_id "seg_123456789"
  @audience_id "aud_123456789"

  describe "Segments" do
    test "create/2 creates a new segment", context do
      ClientMock.mock_request(context,
        method: :post,
        path: "/segments",
        response: %{
          "id" => @segment_id,
          "name" => "VIP Customers",
          "audience_id" => @audience_id
        },
        assert_body: fn body ->
          assert body["name"] == "VIP Customers"
          assert body["audience_id"] == @audience_id
        end
      )

      assert {:ok, %Resend.Segments.Segment{id: @segment_id, name: "VIP Customers"}} =
               Resend.Segments.create(audience_id: @audience_id, name: "VIP Customers")
    end

    test "list/1 lists all segments", context do
      ClientMock.mock_request(context,
        method: :get,
        path: "/segments",
        response: %{
          "data" => [
            %{"id" => @segment_id, "name" => "VIP Customers"},
            %{"id" => "seg_987654321", "name" => "New Users"}
          ]
        }
      )

      assert {:ok, %Resend.List{data: segments}} = Resend.Segments.list()
      assert length(segments) == 2
    end

    test "list/2 lists segments filtered by audience_id", _context do
      Req.Test.stub(Resend.ReqStub, fn conn ->
        assert conn.method == "GET"
        assert conn.request_path == "/segments"
        assert conn.query_string == "audience_id=#{@audience_id}"

        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.send_resp(
          200,
          Jason.encode!(%{
            "data" => [
              %{"id" => @segment_id, "name" => "VIP Customers"}
            ]
          })
        )
      end)

      assert {:ok, %Resend.List{data: segments}} =
               Resend.Segments.list(audience_id: @audience_id)

      assert length(segments) == 1
    end

    test "get/2 gets a segment by ID", context do
      ClientMock.mock_request(context,
        method: :get,
        path: "/segments/#{@segment_id}",
        response: %{
          "id" => @segment_id,
          "name" => "VIP Customers",
          "audience_id" => @audience_id,
          "created_at" => "2023-06-01T00:00:00.000Z"
        }
      )

      assert {:ok, %Resend.Segments.Segment{id: @segment_id, name: "VIP Customers"}} =
               Resend.Segments.get(@segment_id)
    end

    test "remove/2 removes a segment", context do
      ClientMock.mock_request(context,
        method: :delete,
        path: "/segments/#{@segment_id}",
        response: %{}
      )

      assert {:ok, %Resend.Empty{}} = Resend.Segments.remove(@segment_id)
    end
  end
end
