defmodule Chronic.Mixfile do
  use Mix.Project

  def project do
    [app: :chronic,
     version: "2.0.1",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     package: package(),
     deps: deps()]
  end

  def application do
    [applications: [:calendar]]
  end

  defp deps do
    [
      {:calendar, "~> 0.14"},
      {:earmark, "~> 0.1", only: :dev},
      {:ex_doc, "~> 0.11", only: :dev}
   ]
  end

  defp package do
    [
      name: :chronic,
      description: "Natural language datetime parser.",
      files: ["lib", "README*", "mix.exs"],
      maintainers: ["Ryan Bigg"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/radar/chronic"}
    ]
  end
end
