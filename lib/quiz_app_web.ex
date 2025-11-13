defmodule QuizAppWeb do
  def static_paths, do: ~w(assets fonts images favicon.ico robots.txt)

  def router do
    quote do
      use Phoenix.Router, helpers: true

      import Plug.Conn
      import Phoenix.Controller
      import Phoenix.LiveView.Router
    end
  end

  def channel do
    quote do
      use Phoenix.Channel
      import QuizAppWeb.Gettext
    end
  end

  def controller do
    quote do
      use Phoenix.Controller,
        formats: [:html, :json],
        layouts: [html: QuizAppWeb.Layouts]

      import Plug.Conn
      import QuizAppWeb.Gettext
    end
  end

  def live_view do
    quote do
      use Phoenix.LiveView,
        layout: {QuizAppWeb.Layouts, :app}

      import QuizAppWeb.CoreComponents
      import QuizAppWeb.Gettext
    end
  end

  def live_component do
    quote do
      use Phoenix.LiveComponent

      import QuizAppWeb.CoreComponents
      import QuizAppWeb.Gettext
    end
  end

  def html do
    quote do
      use Phoenix.Component

      import Phoenix.HTML
      import Phoenix.LiveView.Helpers
      import Phoenix.Component
      import QuizAppWeb.CoreComponents
      import QuizAppWeb.Gettext
    end
  end

  @doc """
  Handles defining routes in the given module
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
