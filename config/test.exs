import Config

if resend_key = System.get_env("RESEND_KEY") do
  config :resend, Resend.Client, api_key: resend_key
else
  config :tesla, adapter: Tesla.Mock

  config :resend, Resend.Client, api_key: "re_123456789"
end
