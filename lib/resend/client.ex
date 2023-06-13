defmodule Resend.Client do
  @moduledoc """
  Resend API client.
  """

  require Logger

  alias Resend.Castable

  @callback request(t(), Keyword.t()) ::
              {:ok, %{body: map(), status: pos_integer()}} | {:error, any()}

  @type response(type) :: {:ok, type} | {:error, Resend.Error.t() | :client_error}

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

  @spec get(t(), atom(), String.t(), Keyword.t()) :: response(any())
  def get(client, castable_module, path, opts) do
    client_module = client.client || Resend.Client.TeslaClient

    opts =
      opts
      |> Keyword.put(:method, :get)
      |> Keyword.put(:url, path)

    client_module.request(client, opts)
    |> handle_response(path, castable_module)
  end

  @spec post(t(), atom(), String.t(), map(), Keyword.t()) :: response(any())
  def post(client, castable_module, path, body, opts) do
    client_module = client.client || Resend.Client.TeslaClient

    opts =
      opts
      |> Keyword.put(:method, :post)
      |> Keyword.put(:url, path)
      |> Keyword.put(:body, body)

    client_module.request(client, opts)
    |> handle_response(path, castable_module)
  end

  defp handle_response(response, path, castable_module) do
    case response do
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
