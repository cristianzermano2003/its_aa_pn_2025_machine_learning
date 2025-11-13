import Config

config :quiz_app,
  ecto_repos: [QuizApp.Repo],
  generators: [timestamp_type: :utc_datetime_usec]

config :quiz_app, QuizAppWeb.Endpoint,
  adapter: Phoenix.Endpoint.Cowboy2Adapter,
  render_errors: [
    formats: [html: QuizAppWeb.ErrorHTML, json: QuizAppWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: QuizApp.PubSub,
  live_view: [signing_salt: "quiz_app_salt"]

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :phoenix, :json_library, Jason

config :esbuild,
  version: "0.17.11",
  default: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:./fonts --external:./images),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

config :tailwind,
  version: "3.3.5",
  default: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

import_config "#{config_env()}.exs"
