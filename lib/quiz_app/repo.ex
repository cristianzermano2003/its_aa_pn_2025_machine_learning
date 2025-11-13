defmodule QuizApp.Repo do
  use Ecto.Repo,
    otp_app: :quiz_app,
    adapter: Ecto.Adapters.Postgres
end
