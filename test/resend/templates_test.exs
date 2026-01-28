defmodule Resend.TemplatesTest do
  use Resend.TestCase

  alias Resend.ClientMock

  setup :setup_env

  @template_id "tmpl_123456789"

  describe "Templates" do
    test "create/2 creates a new template", context do
      ClientMock.mock_request(context,
        method: :post,
        path: "/templates",
        response: %{
          "id" => @template_id,
          "name" => "Welcome Email",
          "subject" => "Welcome to our service!"
        },
        assert_body: fn body ->
          assert body["name"] == "Welcome Email"
          assert body["subject"] == "Welcome to our service!"
        end
      )

      assert {:ok, %Resend.Templates.Template{id: @template_id, name: "Welcome Email"}} =
               Resend.Templates.create(
                 name: "Welcome Email",
                 subject: "Welcome to our service!",
                 html: "<h1>Welcome!</h1>"
               )
    end

    test "list/1 lists all templates", context do
      ClientMock.mock_request(context,
        method: :get,
        path: "/templates",
        response: %{
          "data" => [
            %{"id" => @template_id, "name" => "Welcome Email"},
            %{"id" => "tmpl_987654321", "name" => "Password Reset"}
          ]
        }
      )

      assert {:ok, %Resend.List{data: templates}} = Resend.Templates.list()
      assert length(templates) == 2
    end

    test "get/2 gets a template by ID", context do
      ClientMock.mock_request(context,
        method: :get,
        path: "/templates/#{@template_id}",
        response: %{
          "id" => @template_id,
          "name" => "Welcome Email",
          "subject" => "Welcome!",
          "html" => "<h1>Welcome!</h1>",
          "created_at" => "2023-06-01T00:00:00.000Z"
        }
      )

      assert {:ok, %Resend.Templates.Template{id: @template_id, html: "<h1>Welcome!</h1>"}} =
               Resend.Templates.get(@template_id)
    end

    test "update/3 updates a template", context do
      ClientMock.mock_request(context,
        method: :patch,
        path: "/templates/#{@template_id}",
        response: %{
          "id" => @template_id,
          "name" => "Updated Welcome Email",
          "subject" => "Welcome!"
        },
        assert_body: fn body ->
          assert body["name"] == "Updated Welcome Email"
        end
      )

      assert {:ok, %Resend.Templates.Template{name: "Updated Welcome Email"}} =
               Resend.Templates.update(@template_id, name: "Updated Welcome Email")
    end

    test "remove/2 removes a template", context do
      ClientMock.mock_request(context,
        method: :delete,
        path: "/templates/#{@template_id}",
        response: %{}
      )

      assert {:ok, %Resend.Empty{}} = Resend.Templates.remove(@template_id)
    end

    test "duplicate/2 duplicates a template", context do
      ClientMock.mock_request(context,
        method: :post,
        path: "/templates/#{@template_id}/duplicate",
        response: %{
          "id" => "tmpl_copy_123",
          "name" => "Welcome Email (Copy)"
        }
      )

      assert {:ok, %Resend.Templates.Template{id: "tmpl_copy_123"}} =
               Resend.Templates.duplicate(@template_id)
    end

    test "publish/2 publishes a template", context do
      ClientMock.mock_request(context,
        method: :post,
        path: "/templates/#{@template_id}/publish",
        response: %{
          "id" => @template_id,
          "name" => "Welcome Email"
        }
      )

      assert {:ok, %Resend.Templates.Template{id: @template_id}} =
               Resend.Templates.publish(@template_id)
    end
  end
end
