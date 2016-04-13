defmodule ProsperMigrate.Repo do
  use Ecto.Repo, otp_app: :prosper_migrate, adapter: Sqlite.Ecto
end