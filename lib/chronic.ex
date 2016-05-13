defmodule Chronic do
  use Chronic.Processors.MonthAndDay
  use Chronic.Processors.Relative
  use Chronic.Processors.PlainTime

  def parse(time, opts \\ []) do
    case Calendar.NaiveDateTime.Parse.iso8601(time) do
      { :ok, time, offset } ->
        { :ok, time, offset }
      _ ->
        currently = opts[:currently] || :calendar.universal_time
        result = time |> preprocess |> debug(opts[:debug]) |> process(currently: currently)
        case result do
          { :ok, time } ->
            { :ok, time, 0 }
          error ->
            error
        end
    end
  end

  defp preprocess(time) do
    String.replace(time, "-", " ") |> String.split(" ") |> Chronic.Tokenizer.tokenize
  end

  def process(_, _opts) do
    { :error, :unknown_format }
  end

  defp combine(currently, month: month, day: day) do
    {{ year, _, _ }, _} = currently
    combine(year: year, month: month, day: day, hour: 0, minute: 0, second: 0, usec: 0)
  end

  defp combine(currently, month: month, day: day, time: time) do
    {{ year, _, _ }, _} = currently

    combine([year: year, month: month, day: day] ++ time)
  end

  defp combine(currently, time: time) do
    {{year, month, day}, _} = currently

    combine([year: year, month: month, day: day] ++ time)
  end

  defp combine(year: year, month: month, day: day, hour: hour, minute: minute, second: second, usec: usec) do
    {{ year, month, day }, { hour, minute, second }} |> Calendar.NaiveDateTime.from_erl!(usec)
  end

  defp find_next_day_of_the_week(current_date, day_of_the_week) do
    %{ year: year, month: month, day: day } = Calendar.Date.days_after(current_date) 
      |> Enum.take(7)
      |> Enum.find(fn(date) ->
        Calendar.Date.day_of_week_zb(date) == day_of_the_week
      end)
    [year: year, month: month, day: day]
  end

  def date_for(datetime) do
    {date, _} = datetime
    date
  end

  def date_with_time(date, time) do
    { year, month, day } = date

    parts = [year: year, month: month, day: day] ++ time

    combine(parts)
  end

  defp debug(result, debug) when debug == true do
    IO.inspect(result)
  end

  defp debug(result, _debug) do
    result
  end
end
