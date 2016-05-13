defmodule Chronic do
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

  def scan([day_of_the_week: day_of_the_week], [currently: currently]) do
    {current_date, _} = currently

    %{ year: year, month: month, day: day } = Calendar.Date.days_after(current_date) 
      |> Enum.take(7)
      |> Enum.find(fn(date) ->
        Calendar.Date.day_of_week_zb(date) == day_of_the_week
      end)

    {{ year, month, day}, { 12, 0, 0}} |> Calendar.NaiveDateTime.from_erl!(0)
  end

  def parse(time, opts \\ []) do
    case Calendar.NaiveDateTime.Parse.iso8601(time) do
      { :ok, time, offset } ->
        { :ok, time, offset }
      _ ->
        currently = opts[:currently] || :calendar.universal_time
        { :ok, time |> preprocess |> scan(currently: currently), 0 }
    end
  end

  defp preprocess(time) do
    String.replace(time, "-", " ") |> String.split(" ") |> Chronic.Tokenizer.tokenize
  end

  defp combine(currently, month: month, day: day) do
    {{ year, _, _ }, _} = currently
    {{ year, month, process_day(day) }, { 0, 0, 0 }} |> Calendar.NaiveDateTime.from_erl!
  end

  defp combine(currently, month: month, day: day, time: time) do
    {{ year, _, _ }, _} = currently

    [hour: hour, minute: minute, second: second, usec: usec] = parse_time(time)
    
    {{ year, month, process_day(day) }, { hour, minute, second }} |> Calendar.NaiveDateTime.from_erl!(usec)
  end

  defp process_day(day) when is_integer(day) do
    day
  end

  defp process_day(day) do
    Regex.replace(~r/st|nd|rd|th/, day, "") |> String.to_integer
  end

  defp parse_time([hour: hour, minute: minute, second: second, usec: usec, am_or_pm: am_or_pm]) do
    hour = String.to_integer(hour)
    hour = if am_or_pm == "pm", do: hour + 12, else: hour
    minute = if minute == "", do: 0, else: String.to_integer(minute)
    second = if second == "", do: 0, else: String.to_integer(second)
    usec = if usec == "", do: 0, else: String.to_integer(usec)

    [hour: hour, minute: minute, second: second, usec: usec]
  end
end
