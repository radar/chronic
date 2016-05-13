defmodule Chronic do
  def parse(time, opts \\ []) do
    case Calendar.NaiveDateTime.Parse.iso8601(time) do
      { :ok, time, offset } ->
        { :ok, time, offset }
      _ ->
        currently = opts[:currently] || :calendar.universal_time
        time = time |> preprocess |> scan(currently: currently)
        { :ok, time, 0 }
    end
  end

  def scan([month: month, number: day], [currently: currently]) do
    combine(currently, month: month, day: day)
  end

  def scan([month: month, number: day, time: time], [currently: currently]) do
    combine(currently, month: month, day: day, time: time)
  end

  def scan([{:month, month}, {:number, day}, "at", {:time, time}], [currently: currently]) do
    combine(currently, month: month, day: day, time: time)
  end

  def scan(["yesterday", "at", { :time, time }], [currently: currently]) do
    {{ _, month, day }, _} = currently

    { :ok, datetime } = combine(currently, month: month, day: day, time: time)
                        |> Calendar.NaiveDateTime.subtract(86400)

    datetime
  end

  def scan(["tomorrow", "at", { :time, time }], [currently: currently]) do
    {{ _, month, day }, _} = currently

    { :ok, datetime } = combine(currently, month: month, day: day, time: time)
                        |> Calendar.NaiveDateTime.add(86400)

    datetime
  end

  def scan([time: time], [currently: currently]) do
    combine(currently, time: time)
  end

  def scan([day_of_the_week: day_of_the_week], [currently: currently]) do
    {current_date, _} = currently

    %{ year: year, month: month, day: day } = find_next_day_of_the_week(current_date, day_of_the_week)

    {{ year, month, day}, { 12, 0, 0}} |> Calendar.NaiveDateTime.from_erl!(0)
  end

  def scan([day_of_the_week: day_of_the_week, time: time], [currently: currently]) do
    {current_date, _} = currently

    %{ year: year, month: month, day: day } = find_next_day_of_the_week(current_date, day_of_the_week)

    combine(year: year, month: month, day: day, time: time)
  end

  def scan([{:day_of_the_week, day_of_the_week}, "at", {:time, time}], [currently: currently]) do
    {current_date, _} = currently

    %{ year: year, month: month, day: day } = find_next_day_of_the_week(current_date, day_of_the_week)

    combine(year: year, month: month, day: day, time: time)
  end

  def scan(_, _opts) do
    nil
  end

  defp preprocess(time) do
    String.replace(time, "-", " ") |> String.split(" ") |> Chronic.Tokenizer.tokenize
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
