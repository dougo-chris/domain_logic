defmodule Linklab.DomainLogic.Mixfile do
  use Mix.Project

  @version "0.1.0"
  @elixir_version "~> 1.7"

  def project do
    [
      app: :linklab_domain_logic,
      version: @version,
      elixir: @elixir_version,
      elixirc_paths: elixirc_paths(Mix.env()),
      deps: deps(),

      description: description(),
      package: package(),

      aliases: aliases(),
      dialyzer: dialyzer()
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "priv", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      # ECTO
      {:ecto_sql, "~>  3.0"},
      {:mariaex, "~> 0.9", only: :test},
      # PAGINATION
      {:scrivener_ecto, "~> 2.0"},

      # DEV AND TEST
      {:dialyxir, "~> 0.5", only: :dev, runtime: false},
      {:ex_machina, "~> 2.2", only: :test},
      {:mix_test_watch, "~> 0.9", only: :dev, runtime: false}
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
      links: %{"Github" => "TODO"},
      files: ~w(lib mix.exs README.md)
    ]
  end

  defp aliases do
    [
      test: ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end

  defp dialyzer do
    [
      plt_add_deps: :transitive,
      plt_add_apps: [:mix]
    ]
  end
end
