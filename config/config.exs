import Config

# Swoosh initializes an API client on startup even when using custom adapters.
# Since we don't include hackney (Swoosh's default), we configure Req instead.
config :swoosh, :api_client, Swoosh.ApiClient.Req

import_config "#{Mix.env()}.exs"
