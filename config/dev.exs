import Config

config :resend, Resend.Client, api_key: System.get_env("RESEND_KEY")
