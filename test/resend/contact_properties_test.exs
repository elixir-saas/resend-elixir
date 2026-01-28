defmodule Resend.ContactPropertiesTest do
  use Resend.TestCase

  alias Resend.ClientMock

  setup :setup_env

  @property_id "prop_123456789"

  describe "ContactProperties" do
    test "create/2 creates a new contact property", context do
      ClientMock.mock_request(context,
        method: :post,
        path: "/contact-properties",
        response: %{
          "id" => @property_id,
          "key" => "company_size",
          "type" => "string",
          "fallback_value" => "unknown"
        },
        assert_body: fn body ->
          assert body["key"] == "company_size"
          assert body["type"] == "string"
          assert body["fallback_value"] == "unknown"
        end
      )

      assert {:ok,
              %Resend.ContactProperties.ContactProperty{id: @property_id, key: "company_size"}} =
               Resend.ContactProperties.create(
                 key: "company_size",
                 type: "string",
                 fallback_value: "unknown"
               )
    end

    test "list/1 lists all contact properties", context do
      ClientMock.mock_request(context,
        method: :get,
        path: "/contact-properties",
        response: %{
          "data" => [
            %{"id" => @property_id, "key" => "company_size", "type" => "string"},
            %{"id" => "prop_987654321", "key" => "industry", "type" => "string"}
          ]
        }
      )

      assert {:ok, %Resend.List{data: properties}} = Resend.ContactProperties.list()
      assert length(properties) == 2
    end

    test "get/2 gets a contact property by ID", context do
      ClientMock.mock_request(context,
        method: :get,
        path: "/contact-properties/#{@property_id}",
        response: %{
          "id" => @property_id,
          "key" => "company_size",
          "type" => "string",
          "created_at" => "2023-06-01T00:00:00.000Z"
        }
      )

      assert {:ok, %Resend.ContactProperties.ContactProperty{id: @property_id}} =
               Resend.ContactProperties.get(@property_id)
    end

    test "update/3 updates a contact property", context do
      ClientMock.mock_request(context,
        method: :patch,
        path: "/contact-properties/#{@property_id}",
        response: %{
          "id" => @property_id,
          "key" => "company_size",
          "fallback_value" => "small"
        },
        assert_body: fn body ->
          assert body["fallback_value"] == "small"
        end
      )

      assert {:ok, %Resend.ContactProperties.ContactProperty{}} =
               Resend.ContactProperties.update(@property_id, fallback_value: "small")
    end

    test "remove/2 removes a contact property", context do
      ClientMock.mock_request(context,
        method: :delete,
        path: "/contact-properties/#{@property_id}",
        response: %{}
      )

      assert {:ok, %Resend.Empty{}} = Resend.ContactProperties.remove(@property_id)
    end
  end
end
