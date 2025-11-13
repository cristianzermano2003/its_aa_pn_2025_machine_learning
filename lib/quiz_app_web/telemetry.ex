defmodule QuizAppWeb.Telemetry do
  use Supervisor

  def start_link(arg) do
    Supervisor.start_link(__MODULE__, arg, name: __MODULE__)
  end

  @impl true
  def init(_arg) do
    children = [
      {:telemetry_poller, handlers: periodic_measurements(), period: 10_000}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

  def periodic_measurements do
    [
      {QuizAppWeb.Telemetry, :erlang_memory, []},
      {QuizAppWeb.Telemetry, :erlang_statistics, []}
    ]
  end

  def erlang_memory do
    :telemetry.execute([:vm, :memory], %{
      total: :erlang.memory(:total),
      processes: :erlang.memory(:processes),
      atom: :erlang.memory(:atom),
      binary: :erlang.memory(:binary),
      code: :erlang.memory(:code)
    })
  end

  def erlang_statistics do
    :telemetry.execute([:vm, :statistics], %{
      run_queue: :erlang.statistics(:run_queue),
      garbage_collection: :erlang.statistics(:garbage_collection)
    })
  end
end
