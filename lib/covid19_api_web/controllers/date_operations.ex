defmodule Covid19ApiWeb.DateOperations do
  @date_pattern ~r/^(?<month>\d{1,2})\/(?<day>\d{1,2})\/(?<year>\d{2})$/

  @spec parse_date(String.t()) :: {:ok, Date.t()} | {:error, atom}
  def parse_date(string) when is_binary(string) do
    case @date_pattern |> Regex.named_captures(string) do
      %{"day" => day, "month" => month, "year" => year} ->
        Date.new(
          2000 + (year |> String.to_integer()),
          month |> String.to_integer(),
          day |> String.to_integer()
        )

      _ ->
        {:error, :invalid_date}
    end
  end
end
