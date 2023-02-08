defmodule Resend.ClientMock do
  use ExUnit.Case

  def mock_send_email(context, opts) do
    Tesla.Mock.mock(fn request ->
      %{api_key: api_key} = context

      assert request.method == :post
      assert request.url == "https://api.resend.com/email"

      assert Enum.find(request.headers, &(elem(&1, 0) == "Authorization")) ==
               {"Authorization", "Bearer #{api_key}"}

      body = Jason.decode!(request.body)

      for {field, value} <- Keyword.get(opts, :assert_fields, []) do
        assert body[to_string(field)] == value
      end

      success_body = %{
        "from" => body["from"],
        "id" => "f524bc41-316b-45c6-99f3-c5d3bc193d12",
        "to" => body["to"]
      }

      {status, body} = Keyword.get(opts, :respond_with, {200, success_body})
      %Tesla.Env{status: status, body: body}
    end)
  end
end
