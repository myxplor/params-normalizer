defmodule ParamsNormalizer.Mixfile do
  use Mix.Project

  def project do
    [
      app: :params_normalizer,
      version: "0.1.0",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      deps: deps(),
      aliases: aliases(),
      name: "Params Normalizer",
      description: "Provides interface for normalizing params",
      dialyzer: [flags: [:error_handling]]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:dialyxir, "~> 0.5", only: [:dev], runtime: false}
    ]
  end

  defp aliases do
    [
      dialyzer: ["dialyzer -Wno_return"]
    ]
end
end
