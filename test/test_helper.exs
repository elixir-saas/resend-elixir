# Exclude integration tests by default
# Run with: RESEND_KEY=re_xxx mix test --include integration
ExUnit.start(exclude: [:integration])
