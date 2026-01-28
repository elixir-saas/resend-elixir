import Config

# Unit tests always use mocks
config :resend, Resend.Client, api_key: "re_123456789"
config :resend, req_options: [plug: {Req.Test, Resend.ReqStub}]
