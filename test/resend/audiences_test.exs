defmodule Resend.AudiencesTest do
  use Resend.TestCase

  alias Resend.ClientMock

  setup :setup_env

  @audience_id "aud_123456789"

  describe "Audiences" do
    test "create/2 creates a new audience", context do
      ClientMock.mock_request(context,
        method: :post,
        path: "/audiences",
        response: %{
          "id" => @audience_id,
          "name" => "My Audience"
        },
        assert_body: fn body ->
          assert body["name"] == "My Audience"
        end
      )

      assert {:ok, %Resend.Audiences.Audience{id: @audience_id, name: "My Audience"}} =
               Resend.Audiences.create(name: "My Audience")
    end

    test "list/1 lists all audiences", context do
      ClientMock.mock_request(context,
        method: :get,
        path: "/audiences",
        response: %{
          "data" => [
            %{"id" => @audience_id, "name" => "Audience 1"},
            %{"id" => "aud_987654321", "name" => "Audience 2"}
          ]
        }
      )

      assert {:ok, %Resend.List{data: audiences}} = Resend.Audiences.list()
      assert length(audiences) == 2
      assert [%Resend.Audiences.Audience{id: @audience_id} | _] = audiences
    end

    test "get/2 gets an audience by ID", context do
      ClientMock.mock_request(context,
        method: :get,
        path: "/audiences/#{@audience_id}",
        response: %{
          "id" => @audience_id,
          "name" => "My Audience",
          "created_at" => "2023-06-01T00:00:00.000Z"
        }
      )

      assert {:ok, %Resend.Audiences.Audience{id: @audience_id, name: "My Audience"}} =
               Resend.Audiences.get(@audience_id)
    end

    test "remove/2 removes an audience", context do
      ClientMock.mock_request(context,
        method: :delete,
        path: "/audiences/#{@audience_id}",
        response: %{}
      )

      assert {:ok, %Resend.Empty{}} = Resend.Audiences.remove(@audience_id)
    end
  end
end
