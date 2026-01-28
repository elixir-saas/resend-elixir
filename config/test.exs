import Config

if resend_key = System.get_env("RESEND_KEY") do
  config :resend, live_mode: true
  config :resend, Resend.Client, api_key: resend_key
else
  config :resend, live_mode: false
  config :resend, Resend.Client, api_key: "re_123456789"
  config :resend, req_options: [plug: {Req.Test, Resend.ReqStub}]
end
