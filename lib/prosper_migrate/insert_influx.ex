defmodule ProsperMigrate.InsertInflux do

  def item_insert(list) do
    list
    |> Enum.map(&format_row/1)
    |> Enum.map(&ProsperMigrate.InfluxConnection.write/2)
  end

  def format_row(row) do
    timestamp = Timex.to_unix({row."price_date", row."price_time"})

    buy_sell=
      if row."buy_sell" == 0 do
        "sell"
      else
        "buy"
      end

    field = %{price_best: row."price_best",
              price_avg: row."price_avg",
              order_volume: row."order_volume"}

    tags = %{typeid: to_string(row."typeid"),
             locationid: to_string(row."locationid"),
             location_type: to_string(row."location_type"),
             buy_sell: buy_sell}

    data = %{ fields: field,
              tags: tags,
              timestamp: timestamp}
    data
  end
end