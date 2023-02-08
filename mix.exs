defmodule Resend.MixProject do
  use Mix.Project

  def project do
    [
      app: :resend,
      version: "0.1.0",
      elixir: "~> 1.14",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:swoosh, "~> 1.3"},
      {:hackney, "~> 1.9", only: [:dev, :test]},
      {:tesla, "~> 1.5"}
    ]
  end
end
