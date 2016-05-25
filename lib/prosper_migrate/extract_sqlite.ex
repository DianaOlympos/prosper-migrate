defmodule ProsperMigrate.ExtractSqlite do
  alias ProsperMigrate.Repo
  alias ProsperMigrate.InsertInflux
  import Ecto.Query


  def seed_influx() do
    pad = List.duplicate(0,10)
    extract_itemID()
    |> Stream.chunk(10,10,pad)
    |> Stream.map(&async_workers/1)
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

  def async_workers(0) do
    :ok
  end

  def async_workers(list) do
    list
    |> Enum.map(&extract_and_seed_worker/1)
    |> Enum.map(&Task.await(&1, 60000))
  end

  def extract_and_seed_worker(0) do
    :ok
  end
  def extract_and_seed_worker(id) do
    Task.Supervisor.async(ProsperMigrate.TaskSupervisor,
                          fn -> extract_and_seed(id) end)
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