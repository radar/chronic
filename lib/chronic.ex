defmodule Chronic do
  @months ["jan", "feb", "mar", "apr", "may", "jun", "jul", "aug", "sep", "oct", "nov", "dec"]
  @months |> Enum.each(fn month ->
    # "aug 3"
    def unquote(:scan)([unquote(month), day], currently: currently) do
      combine(currently, month: unquote(month), day: day)
    end

    # "aug. 3"
    def unquote(:scan)([unquote(month <> "."), day], currently: currently) do
      combine(currently, month: unquote(month), day: day)
    end

    # "aug-20"
    def unquote(:scan)([unquote(month <> "-") <> day], currently: currently) do
      combine(currently, month: unquote(month), day: day)
    end

    # "aug 3 5:26pm"
    def unquote(:scan)([unquote(month), day, time], currently: currently) do
      { hour, min, sec, usec } = parse_time(time)

      combine(currently, month: unquote(month), day: day, hour: hour, min: min, sec: sec, usec: usec)
    end

    # "aug 3 at 5:26pm"
    def unquote(:scan)([unquote(month), day, "at", time], currently: currently) do
      { hour, min, sec, usec } = parse_time(time)
      combine(currently, month: unquote(month), day: day, hour: hour, min: min, sec: sec, usec: usec)
    end
  end)

  # "tomorrow at 9am"
  def scan(["tomorrow", "at", time], currently: currently) do
    { hour, min, sec, usec } = parse_time(time)
    {{ _, month, day }, _} = currently

    require IEx
    IEx.pry

    { :ok, datetime } = combine(currently, month: month, day: day, hour: hour, min: min, sec: sec, usec: usec)
                        |> Calendar.NaiveDateTime.add(86400)

    datetime
  end

  # "yesterday at 9am"
  def scan(["yesterday", "at", time], currently: currently) do
    { hour, min, sec, usec } = parse_time(time)
    {{ _, month, day }, _} = currently

    { :ok, datetime } = combine(currently, month: month, day: day, hour: hour, min: min, sec: sec, usec: usec)
                        |> Calendar.NaiveDateTime.subtract(86400)

    datetime
  end

  def parse(time, opts \\ []) do
    case Calendar.NaiveDateTime.Parse.iso8601(time) do
      { :ok, time, offset } ->
        { :ok, time, offset }
      _ ->
        currently = opts[:currently] || :calendar.universal_time
        { :ok, String.split(time, " ") |> scan(currently: currently), 0 }
    end
  end

  defp parse_time(time) do
    regex = ~r/(?<hour>\d{1,2}):?(?<minute>\d{1,2})?:?(?<second>\d{1,2})?\.?(?<usec>\d{1,6})?(?<am_or_pm>am|pm)?/
    %{ 
      "hour" => hour,
      "minute" => minute,
      "second" => second,
      "usec" => usec,
      "am_or_pm" => am_or_pm } = Regex.named_captures(regex, time)
    hour = String.to_integer(hour)
    hour = if am_or_pm == "pm", do: hour + 12, else: hour
    minute = if minute == "", do: 0, else: String.to_integer(minute)
    second = if second == "", do: 0, else: String.to_integer(second)
    usec = if usec == "", do: 0, else: String.to_integer(usec)

    { hour, minute, second, usec }
  end

  def month_number(month) when is_binary(month) do
    Enum.find_index(@months, fn (m) -> m == month end) + 1
  end

  def month_number(month) when is_integer(month) do
    month
  end

  defp combine(currently, month: month, day: day) do
    {{ year, _, _ }, { _, _, _}} = currently
    {{ year, month_number(month), process_day(day) }, { 0, 0, 0 }} |> Calendar.NaiveDateTime.from_erl!
  end

  defp combine(currently, month: month, day: day, hour: hour, min: min, sec: sec, usec: usec) do
    {{ year, _, _ }, { _, _, _}} = currently
    {{ year, month_number(month), process_day(day) }, { hour, min, sec }} |> Calendar.NaiveDateTime.from_erl!(usec)
  end

  defp process_day(day) when is_integer(day) do
    day
  end

  defp process_day(day) do
    Regex.replace(~r/st|nd|rd|th/, day, "") |> String.to_integer
  end
end
