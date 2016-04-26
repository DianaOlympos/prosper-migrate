defmodule ProsperMigrate.ExtractSqlite do
  alias ProsperMigrate.Repo
  import Ecto.Query

  def extract_itemID() do

    get_typeid_list([], 0, false)
    |>Enum.sort()
  end

  defp get_typeid_list(state, _position, true)do
    state
  end
  defp get_typeid_list(state, position, false) do
    query_result = query_1000(position)
    continue = Enum.empty?(query_result)

    new_state = if continue do
                  Enum.uniq(query_result ++ state)
                else
                  state
                end
    get_typeid_list(new_state, position+10_000, continue)
  end


  defp query_1000(position) do
    from(s in "snapshot_evecentral")
    |> select([s], s."typeid")
    |> limit(10_000)
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