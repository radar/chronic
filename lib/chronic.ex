defmodule Chronic do
  @moduledoc """
    Chronic is a Pure Elixir natural language parser for times and dates
  """

  @doc """
    Parses the specified time. Will return `{:ok, time, utc_offset}` if it knows a time, otherwise `{:error, :unknown_format}`

    ## Examples

    ISO8601 times will return an offset if one is specified:

      iex> Chronic.parse("2012-08-02T13:00:00")
      { :ok, %NaiveDateTime{day: 2, hour: 13, minute: 0, month: 8, second: 0, microsecond: {0,0}, year: 2012}, nil }

      iex> Chronic.parse("2012-08-02T13:00:00+01:00")
      { :ok, %NaiveDateTime{day: 2, hour: 13, minute: 0, month: 8, second: 0, microsecond: {0,0}, year: 2012}, 3600 }

    You can pass an option to define the "current" time for Chronic:

      iex> Chronic.parse("aug 2", currently: {{1999, 1, 1}, {0,0,0}})
      { :ok, %NaiveDateTime{day: 2, hour: 0, minute: 0, month: 8, second: 0, microsecond: {0, 6}, year: 1999}, 0 }

    **All examples here use `currently` so that they are not affected by the passing of time. You may leave the `currently` option off.**

      iex> Chronic.parse("aug 2 9am", currently: {{2016, 1, 1}, {0,0,0}})
      { :ok, %NaiveDateTime{day: 2, hour: 9, minute: 0, month: 8, second: 0, microsecond: {0, 6}, year: 2016}, 0 }

      iex> Chronic.parse("aug 2 9:15am", currently: {{2016, 1, 1}, {0,0,0}})
      { :ok, %NaiveDateTime{day: 2, hour: 9, minute: 15, month: 8, second: 0, microsecond: {0, 6}, year: 2016}, 0 }

      iex> Chronic.parse("aug 2nd 9:15am", currently: {{2016, 1, 1}, {0,0,0}})
      { :ok, %NaiveDateTime{day: 2, hour: 9, minute: 15, month: 8, second: 0, microsecond: {0, 6}, year: 2016}, 0 }

      iex> Chronic.parse("aug. 2nd 9:15am", currently: {{2016, 1, 1}, {0,0,0}})
      { :ok, %NaiveDateTime{day: 2, hour: 9, minute: 15, month: 8, second: 0, microsecond: {0, 6}, year: 2016}, 0 }

      iex> Chronic.parse("2 aug 9:15am", currently: {{2016, 1, 1}, {0,0,0}})
      { :ok, %NaiveDateTime{day: 2, hour: 9, minute: 15, month: 8, second: 0, microsecond: {0, 6}, year: 2016}, 0 }

      iex> Chronic.parse("2 aug at 9:15am", currently: {{2016, 1, 1}, {0,0,0}})
      { :ok, %NaiveDateTime{day: 2, hour: 9, minute: 15, month: 8, second: 0, microsecond: {0, 6}, year: 2016}, 0 }

      iex> Chronic.parse("2nd of aug 9:15am", currently: {{2016, 1, 1}, {0,0,0}})
      { :ok, %NaiveDateTime{day: 2, hour: 9, minute: 15, month: 8, second: 0, microsecond: {0, 6}, year: 2016}, 0 }

      iex> Chronic.parse("2nd of aug at 9:15am", currently: {{2016, 1, 1}, {0,0,0}})
      { :ok, %NaiveDateTime{day: 2, hour: 9, minute: 15, month: 8, second: 0, microsecond: {0,6}, year: 2016}, 0 }

      iex> Chronic.parse("2nd of aug at 9:15 am", currently: {{2016, 1, 1}, {0,0,0}})
      { :ok, %NaiveDateTime{day: 2, hour: 9, minute: 15, month: 8, second: 0, microsecond: {0,6}, year: 2016}, 0 }

      iex> Chronic.parse("Feb 29", currently: {{2016, 1, 1}, {0,0,0}})
      { :ok, %NaiveDateTime{day: 29, hour: 0, minute: 0, month: 2, second: 0, microsecond: {0,6}, year: 2016}, 0 }

      iex> Chronic.parse("Feb 29", currently: {{2017, 1, 1}, {0,0,0}})
      { :error, :invalid_datetime }

      iex> Chronic.parse("Nov 31")
      { :error, :invalid_datetime }
  """
  def parse(time, opts \\ []) do
    case DateTime.from_iso8601(time) do
      {:ok, %DateTime{} = dt, offset} ->
        ndt = DateTime.to_naive(dt) |> NaiveDateTime.add(offset)
        {:ok, ndt, offset}

      {:error, :missing_offset} ->
        ndt = NaiveDateTime.from_iso8601!(time)
        {:ok, ndt, nil}

      _ -> parse_natural_language(time, opts)
    end
  end

  defp parse_natural_language(time_as_string, opts) do
    currently = opts[:currently] || :calendar.universal_time
    result = time_as_string |> preprocess |> debug(opts[:debug]) |> process(currently: currently)

    with {:ok, datetime = %NaiveDateTime{} } <- result do
      { :ok, datetime, 0 }
    else
      {:error, :invalid_date} -> {:error, :invalid_datetime}
      {:error, :unknown_format} -> {:error, :unknown_format}
    end
  end

  defp preprocess(time) do
    String.replace(time, "-", " ")
    # Converts strings like "9 am" to "9 am"
    |> String.replace(~r/(?<=\d)\s+(?=[a|p]m\b)/i, "")
    |> String.split(" ")
    |> Chronic.Tokenizer.tokenize
  end

  # Aug 2
  defp process([month: month, number: day], [currently: currently]) do
    process_day_and_month(currently, day, month)
  end

  # Aug 2 9am
  defp process([month: month, number: day, time: time], [currently: currently]) do
    process_day_and_month(currently, day, month, time)
  end

  # Aug 2 at 9am
  defp process([month: month, number: day, word: "at", time: time], [currently: currently]) do
    process_day_and_month(currently, day, month, time)
  end

  # 2 Aug
  defp process([number: day, month: month], [currently: currently]) do
    process_day_and_month(currently, day, month)
  end

  # 2016 Aug 2
  defp process([number: day, month: month, number: year], [currently: currently]) when day <= 31 do
    process_day_and_month_and_year(currently, day, month, year)
  end

  # 2 Aug 2016
  defp process([number: year, month: month, number: day], [currently: currently]) when day > 31 do
    process_day_and_month_and_year(currently, day, month, year)
  end

  defp process([number: year, month: month, number: day], [currently: currently]) do
    process_day_and_month_and_year(currently, day, month, year)
  end

  # 2 Aug 9am
  defp process([number: day, month: month, time: time], [currently: currently]) do
    process_day_and_month(currently, day, month, time)
  end

  # 2 Aug at 9am
  defp process([number: day, month: month, word: "at", time: time], [currently: currently]) do
    process_day_and_month(currently, day, month, time)
  end

  # 2nd of Aug
  defp process([number: day, word: "of", month: month], [currently: currently]) do
    process_day_and_month(currently, day, month)
  end

  # 2nd of Aug 9am
  defp process([number: day, word: "of", month: month, time: time], [currently: currently]) do
    process_day_and_month(currently, day, month, time)
  end

  # 2nd of Aug at 9am
  defp process([number: day, word: "of", month: month, word: "at", time: time], [currently: currently]) do
    process_day_and_month(currently, day, month, time)
  end

  # 9am
  # 9:30am
  # 9:30:15am
  # 9:30:15.123456am
  defp process([time: time], [currently: currently]) do
    combine(currently, time: time)
  end

  # 10 to 8
  defp process([number: minutes, word: "to", number: hour], [currently: {{year, month, day}, _}]) do
    with {:ok, datetime} <- combine(
      year: year,
      month: month,
      day: day,
      hour: hour,
      minute: 0,
      second: 0,
      microsecond: {0, 6}
    ) do
      {:ok, datetime |> NaiveDateTime.add(-minutes * 60, :second)}
    end
  end

  # 10 to 8am
  defp process([number: minutes, word: "to", time: time], [currently: {{year, month, day}, _}]) do
    with {:ok, datetime} <- combine([year: year, month: month, day: day] ++ time) do
      {:ok, datetime |> NaiveDateTime.add(-minutes * 60, :second)}
    end
  end

  # half past 2
  # half past 2pm
  defp process([word: "half", word: "past", number: hour], [currently: {{year, month, day}, _}]) do
    dt = combine(
      year: year,
      month: month,
      day: day,
      hour: hour,
      minute: 0,
      second: 0,
      microsecond: {0, 6}
    )
    with {:ok, datetime} <- dt do
      {:ok, datetime |> NaiveDateTime.add(30 * 60)}
    end
  end

  # Yesterday at 9am
  defp process([word: "yesterday", word: "at", time: time], [currently: currently]) do
    process_yesterday(currently, time)
  end

  # Yesterday 9am
  defp process([word: "yesterday", time: time], [currently: currently]) do
    process_yesterday(currently, time)
  end

  # Tomorrow at 9am
  defp process([word: "tomorrow", word: "at", time: time], [currently: currently]) do
    process_tomorrow(currently, time)
  end

  # Today 9am
  defp process([word: "today", time: time], [currently: currently]) do
    process_today(currently, time)
  end

  # Today at 9am
  defp process([word: "today", word: "at", time: time], [currently: currently]) do
    process_today(currently, time)
  end

  # Tueesday
  defp process([day_of_the_week: day_of_the_week], [currently: { current_date, _}]) do
    parts = find_next_day_of_the_week(current_date, day_of_the_week) ++ [hour: 12, minute: 0, second: 0, microsecond: {0, 6}]
    combine(parts)
  end

  # Tuesday 9am
  defp process([day_of_the_week: day_of_the_week, time: time], [currently: currently]) do
    process_day_of_the_week_with_time(currently, day_of_the_week, time)
  end

  # Tuesday at 9am
  defp process([day_of_the_week: day_of_the_week, word: "at", time: time], [currently: currently]) do
    process_day_of_the_week_with_time(currently, day_of_the_week, time)
  end

  # 6 in the morning
  defp process([number: hour, word: "in", word: "the", word: "morning"], [currently: {{year, month, day}, _}]) do
    combine(year: year, month: month, day: day, hour: hour, minute: 0, second: 0, microsecond: {0, 6})
  end

  # 6 in the evening
  defp process([number: hour, word: "in", word: "the", word: "evening"], [currently: {{year, month, day}, _}]) do
    combine(year: year, month: month, day: day, hour: hour + 12, minute: 0, second: 0, microsecond: {0, 6})
  end

  # sat 7 in the evening
  defp process([day_of_the_week: day_of_the_week, number: hour, word: "in", word: "the", word: "evening"], [currently: currently]) do
    hour = hour + 12
    date = date_for(currently) |> find_next_day_of_the_week(day_of_the_week)

    combine(date ++ [hour: hour, minute: 0, second: 0, microsecond: {0, 6}])
  end

  defp process(_, _opts) do
    { :error, :unknown_format }
  end

  defp process_day_and_month(currently, day, month) do
    combine(currently, month: month, day: day)
  end

  defp process_day_and_month(currently, day, month, time) do
    combine(currently, month: month, day: day, time: time)
  end

  defp process_day_and_month_and_year(currently, day, month, year) do
    combine(currently, month: month, day: day, year: year)
  end

  defp process_day_of_the_week_with_time(currently, day_of_the_week, time) do
    parts = (date_for(currently) |> find_next_day_of_the_week(day_of_the_week))

    combine(parts ++ time)
  end

  defp process_yesterday({{year, month, day}, _}, time) do
    with {:ok, datetime} <- combine([year: year, month: month, day: day] ++ time) do
      {:ok, datetime |> NaiveDateTime.add(-86400)}
    end
  end

  defp process_tomorrow({{year, month, day}, _}, time) do
    with {:ok, datetime} <- combine([year: year, month: month, day: day] ++ time) do
      {:ok, datetime |> NaiveDateTime.add(86400)}
    end
  end

  defp process_today(currently, time) do
    date_for(currently) |> date_with_time(time)
  end

  defp combine(_, month: month, day: day, year: year) do
    with {:ok, datetime} <- combine(
      year: year,
      month: month,
      day: day,
      hour: 0,
      minute: 0,
      second: 0,
      microsecond: {0, 6}
    ) do
      {:ok, datetime |> change_year_to_four_digit}
    end
  end

  defp combine({{year, _, _}, _}, month: month, day: day) do
    combine(year: year, month: month, day: day, hour: 0, minute: 0, second: 0, microsecond: {0, 6})
  end

  defp combine({{year, _, _}, _}, month: month, day: day, time: time) do
    combine([year: year, month: month, day: day] ++ time)
  end

  defp combine({{year, month, day}, _}, time: time) do
    combine([year: year, month: month, day: day] ++ time)
  end

  defp combine(year: year, month: month, day: day, hour: hour, minute: minute, second: second, microsecond: microsecond) do
    {{ year, month, day }, { hour, minute, second }} |> NaiveDateTime.from_erl(microsecond)
  end

  defp change_year_to_four_digit(%NaiveDateTime{year: year} = ndt, year_guess \\ 2016) do
    changed_year = year |> two_to_four_digit(year_guess)
    %NaiveDateTime{ndt | year: changed_year}
  end

  defp two_to_four_digit(year, year_guess) when year < 100 do
    closest_year(year, year_guess)
  end
  defp two_to_four_digit(year, _), do: year

  defp closest_year(two_digit_year, year_guessing_base) do
    two_digit_year
    |> possible_years(year_guessing_base)
    |> Enum.map(fn year -> {year, abs(year_guessing_base-year)} end)
    |> Enum.min_by(fn {_year, diff} -> diff end)
    |> elem(0)
  end

  defp possible_years(two_digit_year, year_guessing_base) do
    centuries_for_guessing_base(year_guessing_base)
    |> Enum.map(&(&1+two_digit_year))
  end

  # The three centuries closest to the guessing base
  # if you provide e.g. 2016 it should return [1900, 2000, 2100]
  defp centuries_for_guessing_base(year_guessing_base) do
    base_century = year_guessing_base-rem(year_guessing_base, 100)
    [base_century-100, base_century, base_century+100]
  end

  defp find_next_day_of_the_week(current_date, day_of_the_week) do
    current_date = case current_date do
      %Date{} -> current_date
      {_, _, _} = erl_date -> Date.from_erl!(erl_date)
    end

    tomorrow = Date.add(current_date, 1)

    if Date.day_of_week(tomorrow) == day_of_the_week do
      %{ year: year, month: month, day: day } = tomorrow
      [year: year, month: month, day: day]
    else
      find_next_day_of_the_week(tomorrow, day_of_the_week)
    end
  end

  defp date_for({date, _}), do: date

  defp date_with_time({year, month, day}, time) do
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
