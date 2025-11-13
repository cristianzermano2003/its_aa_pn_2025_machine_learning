import Config

config :quiz_app, QuizApp.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "quiz_app_test",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

config :quiz_app, QuizAppWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "qJRi8qyr/9/DSns2QuAqyG4exqt7ba9evvLodGdjnTQ=",
  server: false

config :logger, level: :warning
