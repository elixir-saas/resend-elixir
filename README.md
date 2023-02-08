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
    {:resend, "~> 0.1.0"}
  ]
end
```

## Testing

By default, calls to Resend are mocked in tests. To send live emails while running
the test suite, set the following environment variables:

```sh
RESEND_KEY="re_1234567" RECIPIENT_EMAIL="<to_email>" SENDER_EMAIL="<from_email>" mix test
```
