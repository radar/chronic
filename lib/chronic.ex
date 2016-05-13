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
        result = time |> preprocess |> process(currently: currently)
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
    {{ year, month, day }, { 0, 0, 0 }} |> Calendar.NaiveDateTime.from_erl!
  end

  defp combine(currently, month: month, day: day, time: time) do
    {{ year, _, _ }, _} = currently

    [hour: hour, minute: minute, second: second, usec: usec] = parse_time(time)
    
    {{ year, month, day }, { hour, minute, second }} |> Calendar.NaiveDateTime.from_erl!(usec)
  end

  defp combine(currently, time: time) do
    {{year, month, day}, _} = currently
    [hour: hour, minute: minute, second: second, usec: usec] = parse_time(time)

    {{ year, month, day }, { hour, minute, second }} |> Calendar.NaiveDateTime.from_erl!(usec)
  end

  defp combine(year: year, month: month, day: day, time: time) do
    [hour: hour, minute: minute, second: second, usec: usec] = parse_time(time)
    
    {{ year, month, day }, { hour, minute, second }} |> Calendar.NaiveDateTime.from_erl!(usec)
  end

  defp parse_time([hour: hour, minute: minute, second: second, usec: usec, am_or_pm: am_or_pm]) do
    hour = String.to_integer(hour)
    hour = if am_or_pm == "pm", do: hour + 12, else: hour
    minute = if minute == "", do: 0, else: String.to_integer(minute)
    second = if second == "", do: 0, else: String.to_integer(second)
    usec = if usec == "", do: 0, else: String.to_integer(usec)

    [hour: hour, minute: minute, second: second, usec: usec]
  end

  defp find_next_day_of_the_week(current_date, day_of_the_week) do
    Calendar.Date.days_after(current_date) 
      |> Enum.take(7)
      |> Enum.find(fn(date) ->
        Calendar.Date.day_of_week_zb(date) == day_of_the_week
      end)
  end
end
