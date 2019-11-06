defmodule DomainLogic.DomainQuery.Mixfile do
  use Mix.Project

  @version "0.1.0"
  @elixir_version "~> 1.8"

  def project do
    [
      app: :domain_logic,
      version: @version,
      elixir: @elixir_version,
      elixirc_paths: elixirc_paths(Mix.env()),
      deps: deps(),

      description: description(),
      package: package(),

      aliases: aliases(),
      dialyzer: dialyzer(),

      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [coveralls: :test, "coveralls.detail": :test, "coveralls.post": :test, "coveralls.html": :test]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "task", "priv", "test/support"]
  defp elixirc_paths(_), do: ["lib", "task"]

  defp deps do
    [
      # ECTO
      {:ecto_sql, "~>  3.2"},
      # PAGINATION
      {:scrivener_ecto, "~> 2.0"},

      # DEV AND TEST
      {:myxql, "~> 0.2.0", only: [:dev, :test]},
      {:dialyxir, "~> 0.5", only: :dev, runtime: false},
      {:credo, "~>1.0", only: :dev, runtime: false},
      {:mix_test_watch, "~> 0.9", only: :dev, runtime: false},

      {:mariaex, "~> 0.9", only: :test},
      {:ex_machina, "~> 2.2", only: :test},
      {:excoveralls, "~> 0.11", only: :test}
    ]
  end

  defp description do
    """
    Domain Logic for Ecto Models
    """
  end

  defp package do
    [
      maintainers: ["Chris Douglas"],
      licenses: ["TODO"],
      links: %{"Github" => "https://github.com/dougo-chris/domain_logic"},
      files: ~w(lib mix.exs README.md)
    ]
  end

  defp aliases do
    [
      test: ["ecto.drop --quiet", "ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end

  defp dialyzer do
    [
      plt_add_deps: :transitive,
      plt_add_apps: [:mix]
    ]
  end
end
