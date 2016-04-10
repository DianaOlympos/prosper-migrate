defmodule ProsperMigrate.ExtractSqlite do
  alias ProsperMigrate.Repo
  import Ecto.Query

  def extract_itemID() do
    query = from(s in "snapshot_evecentral")
    |> distinct(true)
    |> select([s], s."typeid")

    query
    |> Repo.all
    |> Enum.sort(fn x,y -> x>=y end)
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

    item_list
    |> Stream.map(&extract_item/1)
    |> Stream.map(fn x -> Enum.map(x, &InsertInflux.item_insert/1) end)
    |> Stream.run()
  end
end