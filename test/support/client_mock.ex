defmodule Resend.ClientMock do
  @moduledoc """
  Test helpers for mocking Resend API calls using Tesla.Mock.
  """
  use ExUnit.Case

  @base_url "https://api.resend.com"

  @doc """
  Generic mock for any API endpoint.

  ## Options
    * `:method` - HTTP method (default: :get)
    * `:path` - Expected path (required)
    * `:status` - Response status (default: 200)
    * `:response` - Response body (required)
    * `:assert_body` - Function to assert request body (optional)
  """
  def mock_request(context, opts) do
    method = Keyword.get(opts, :method, :get)
    path = Keyword.fetch!(opts, :path)
    status = Keyword.get(opts, :status, 200)
    response = Keyword.fetch!(opts, :response)
    assert_body = Keyword.get(opts, :assert_body)

    Tesla.Mock.mock(fn request ->
      %{api_key: api_key} = context

      assert request.method == method
      assert request.url == @base_url <> path

      assert Enum.find(request.headers, &(elem(&1, 0) == "Authorization")) ==
               {"Authorization", "Bearer #{api_key}"}

      if assert_body && request.body do
        body = Jason.decode!(request.body)
        assert_body.(body)
      end

      %Tesla.Env{status: status, body: response}
    end)
  end
end
