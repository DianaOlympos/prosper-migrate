defmodule ProsperMigrate.ExtractSqlite do
  alias ProsperMigrate.Repo
  alias ProsperMigrate.InsertInflux
  import Ecto.Query


  def seed_influx() do
    extract_itemID()
    |> Stream.chunk(5,5,[0,0,0,0,0,0,0,0,0,0])
    |> Stream.map(fn x -> Enum.map(x,&async_workers/1) end)
    |> Stream.run()
  end

  defp extract_itemID() do
      query = from(s in "snapshot_evecentral")
      |> distinct(true)
      |> select([s], s."typeid")

      query
      |> Repo.all([timeout: 600000,pool_timeout: 600000])
      |> Enum.sort()
  end

  def async_workers(0) do
    :ok
  end

  def async_workers(id) do
    Task.Supervisor.async(ProsperMigrate.TaskSupervisor,
                          fn x=^id -> extract_and_seed(x) end)
    |> Task.await(60000)
  end

  def extract_and_seed(id) do
    id
    |> extract_item()
    |> seed_from_item()
  end

  def extract_item(itemID) do
    query = from(s in "snapshot_evecentral")
    |> where([s], s."typeid"== ^itemID)
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