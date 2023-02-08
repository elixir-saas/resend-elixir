defmodule Resend do
  @moduledoc """
  Documentation for `Resend`.
  """

  @type config() ::
          list(
            {:api_key, String.t()}
            | {:base_url, String.t()}
            | {:client, atom()}
          )

  @spec config() :: config()
  def config() do
    config_module = Resend.Client

    Application.get_env(:resend, config_module) ||
      raise """
      Missing client configuration for Resend.

      Configure your Resend API key in one of your config files, for example:

          config :resend, #{inspect(config_module)}, api_key: "re_1234567"
      """
  end
end
