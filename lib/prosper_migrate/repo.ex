defmodule ProsperMigrate.Repo do
  use Ecto.Repo, otp_app: ProsperMigrate, adapter: Sqlite.Ecto
end