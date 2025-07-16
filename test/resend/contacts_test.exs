defmodule Resend.ContactsTest do
  use Resend.TestCase, async: true

  alias Resend.Contacts.Contact

  setup :setup_env

  describe "/audiences/:audience_id/contacts" do
    test "creates a contact", context do
      audience_id = "78261eea-8f8b-4381-83c6-79fa7120f1cf"
      contact_id = "479e3145-dd38-476b-932c-529ceb705947"
      email = "steve.wozniak@gmail.com"
      first_name = "Steve"
      last_name = "Wozniak"

      Tesla.Mock.mock(fn request ->
        %{api_key: api_key} = context

        assert request.method == :post
        assert request.url == "https://api.resend.com/audiences/#{audience_id}/contacts"

        assert Enum.find(request.headers, &(elem(&1, 0) == "Authorization")) ==
                 {"Authorization", "Bearer #{api_key}"}

        body = Jason.decode!(request.body)
        assert body["email"] == email
        assert body["first_name"] == first_name
        assert body["last_name"] == last_name
        assert body["unsubscribed"] == false

        success_body = %{
          "object" => "contact",
          "id" => contact_id
        }

        %Tesla.Env{status: 200, body: success_body}
      end)

      assert {:ok, %Contact{id: ^contact_id}} =
               Resend.Contacts.create(audience_id,
                 email: email,
                 first_name: first_name,
                 last_name: last_name,
                 unsubscribed: false
               )
    end

    test "lists all contacts", context do
      audience_id = "78261eea-8f8b-4381-83c6-79fa7120f1cf"
      contact_id = "e169aa45-1ecf-4183-9955-b1499d5701d3"
      email = "steve.wozniak@gmail.com"

      Tesla.Mock.mock(fn request ->
        %{api_key: api_key} = context

        assert request.method == :get
        assert request.url == "https://api.resend.com/audiences/#{audience_id}/contacts"

        assert Enum.find(request.headers, &(elem(&1, 0) == "Authorization")) ==
                 {"Authorization", "Bearer #{api_key}"}

        success_body = %{
          "object" => "list",
          "data" => [
            %{
              "id" => contact_id,
              "email" => email,
              "first_name" => "Steve",
              "last_name" => "Wozniak",
              "created_at" => "2023-10-06T23:47:56.678Z",
              "unsubscribed" => false
            }
          ]
        }

        %Tesla.Env{status: 200, body: success_body}
      end)

      assert {:ok, %Resend.List{data: [%Contact{id: ^contact_id, email: ^email}]}} =
               Resend.Contacts.list(audience_id)
    end

    test "gets a contact by ID", context do
      audience_id = "78261eea-8f8b-4381-83c6-79fa7120f1cf"
      contact_id = "e169aa45-1ecf-4183-9955-b1499d5701d3"
      email = "steve.wozniak@gmail.com"

      Tesla.Mock.mock(fn request ->
        %{api_key: api_key} = context

        assert request.method == :get

        assert request.url ==
                 "https://api.resend.com/audiences/#{audience_id}/contacts/#{contact_id}"

        assert Enum.find(request.headers, &(elem(&1, 0) == "Authorization")) ==
                 {"Authorization", "Bearer #{api_key}"}

        success_body = %{
          "object" => "contact",
          "id" => contact_id,
          "email" => email,
          "first_name" => "Steve",
          "last_name" => "Wozniak",
          "created_at" => "2023-10-06T23:47:56.678Z",
          "unsubscribed" => false
        }

        %Tesla.Env{status: 200, body: success_body}
      end)

      assert {:ok, %Contact{id: ^contact_id, email: ^email}} =
               Resend.Contacts.get(audience_id, id: contact_id)
    end

    test "gets a contact by email", context do
      audience_id = "78261eea-8f8b-4381-83c6-79fa7120f1cf"
      contact_id = "e169aa45-1ecf-4183-9955-b1499d5701d3"
      email = "steve.wozniak@gmail.com"
      encoded_email = URI.encode_www_form(email)

      Tesla.Mock.mock(fn request ->
        %{api_key: api_key} = context

        assert request.method == :get

        assert request.url ==
                 "https://api.resend.com/audiences/#{audience_id}/contacts/#{encoded_email}"

        assert Enum.find(request.headers, &(elem(&1, 0) == "Authorization")) ==
                 {"Authorization", "Bearer #{api_key}"}

        success_body = %{
          "object" => "contact",
          "id" => contact_id,
          "email" => email,
          "first_name" => "Steve",
          "last_name" => "Wozniak",
          "created_at" => "2023-10-06T23:47:56.678Z",
          "unsubscribed" => false
        }

        %Tesla.Env{status: 200, body: success_body}
      end)

      assert {:ok, %Contact{id: ^contact_id, email: ^email}} =
               Resend.Contacts.get(audience_id, email: email)
    end

    test "updates a contact by ID", context do
      audience_id = "78261eea-8f8b-4381-83c6-79fa7120f1cf"
      contact_id = "e169aa45-1ecf-4183-9955-b1499d5701d3"

      Tesla.Mock.mock(fn request ->
        %{api_key: api_key} = context

        assert request.method == :patch

        assert request.url ==
                 "https://api.resend.com/audiences/#{audience_id}/contacts/#{contact_id}"

        assert Enum.find(request.headers, &(elem(&1, 0) == "Authorization")) ==
                 {"Authorization", "Bearer #{api_key}"}

        body = Jason.decode!(request.body)
        assert body["unsubscribed"] == true
        assert Map.keys(body) == ["unsubscribed"]

        success_body = %{
          "object" => "contact",
          "id" => contact_id
        }

        %Tesla.Env{status: 200, body: success_body}
      end)

      assert {:ok, %Contact{id: ^contact_id}} =
               Resend.Contacts.update(audience_id, id: contact_id, unsubscribed: true)
    end

    test "updates a contact by email", context do
      audience_id = "78261eea-8f8b-4381-83c6-79fa7120f1cf"
      contact_id = "e169aa45-1ecf-4183-9955-b1499d5701d3"
      email = "steve@example.com"
      encoded_email = URI.encode_www_form(email)

      Tesla.Mock.mock(fn request ->
        %{api_key: api_key} = context

        assert request.method == :patch

        assert request.url ==
                 "https://api.resend.com/audiences/#{audience_id}/contacts/#{encoded_email}"

        assert Enum.find(request.headers, &(elem(&1, 0) == "Authorization")) ==
                 {"Authorization", "Bearer #{api_key}"}

        body = Jason.decode!(request.body)
        assert body["first_name"] == "Steven"
        assert body["last_name"] == "Jobs"
        assert Map.keys(body) |> Enum.sort() == ["first_name", "last_name"]

        success_body = %{
          "object" => "contact",
          "id" => contact_id
        }

        %Tesla.Env{status: 200, body: success_body}
      end)

      assert {:ok, %Contact{id: ^contact_id}} =
               Resend.Contacts.update(audience_id,
                 email: email,
                 first_name: "Steven",
                 last_name: "Jobs"
               )
    end

    test "removes a contact by ID", context do
      audience_id = "78261eea-8f8b-4381-83c6-79fa7120f1cf"
      contact_id = "520784e2-887d-4c25-b53c-4ad46ad38100"

      Tesla.Mock.mock(fn request ->
        %{api_key: api_key} = context

        assert request.method == :delete

        assert request.url ==
                 "https://api.resend.com/audiences/#{audience_id}/contacts/#{contact_id}"

        assert Enum.find(request.headers, &(elem(&1, 0) == "Authorization")) ==
                 {"Authorization", "Bearer #{api_key}"}

        success_body = %{
          "object" => "contact",
          "contact" => contact_id,
          "deleted" => true
        }

        %Tesla.Env{status: 200, body: success_body}
      end)

      assert {:ok, %Contact{id: ^contact_id, deleted: true}} =
               Resend.Contacts.remove(audience_id, id: contact_id)
    end

    test "removes a contact by email", context do
      audience_id = "78261eea-8f8b-4381-83c6-79fa7120f1cf"
      contact_id = "520784e2-887d-4c25-b53c-4ad46ad38100"
      email = "acme@example.com"
      encoded_email = URI.encode_www_form(email)

      Tesla.Mock.mock(fn request ->
        %{api_key: api_key} = context

        assert request.method == :delete

        assert request.url ==
                 "https://api.resend.com/audiences/#{audience_id}/contacts/#{encoded_email}"

        assert Enum.find(request.headers, &(elem(&1, 0) == "Authorization")) ==
                 {"Authorization", "Bearer #{api_key}"}

        success_body = %{
          "object" => "contact",
          "contact" => contact_id,
          "deleted" => true
        }

        %Tesla.Env{status: 200, body: success_body}
      end)

      assert {:ok, %Contact{id: ^contact_id, deleted: true}} =
               Resend.Contacts.remove(audience_id, email: email)
    end

    if not live_mode?() do
      test "returns an error when creating contact fails", context do
        audience_id = "78261eea-8f8b-4381-83c6-79fa7120f1cf"

        Tesla.Mock.mock(fn request ->
          %{api_key: api_key} = context

          assert request.method == :post
          assert request.url == "https://api.resend.com/audiences/#{audience_id}/contacts"

          assert Enum.find(request.headers, &(elem(&1, 0) == "Authorization")) ==
                   {"Authorization", "Bearer #{api_key}"}

          error_body = %{
            "message" => "Email is required",
            "name" => "validation_error",
            "statusCode" => 400
          }

          %Tesla.Env{status: 400, body: error_body}
        end)

        assert {:error, %Resend.Error{name: "validation_error", status_code: 400}} =
                 Resend.Contacts.create(audience_id, email: nil)
      end

      test "returns an error when contact not found", context do
        audience_id = "78261eea-8f8b-4381-83c6-79fa7120f1cf"
        contact_id = "non-existent-id"

        Tesla.Mock.mock(fn request ->
          %{api_key: api_key} = context

          assert request.method == :get

          assert request.url ==
                   "https://api.resend.com/audiences/#{audience_id}/contacts/#{contact_id}"

          assert Enum.find(request.headers, &(elem(&1, 0) == "Authorization")) ==
                   {"Authorization", "Bearer #{api_key}"}

          error_body = %{
            "message" => "Contact not found",
            "name" => "not_found",
            "statusCode" => 404
          }

          %Tesla.Env{status: 404, body: error_body}
        end)

        assert {:error, %Resend.Error{name: "not_found", status_code: 404}} =
                 Resend.Contacts.get(audience_id, id: contact_id)
      end
    end
  end

  describe "with custom client" do
    test "creates a contact with custom client", _context do
      audience_id = "78261eea-8f8b-4381-83c6-79fa7120f1cf"
      contact_id = "479e3145-dd38-476b-932c-529ceb705947"
      email = "test@example.com"
      custom_client = Resend.client(api_key: "re_custom_key")

      Tesla.Mock.mock(fn request ->
        assert request.method == :post
        assert request.url == "https://api.resend.com/audiences/#{audience_id}/contacts"

        assert Enum.find(request.headers, &(elem(&1, 0) == "Authorization")) ==
                 {"Authorization", "Bearer re_custom_key"}

        body = Jason.decode!(request.body)
        assert body["email"] == email

        success_body = %{
          "object" => "contact",
          "id" => contact_id
        }

        %Tesla.Env{status: 200, body: success_body}
      end)

      assert {:ok, %Contact{id: ^contact_id}} =
               Resend.Contacts.create(custom_client, audience_id, email: email)
    end
  end
end
