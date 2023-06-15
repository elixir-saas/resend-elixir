# Resend

[![Run in Livebook](https://livebook.dev/badge/v1/black.svg)](https://livebook.dev/run?url=https%3A%2F%2Fraw.githubusercontent.com%2Felixir-saas%2Fresend-elixir%2Fmain%2Fresend_elixir.livemd)

API client for [Resend](https://resend.com/), the new email API for developers.

## API

* [`Resend.Emails`](https://hexdocs.pm/resend/Resend.Emails.html)
* [`Resend.Domains`](https://hexdocs.pm/resend/Resend.Domains.html)
* [`Resend.ApiKeys`](https://hexdocs.pm/resend/Resend.ApiKeys.html)

## Installation

Install by adding `resend` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:resend, "~> 0.4.0"}
  ]
end
```

## Getting Started

Send your first email in two steps:

```ex
# Configure your Resend API key
config :resend, Resend.Client, api_key: "re_123456789"
```

```ex
# Send an email
Resend.Emails.send(%{
  to: "me@example.com",
  from: "myapp@example.com",
  subject: "Hello!",
  text: "👋🏻"
})
```

Elixir script example:

```ex
# Save this file as `resend.exs`, run it with `elixir resend.exs`
Mix.install([
  {:resend, "~> 0.4.0"}
])

# Replace with your API key
client = Resend.client(api_key: "re_123456789")

# Replace `:to` and `:from` with valid emails
Resend.Emails.send(client, %{
  to: "me@example.com",
  from: "myapp@example.com",
  subject: "Hello!",
  text: "👋🏻"
})
```

View additional documentation at <https://hexdocs.pm/resend>.

## Swoosh Adapter

This library includes a Swoosh adapter to make using Resend with a new Phoenix project as easy as
possible. All you have to do is configure your Mailer:

```ex
config :my_app, MyApp.Mailer,
  adapter: Resend.Swoosh.Adapter,
  api_key: "re_123456789"
```

View additional documentation at <https://hexdocs.pm/resend/Resend.Swoosh.Adapter.html>.

## Testing

By default, calls to Resend are mocked in tests. To send live emails while running
the test suite, set the following environment variables:

```sh
RESEND_KEY="re_123456789" \
  RECIPIENT_EMAIL="<to_email>" \
  SENDER_EMAIL="<from_email>" \
  SENT_EMAIL_ID="<existing_email_id>" \
  mix test
```
