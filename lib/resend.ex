defmodule Resend do
  @moduledoc """
  Documentation for `Resend`.
  """

  @config_module Resend.Client

  @type config() ::
          list(
            {:api_key, String.t()}
            | {:base_url, String.t()}
            | {:client, atom()}
          )

  @doc """
  Loads config values from the application environment.

  Config options are as follows:

  ```ex
  config :resend, Resend.Client
    api_key: "re_1234567",
    base_url: "https://api.resend.com",
    client: Resend.Client.TeslaClient
  ```

  The only required config option is `:api_key`. If you would like to replace the
  HTTP client used by Resend, configure the `:client` option. By default, this library
  uses [Tesla](https://github.com/elixir-tesla/tesla), but changing it is as easy as
  defining your own client module. See the `Resend.Client` module docs for more info.
  """
  @spec config() :: config()
  def config() do
    config =
      Application.get_env(:resend, @config_module) ||
        raise """
        Missing client configuration for Resend.

        Configure your Resend API key in one of your config files, for example:

            config :resend, #{inspect(@config_module)}, api_key: "re_1234567"
        """

    validate_config!(config)
  end

  @doc false
  @spec validate_config!(Resend.config()) :: Resend.config() | no_return()
  def validate_config!(config) do
    api_key =
      Keyword.get(config, :api_key) ||
        raise "Missing required config key for #{@config_module}: :api_key"

    String.starts_with?(api_key, "re_") ||
      raise "Resend API key should start with 're_', please check your configuration"

    config
  end
end
