defmodule Revisionair.Mixfile do
  use Mix.Project

  def project do
    [app: :revisionair,
     version: "0.9.0",
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps(),
     name: "Revisionair",
    ]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    # Specify extra applications you'll use from Erlang/Elixir
    [extra_applications: [:logger]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:my_dep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:my_dep, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    []
  end


  defp description do
    """
    Keep track of revisions, versions, changes to your data. Persistence layer agnostic.
    """
  end

  defp package do
    # These are the default files included in the package
    [
      name: :revisionair,
      files: ["lib", "priv", "mix.exs", "README*"],
      maintainers: ["Qqwy/W-M"],
      licenses: ["Apache 2.0"],
      links: %{"GitHub" => "https://github.com/Qqwy/elixir_revisionair"}
    ]
  end
end
