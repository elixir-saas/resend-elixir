defmodule Resend.Client do
  @moduledoc false

  require Logger

  alias Resend.Castable

  @callback post(Resend.config(), String.t(), map()) ::
              {:ok, %{body: map(), status: pos_integer()}} | {:error, any()}

  @type response(type) :: {:ok, type} | {:error, Resend.Error.t() | :client_error}

  @spec post(Resend.config(), String.t(), atom(), map()) :: response(any())
  def post(config, path, castable_module, body) do
    client = Keyword.get(config, :client, Resend.Client.TeslaClient)

    case client.post(config, path, body) do
      {:ok, %{body: body, status: status}} when status in 200..299 ->
        {:ok, Castable.cast(castable_module, body)}

      {:ok, %{body: body}} ->
        {:error, Castable.cast(Resend.Error, body)}

      {:error, reason} ->
        Logger.error("#{inspect(__MODULE__)} error when calling #{path}: #{inspect(reason)}")
        {:error, :client_error}
    end
  end
end
