defmodule QuizApp.Application do
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      QuizAppWeb.Telemetry,
      QuizApp.Repo,
      {DNSCluster, query: Application.get_env(:quiz_app, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: QuizApp.PubSub},
      QuizAppWeb.Endpoint
    ]

    opts = [strategy: :one_for_one, name: QuizApp.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @impl true
  def config_change(changed, _new, removed) do
    QuizAppWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
