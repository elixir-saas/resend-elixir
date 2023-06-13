defmodule Resend.ClientMock do
  use ExUnit.Case

  def mock_send_email(context, opts \\ []) do
    Tesla.Mock.mock(fn request ->
      %{api_key: api_key} = context

      assert request.method == :post
      assert request.url == "https://api.resend.com/emails"

      assert Enum.find(request.headers, &(elem(&1, 0) == "Authorization")) ==
               {"Authorization", "Bearer #{api_key}"}

      body = Jason.decode!(request.body)

      for {field, value} <- Keyword.get(opts, :assert_fields, []) do
        assert body[to_string(field)] == value
      end

      success_body = %{
        "id" => context.sent_email_id
      }

      {status, body} = Keyword.get(opts, :respond_with, {200, success_body})
      %Tesla.Env{status: status, body: body}
    end)
  end

  def mock_get_email(context, opts \\ []) do
    Tesla.Mock.mock(fn request ->
      %{api_key: api_key} = context

      assert request.method == :get
      assert request.url == "https://api.resend.com/emails/#{context.sent_email_id}"

      assert Enum.find(request.headers, &(elem(&1, 0) == "Authorization")) ==
               {"Authorization", "Bearer #{api_key}"}

      success_body = %{
        "bcc" => nil,
        "cc" => nil,
        "created_at" => "2023-06-01T00:00:00.000Z",
        "from" => context.from,
        "html" => nil,
        "id" => context.sent_email_id,
        "last_event" => "delivered",
        "object" => "email",
        "reply_to" => nil,
        "subject" => "Test Email",
        "text" => "Testing Resend",
        "to" => [context.to]
      }

      {status, body} = Keyword.get(opts, :respond_with, {200, success_body})
      %Tesla.Env{status: status, body: body}
    end)
  end
end
