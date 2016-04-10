defmodule ProsperMigrate.Repo do
  use Ecto.Repo, otp_app: :blog, adapter: Sqlite.Ecto
end