import Config

config :quiz_app, QuizAppWeb.Endpoint,
  url: [host: System.get_env("PHX_HOST") || "example.com", port: 443, scheme: "https"],
  cache_static_manifest: "priv/static/cache_manifest.json"

config :logger, level: :info

if config_env() == :prod do
  config :quiz_app, QuizApp.Repo,
    username: System.get_env("DATABASE_USER") || "postgres",
    password: System.get_env("DATABASE_PASS") || "",
    hostname: System.get_env("DATABASE_HOST") || "localhost",
    database: System.get_env("DATABASE_NAME") || "quiz_app_prod",
    ssl: true,
    socket_options: [:inet6],
    pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10")

  config :quiz_app, QuizAppWeb.Endpoint,
    secret_key_base: System.get_env("SECRET_KEY_BASE") || raise("SECRET_KEY_BASE not set")
end
