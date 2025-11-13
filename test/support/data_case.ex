defmodule QuizApp.DataCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      alias QuizApp.Repo

      import Ecto
      import Ecto.Query
      import QuizApp.DataCase

      # The default endpoint for testing
      @endpoint QuizAppWeb.Endpoint
    end
  end

  setup tags do
    QuizApp.DataCase.setup_sandbox(tags)
    :ok
  end

  def setup_sandbox(tags) do
    pid = Ecto.Adapters.SQL.Sandbox.start_owner!(QuizApp.Repo, shared: not tags[:async])
    on_exit(fn -> Ecto.Adapters.SQL.Sandbox.stop_owner(pid) end)
  end
end
