defmodule Chronic.Mixfile do
  use Mix.Project

  def project do
    [app: :chronic,
     version: "3.0.0",
     elixir: "~> 1.5",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     package: package(),
     deps: deps()]
  end

  def application do
    [applications: []]
  end

  defp deps do
    [
      {:earmark, "~> 0.1", only: :dev},
      {:ex_doc, "~> 0.11", only: :dev},
      {:credo, "~> 0.10.0", only: [:dev, :test], runtime: false}
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
