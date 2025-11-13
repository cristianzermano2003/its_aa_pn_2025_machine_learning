defmodule QuizAppWeb.ConnCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      # The default endpoint for testing
      @endpoint QuizAppWeb.Endpoint

      use Phoenix.ConnTest
      import Phoenix.LiveViewTest
      import QuizAppWeb.Router.Helpers

      # The default endpoint for testing
      @endpoint QuizAppWeb.Endpoint
    end
  end

  setup _tags do
    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end
end
