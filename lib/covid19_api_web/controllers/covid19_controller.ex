defmodule Covid19ApiWeb.Covid19Controller do
  use Covid19ApiWeb, :controller

  import Covid19ApiWeb.DateOperations

  @files %{
    "confirmed" =>
      "csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_confirmed_global.csv",
    "deaths" =>
      "csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_deaths_global.csv",
    "recovered" =>
      "csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_recovered_global.csv"
  }

  def time_series(conn, %{
        "country" => country,
        "time_series" => time_series,
        "province" => province
      })
      when is_map_key(@files, time_series) and province != "" do
    csv_data =
      time_series
      |> file_name()
      |> to_file_path()
      |> csv_data()
      |> Enum.find(&map_with_country_province?(&1, country, province))

    if csv_data do
      conn |> json(csv_data |> to_output() |> to_response_body())
    else
      conn |> put_status(404) |> json(%{error: "country/provice not found"})
    end
  end

  def time_series(conn, %{"country" => country, "province" => province}) do
    result =
      @files
      |> Map.to_list()
      |> Enum.map(fn {time_series, file_name} ->
        {time_series,
         file_name
         |> to_file_path()
         |> csv_data()
         |> Stream.filter(&map_with_country_province?(&1, country, province))
         |> Stream.map(&to_output/1)
         |> Enum.flat_map(& &1)}
      end)
      |> Stream.filter(fn {_, val} -> val != [] end)
      |> Map.new()

    if result == %{} do
      conn |> put_status(404) |> json(%{error: "country not found"})
    else
      conn |> json(result)
    end
  end

  def time_series(conn, %{"country" => country, "time_series" => time_series})
      when is_map_key(@files, time_series) do
    csv_data =
      time_series
      |> file_name()
      |> to_file_path()
      |> csv_data()
      |> Enum.find(&map_with_country?(&1, country))

    if csv_data do
      conn |> json(csv_data |> to_output() |> to_response_body())
    else
      conn |> put_status(404) |> json(%{error: "country not found"})
    end
  end

  def time_series(conn, %{"country" => country}) do
    result =
      @files
      |> Map.to_list()
      |> Enum.map(fn {time_series, file_name} ->
        {time_series,
         file_name
         |> to_file_path()
         |> csv_data()
         |> Stream.filter(&map_with_country?(&1, country))
         |> Stream.map(&to_output/1)
         |> Enum.flat_map(& &1)}
      end)
      |> Stream.filter(fn {_, val} -> val != [] end)
      |> Map.new()

    if result == %{} do
      conn |> put_status(404) |> json(%{error: "country not found"})
    else
      conn |> json(result)
    end
  end

  def time_series(conn, %{"time_series" => invalid}) do
    conn |> put_status(404) |> json(%{error: "invalid time_series: '#{invalid}'"})
  end

  def countries(conn, _) do
    countries =
      @files
      |> Map.keys()
      |> Stream.flat_map(fn time_series ->
        time_series
        |> file_name()
        |> to_file_path()
        |> csv_data()
        |> Stream.map(fn %{"Country/Region" => country} -> country end)
      end)
      |> Stream.uniq()
      |> Enum.sort()
      |> to_response_body()

    conn |> json(countries)
  end

  def provinces(conn, %{"country" => country}) do
    countries =
      @files
      |> Map.keys()
      |> Stream.flat_map(fn time_series ->
        time_series
        |> file_name()
        |> to_file_path()
        |> csv_data()
        |> Stream.flat_map(fn %{"Country/Region" => c, "Province/State" => p} ->
          if c == country and p != "", do: [p], else: []
        end)
      end)
      |> Stream.uniq()
      |> Enum.sort()
      |> to_response_body()

    conn |> json(countries)
  end

  defp map_with_country_province?(
         %{"Country/Region" => c, "Province/State" => p},
         country,
         province
       ) do
    c == country and p == province
  end

  defp map_with_country_province?(_, _, _), do: false

  defp map_with_country?(%{"Country/Region" => c, "Province/State" => ""}, country) do
    c == country
  end

  defp map_with_country?(_, _), do: false

  defp file_name(time_series), do: @files |> Map.get(time_series)
  defp to_file_path(file), do: System.get_env("REPO_BASE_DIR", ".") |> Path.join(file)

  defp csv_data(path) do
    path
    |> Path.expand(__DIR__)
    |> File.stream!()
    |> CSV.decode!(headers: true)
  end

  defp to_output(raw) do
    raw
    |> Map.to_list()
    |> Stream.flat_map(fn {csv_date, value} ->
      case parse_date(csv_date) do
        {:ok, date} -> [%{date: date, count: value |> String.to_integer()}]
        _ -> []
      end
    end)
    |> Enum.sort()
  end

  defp to_response_body(data) when is_list(data), do: %{result: data}
end
