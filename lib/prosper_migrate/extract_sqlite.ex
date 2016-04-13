defmodule ProsperMigrate.ExtractSqlite do
  alias ProsperMigrate.Repo
  import Ecto.Query

  def extract_itemID() do
    query = from(s in "snapshot_evecentral")
    |> distinct(true)
    |> select([s], s."typeid")

    query
    |> Repo.all(:infinity,:infinity)
    |> Enum.sort(&(&1>=&2))
  end

  def extract_item(itemID) do
    query = from(s in "snapshot_evecentral")
    |> where([s], s."typeid"== ^itemID)
    |> order_by([s], asc: s."price_date", asc: s."price_time")
    |> select([s], s)

    query
    |> Repo.all
  end

  def seed_influx() do
    item_list=extract_itemID()
    |>IO.inspect()

    # item_list
    # |> Stream.map(&extract_item/1)
    # |> Stream.map(&seed_from_item/1)
    # |> Stream.run()
  end

  def seed_from_item(list) do
    list
    |> Enum.map(&InsertInflux.item_insert/1)
  end
end