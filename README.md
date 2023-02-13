# Resend

API client for [Resend](https://resend.com/), the new email API for developers.

Send your first email in two steps:

```ex
# Configure your Resend API key
config :resend, Resend.Client, api_key: "re_1234567"
```

```ex
# Send an email
Resend.Email.send(%{to: "me@example.com", from: "myapp@example.com", subject: "Hello!", text: "👋🏻"})
```

View additional documentation at <https://hexdocs.pm/resend>.

## Installation

Install by adding `resend` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:resend, "~> 0.2.0"}
  ]
end
```

## Swoosh Adapter

This library includes a Swoosh adapter to make using Resend with a new Phoenix project as easy as
possible. All you have to do is configure your Mailer:

```ex
config :my_app, MyApp.Mailer,
  adapter: Resend.Swoosh.Adapter,
  api_key: "re_1234567"
```

View additional documentation at <https://hexdocs.pm/resend/Resend.Swoosh.Adapter.html>.

## Testing

By default, calls to Resend are mocked in tests. To send live emails while running
the test suite, set the following environment variables:

```sh
RESEND_KEY="re_1234567" RECIPIENT_EMAIL="<to_email>" SENDER_EMAIL="<from_email>" mix test
```
