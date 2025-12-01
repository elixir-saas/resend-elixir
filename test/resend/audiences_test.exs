defmodule Resend.AudiencesTest do
  use Resend.TestCase, async: true

  alias Resend.Audiences.Audience

  setup :setup_env

  describe "/audiences" do
    test "creates an audience", context do
      name = "Test Audience"
      audience_id = "78261eea-8f8b-4381-83c6-79fa7120f1cf"

      Tesla.Mock.mock(fn request ->
        %{api_key: api_key} = context

        assert request.method == :post
        assert request.url == "https://api.resend.com/audiences"

        assert Enum.find(request.headers, &(elem(&1, 0) == "Authorization")) ==
                 {"Authorization", "Bearer #{api_key}"}

        body = Jason.decode!(request.body)
        assert body["name"] == name

        success_body = %{
          "object" => "audience",
          "id" => audience_id,
          "name" => name
        }

        %Tesla.Env{status: 200, body: success_body}
      end)

      assert {:ok, %Audience{id: ^audience_id, name: ^name}} =
               Resend.Audiences.create(name: name)
    end

    test "lists all audiences", context do
      audience_id = "78261eea-8f8b-4381-83c6-79fa7120f1cf"
      audience_name = "Registered Users"

      Tesla.Mock.mock(fn request ->
        %{api_key: api_key} = context

        assert request.method == :get
        assert request.url == "https://api.resend.com/audiences"

        assert Enum.find(request.headers, &(elem(&1, 0) == "Authorization")) ==
                 {"Authorization", "Bearer #{api_key}"}

        success_body = %{
          "object" => "list",
          "data" => [
            %{
              "id" => audience_id,
              "name" => audience_name,
              "created_at" => "2023-10-06T22:59:55.977Z"
            }
          ]
        }

        %Tesla.Env{status: 200, body: success_body}
      end)

      assert {:ok, %Resend.List{data: [%Audience{id: ^audience_id, name: ^audience_name}]}} =
               Resend.Audiences.list()
    end

    test "gets an audience by ID", context do
      audience_id = "78261eea-8f8b-4381-83c6-79fa7120f1cf"
      audience_name = "Registered Users"

      Tesla.Mock.mock(fn request ->
        %{api_key: api_key} = context

        assert request.method == :get
        assert request.url == "https://api.resend.com/audiences/#{audience_id}"

        assert Enum.find(request.headers, &(elem(&1, 0) == "Authorization")) ==
                 {"Authorization", "Bearer #{api_key}"}

        success_body = %{
          "object" => "audience",
          "id" => audience_id,
          "name" => audience_name,
          "created_at" => "2023-10-06T22:59:55.977Z"
        }

        %Tesla.Env{status: 200, body: success_body}
      end)

      assert {:ok, %Audience{id: ^audience_id, name: ^audience_name}} =
               Resend.Audiences.get(audience_id)
    end

    test "removes an audience by ID", context do
      audience_id = "78261eea-8f8b-4381-83c6-79fa7120f1cf"

      Tesla.Mock.mock(fn request ->
        %{api_key: api_key} = context

        assert request.method == :delete
        assert request.url == "https://api.resend.com/audiences/#{audience_id}"

        assert Enum.find(request.headers, &(elem(&1, 0) == "Authorization")) ==
                 {"Authorization", "Bearer #{api_key}"}

        success_body = %{
          "object" => "audience",
          "id" => audience_id,
          "deleted" => true
        }

        %Tesla.Env{status: 200, body: success_body}
      end)

      assert {:ok, %Audience{id: ^audience_id, deleted: true}} =
               Resend.Audiences.remove(audience_id)
    end

    if not live_mode?() do
      test "returns an error when creating audience fails", context do
        name = "Test Audience"

        Tesla.Mock.mock(fn request ->
          %{api_key: api_key} = context

          assert request.method == :post
          assert request.url == "https://api.resend.com/audiences"

          assert Enum.find(request.headers, &(elem(&1, 0) == "Authorization")) ==
                   {"Authorization", "Bearer #{api_key}"}

          error_body = %{
            "message" => "Audience name is required",
            "name" => "validation_error",
            "statusCode" => 400
          }

          %Tesla.Env{status: 400, body: error_body}
        end)

        assert {:error, %Resend.Error{name: "validation_error", status_code: 400}} =
                 Resend.Audiences.create(name: name)
      end

      test "returns an error when audience not found", context do
        audience_id = "non-existent-id"

        Tesla.Mock.mock(fn request ->
          %{api_key: api_key} = context

          assert request.method == :get
          assert request.url == "https://api.resend.com/audiences/#{audience_id}"

          assert Enum.find(request.headers, &(elem(&1, 0) == "Authorization")) ==
                   {"Authorization", "Bearer #{api_key}"}

          error_body = %{
            "message" => "Audience not found",
            "name" => "not_found",
            "statusCode" => 404
          }

          %Tesla.Env{status: 404, body: error_body}
        end)

        assert {:error, %Resend.Error{name: "not_found", status_code: 404}} =
                 Resend.Audiences.get(audience_id)
      end
    end
  end

  describe "with custom client" do
    test "creates an audience with custom client", _context do
      name = "Test Audience"
      audience_id = "78261eea-8f8b-4381-83c6-79fa7120f1cf"
      custom_client = Resend.client(api_key: "re_custom_key")

      Tesla.Mock.mock(fn request ->
        assert request.method == :post
        assert request.url == "https://api.resend.com/audiences"

        assert Enum.find(request.headers, &(elem(&1, 0) == "Authorization")) ==
                 {"Authorization", "Bearer re_custom_key"}

        body = Jason.decode!(request.body)
        assert body["name"] == name

        success_body = %{
          "object" => "audience",
          "id" => audience_id,
          "name" => name
        }

        %Tesla.Env{status: 200, body: success_body}
      end)

      assert {:ok, %Audience{id: ^audience_id, name: ^name}} =
               Resend.Audiences.create(custom_client, name: name)
    end
  end
end
