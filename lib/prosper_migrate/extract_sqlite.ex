defmodule ProsperMigrate.ExtractSqlite do
  alias ProsperMigrate.Repo
  import Ecto.Query

  def extract_itemID() do

    max = from(s in "snapshot_evecentral")
    |> select([s], count("*"))
    |> Repo.all()

    get_typeid_list([], max)
    |>Enum.sort()
  end

  defp get_typeid_list(state, position) when position <= 0 do
    state
  end
  defp get_typeid_list(state, position) do
    new_state = query_1000(position) ++ state
    new_state
    |> Enum.uniq()
    |> get_typeid_list(position-1000)
  end


  defp query_1000(position) do
    from(s in "snapshot_evecentral")
    |> select([s], s."typeid")
    |> limit(1000)
    |> offset(^position)
    |> Repo.all()
  end

  # def extract_item(itemID) do
  #   query = from(s in "snapshot_evecentral")
  #   |> where([s], s."typeid"== ^itemID)
  #   |> order_by([s], asc: s."price_date", asc: s."price_time")
  #   |> select([s], s)

  #   query
  #   |> Repo.all
  # end

  def seed_influx() do
    item_list=extract_itemID()


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