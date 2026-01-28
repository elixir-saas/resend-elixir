defmodule Resend.DomainsTest do
  use Resend.TestCase

  alias Resend.ClientMock

  setup :setup_env

  @domain_id "d_123456789"

  describe "Domains" do
    test "create/2 creates a new domain", context do
      ClientMock.mock_request(context,
        method: :post,
        path: "/domains",
        response: %{
          "id" => @domain_id,
          "name" => "example.com",
          "status" => "pending",
          "region" => "us-east-1"
        },
        assert_body: fn body ->
          assert body["name"] == "example.com"
          assert body["region"] == "us-east-1"
        end
      )

      assert {:ok, %Resend.Domains.Domain{id: @domain_id, name: "example.com"}} =
               Resend.Domains.create(name: "example.com", region: "us-east-1")
    end

    test "list/1 lists all domains", context do
      ClientMock.mock_request(context,
        method: :get,
        path: "/domains",
        response: %{
          "data" => [
            %{"id" => @domain_id, "name" => "example.com", "status" => "verified"},
            %{"id" => "d_987654321", "name" => "other.com", "status" => "pending"}
          ]
        }
      )

      assert {:ok, %Resend.List{data: domains}} = Resend.Domains.list()
      assert length(domains) == 2
    end

    test "get/2 gets a domain by ID", context do
      ClientMock.mock_request(context,
        method: :get,
        path: "/domains/#{@domain_id}",
        response: %{
          "id" => @domain_id,
          "name" => "example.com",
          "status" => "verified",
          "created_at" => "2023-06-01T00:00:00.000Z",
          "records" => [
            %{
              "name" => "_dmarc",
              "record" => "TXT",
              "status" => "verified",
              "ttl" => "3600",
              "type" => "TXT",
              "value" => "v=DMARC1; p=none"
            }
          ]
        }
      )

      assert {:ok, %Resend.Domains.Domain{id: @domain_id, name: "example.com"}} =
               Resend.Domains.get(@domain_id)
    end

    test "verify/2 initiates domain verification", context do
      ClientMock.mock_request(context,
        method: :post,
        path: "/domains/#{@domain_id}/verify",
        response: %{
          "id" => @domain_id,
          "name" => "example.com",
          "status" => "pending"
        }
      )

      assert {:ok, %Resend.Domains.Domain{id: @domain_id, status: "pending"}} =
               Resend.Domains.verify(@domain_id)
    end

    test "update/3 updates a domain", context do
      ClientMock.mock_request(context,
        method: :patch,
        path: "/domains/#{@domain_id}",
        response: %{
          "id" => @domain_id,
          "name" => "example.com"
        },
        assert_body: fn body ->
          assert body["click_tracking"] == true
          assert body["open_tracking"] == true
        end
      )

      assert {:ok, %Resend.Domains.Domain{id: @domain_id}} =
               Resend.Domains.update(@domain_id, click_tracking: true, open_tracking: true)
    end

    test "remove/2 removes a domain", context do
      ClientMock.mock_request(context,
        method: :delete,
        path: "/domains/#{@domain_id}",
        response: %{
          "id" => @domain_id,
          "deleted" => true
        }
      )

      assert {:ok, %Resend.Domains.Domain{deleted: true}} = Resend.Domains.remove(@domain_id)
    end
  end
end
