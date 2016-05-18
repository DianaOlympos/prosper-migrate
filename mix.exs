defmodule ProsperMigrate.Mixfile do
  use Mix.Project

  def project do
    [app: :prosper_migrate,
     version: "0.0.1",
     elixir: "~> 1.2",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger,:instream, :ecto, :sqlite_ecto,:timex],
     mod: {ProsperMigrate, []}]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [{:instream, "~> 0.12.0"},
     {:sqlite_ecto, "~> 1.1"},
     {:ecto, "~> 1.1"},
     {:timex, "~> 2.1"}]
  end
end
