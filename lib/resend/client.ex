defmodule Resend.Client do
  @moduledoc """
  Resend API client.
  """

  require Logger

  alias Resend.Castable

  @callback request(t(), Keyword.t()) ::
              {:ok, %{body: map(), status: pos_integer()}} | {:error, any()}

  @type response(type) :: {:ok, type} | {:error, Resend.Error.t() | :client_error}

  @typedoc "A module implementing the Castable behaviour, or a tuple for generic types"
  @type castable :: module() | {module(), module()} | :raw

  @type t() :: %__MODULE__{
          api_key: String.t(),
          base_url: String.t() | nil,
          client: module() | nil
        }

  @enforce_keys [:api_key, :base_url, :client]
  defstruct [:api_key, :base_url, :client]

  @default_opts [
    base_url: "https://api.resend.com",
    client: __MODULE__.TeslaClient
  ]

  @doc """
  Creates a new Resend client struct given a keyword list of config opts.
  """
  @spec new(Resend.config()) :: t()
  def new(config) do
    config = Keyword.take(config, [:api_key, :base_url, :client])
    struct!(__MODULE__, Keyword.merge(@default_opts, config))
  end

  @spec get(t(), castable(), String.t()) :: response(any())
  @spec get(t(), castable(), String.t(), Keyword.t()) :: response(any())
  def get(client, castable_module, path, opts \\ []) do
    client_module = client.client || Resend.Client.TeslaClient

    # Extract query params if provided
    {query_params, opts} = Keyword.pop(opts, :query, [])

    opts =
      opts
      |> Keyword.put(:method, :get)
      |> Keyword.put(:url, path)
      |> Keyword.put(:query, query_params)

    client_module.request(client, opts)
    |> handle_response(path, castable_module)
  end

  @spec post(t(), castable(), String.t()) :: response(any())
  @spec post(t(), castable(), String.t(), map() | list(map())) :: response(any())
  @spec post(t(), castable(), String.t(), map() | list(map()), Keyword.t()) ::
          response(any())
  def post(client, castable_module, path, body \\ %{}, opts \\ []) do
    client_module = client.client || Resend.Client.TeslaClient

    opts =
      opts
      |> Keyword.put(:method, :post)
      |> Keyword.put(:url, path)
      |> Keyword.put(:body, body)

    client_module.request(client, opts)
    |> handle_response(path, castable_module)
  end

  @spec patch(t(), castable(), String.t()) :: response(any())
  @spec patch(t(), castable(), String.t(), map()) :: response(any())
  @spec patch(t(), castable(), String.t(), map(), Keyword.t()) :: response(any())
  def patch(client, castable_module, path, body \\ %{}, opts \\ []) do
    client_module = client.client || Resend.Client.TeslaClient

    opts =
      opts
      |> Keyword.put(:method, :patch)
      |> Keyword.put(:url, path)
      |> Keyword.put(:body, body)

    client_module.request(client, opts)
    |> handle_response(path, castable_module)
  end

  @spec delete(t(), castable(), String.t()) :: response(any())
  @spec delete(t(), castable(), String.t(), map()) :: response(any())
  @spec delete(t(), castable(), String.t(), map(), Keyword.t()) :: response(any())
  def delete(client, castable_module, path, body \\ %{}, opts \\ []) do
    client_module = client.client || Resend.Client.TeslaClient

    opts =
      opts
      |> Keyword.put(:method, :delete)
      |> Keyword.put(:url, path)
      |> Keyword.put(:body, body)

    client_module.request(client, opts)
    |> handle_response(path, castable_module)
  end

  defp handle_response(response, path, castable_module) do
    case response do
      {:ok, %{body: "", status: status}} when status in 200..299 ->
        {:ok, Castable.cast(castable_module, %{})}

      {:ok, %{body: body, status: status}} when status in 200..299 ->
        {:ok, Castable.cast(castable_module, body)}

      {:ok, %{body: body}} when is_map(body) ->
        Logger.error("#{inspect(__MODULE__)} error when calling #{path}: #{inspect(body)}")
        {:error, Castable.cast(Resend.Error, body)}

      {:ok, %{body: body}} when is_binary(body) ->
        Logger.error("#{inspect(__MODULE__)} error when calling #{path}: #{body}")
        {:error, body}

      {:error, reason} ->
        Logger.error("#{inspect(__MODULE__)} error when calling #{path}: #{inspect(reason)}")
        {:error, :client_error}
    end
  end
end
