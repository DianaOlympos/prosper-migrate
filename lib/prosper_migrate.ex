defmodule ProsperMigrate do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(ProsperMigrate.Repo, []),
      supervisor(Task.Supervisor, [[name: ProsperMigrate.TaskSupervisor, restart: :transient]]),
      ProsperMigrate.InfluxConnection.child_spec
      # Define workers and child supervisors to be supervised
      # worker(ProsperMigrate.Worker, [arg1, arg2, arg3]),
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ProsperMigrate.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
