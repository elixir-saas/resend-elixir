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
