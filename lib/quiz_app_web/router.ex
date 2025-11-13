defmodule QuizAppWeb.Router do
  use QuizAppWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {QuizAppWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  scope "/", QuizAppWeb do
    pipe_through :browser

    live "/quiz", QuizLive, :index
    live "/", HomeLive, :index
  end
end
