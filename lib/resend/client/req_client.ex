defmodule Resend.Client.ReqClient do
  @moduledoc """
  Req client for Resend. This is the default HTTP client used.
  """
  @behaviour Resend.Client

  @doc """
  Sends a request to a Resend API endpoint, given list of request opts.
  """
  @spec request(Resend.Client.t(), Keyword.t()) ::
          {:ok, %{body: map(), status: pos_integer()}} | {:error, any()}
  def request(client, opts) do
    method = Keyword.get(opts, :method, :get)
    path = Keyword.get(opts, :url, "/")
    body = Keyword.get(opts, :body)
    query = Keyword.get(opts, :query, [])
    path_params = get_in(opts, [:opts, :path_params]) || []

    url = build_url(client.base_url, path, path_params)

    request_opts = [
      method: method,
      url: url,
      headers: [{"authorization", "Bearer #{client.api_key}"}]
    ]

    # Support Req.Test plug for testing
    request_opts =
      case Application.get_env(:resend, :req_options) do
        nil -> request_opts
        req_opts -> Keyword.merge(request_opts, req_opts)
      end

    request_opts =
      if body do
        Keyword.put(request_opts, :json, body)
      else
        request_opts
      end

    request_opts =
      if query != [] do
        Keyword.put(request_opts, :params, query)
      else
        request_opts
      end

    case Req.request(request_opts) do
      {:ok, %Req.Response{status: status, body: body}} ->
        {:ok, %{status: status, body: body}}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp build_url(base_url, path, path_params) do
    path =
      Enum.reduce(path_params, path, fn {key, value}, acc ->
        String.replace(acc, ":#{key}", to_string(value) |> URI.encode_www_form())
      end)

    base_url <> path
  end
end
