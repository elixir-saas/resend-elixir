defmodule Resend.ClientMock do
  @moduledoc """
  Test helpers for mocking Resend API calls using Req.Test.
  """
  use ExUnit.Case

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

    Req.Test.stub(Resend.ReqStub, fn conn ->
      %{api_key: api_key} = context

      assert conn.method == method_to_string(method)
      assert conn.request_path == path

      auth_header = Plug.Conn.get_req_header(conn, "authorization")
      assert auth_header == ["Bearer #{api_key}"]

      if assert_body do
        {:ok, body, _conn} = Plug.Conn.read_body(conn)

        if body != "" do
          body = Jason.decode!(body)
          assert_body.(body)
        end
      end

      conn
      |> Plug.Conn.put_resp_content_type("application/json")
      |> Plug.Conn.send_resp(status, Jason.encode!(response))
    end)
  end

  defp method_to_string(:get), do: "GET"
  defp method_to_string(:post), do: "POST"
  defp method_to_string(:put), do: "PUT"
  defp method_to_string(:patch), do: "PATCH"
  defp method_to_string(:delete), do: "DELETE"
end
