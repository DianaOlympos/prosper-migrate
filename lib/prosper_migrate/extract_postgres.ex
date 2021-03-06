defmodule ProsperMigrate.ExtractPostgres do
  alias ProsperMigrate.Repo
  alias ProsperMigrate.InsertInflux
  import Ecto.Query


  def seed_influx() do
    padding = List.duplicate(0,5)
    extract_itemID()
    |> Stream.chunk(5,5, padding)
    |> Stream.map(&async_extract_from_list/1)
    |> Stream.map(&(Task.await(&1, 600000)))
    |> Stream.map(&seed_worker/1)
    |> Stream.run()
  end

  defp extract_itemID() do
      query = from(s in "snapshot_evecentral")
      |> distinct(true)
      |> select([s], s."typeid")

      query
      |> Repo.all([timeout: 6000000,pool_timeout: 6000000])
      |> Enum.sort()
  end

  def async_extract_from_list(list_itemID) do
    Task.Supervisor.async_nolink(ProsperMigrate.TaskSupervisor,
                                fn -> extract_item(list_itemID) end)
  end

  def seed_worker(id) do
    Task.Supervisor.start_child(ProsperMigrate.TaskSupervisor,
                          fn -> seed_from_item(id) end)
  end

  def extract_item(list_itemID) do
    items = Enum.filter(list_itemID, &(&1!=0))
    query = from(s in "snapshot_evecentral")
    |> where([s], s."typeid" in ^items)
    |> order_by([s], asc: s.price_date, asc: s.price_time)
    |> select([s], %{price_date: s.price_date,
                     price_time: s.price_time,
                     buy_sell: s.buy_sell,
                     price_best: s.price_best,
                     price_avg: s.price_avg,
                     order_volume: s.order_volume,
                     typeid: s.typeid,
                     locationid: s.locationid,
                     location_type: s.location_type,
                     buy_sell: s.buy_sell})

    query
    |> Repo.all([timeout: 600000,pool_timeout: 600000])
  end

  def seed_from_item(list) do
    list
    |> InsertInflux.item_insert
  end

end