defmodule Chronic.Tokenizer do
  @day_names ["sunday", "monday", "tuesday", "wednesday", "thursday", "friday", "saturday"]
  @abbr_months ["jan", "feb", "mar", "apr", "may", "jun", "jul", "aug", "sep", "oct", "nov", "dec"]

  def tokenize([token | remainder]) do
    [tokenize(token) | tokenize(remainder)]
  end

  def tokenize([]) do
    []
  end

  def tokenize(token) do
    token = String.downcase(token)
    ordinal_regex = ~r/\A(?<number>\d+)(st|nd|rd|th)\Z/
    time_regex = ~r/(?<hour>\d{1,2}):?(?<minute>\d{1,2})?:?(?<second>\d{1,2})?\.?(?<microsecond>\d{1,6})?(?<am_or_pm>am|pm)?/

    cond do
      Enum.any?(@abbr_months, fn (month) -> matches_month?(token, month) end) ->
        {:month, month_number(token)}
      Enum.any?(@day_names, fn (dotw) -> matches_day_of_the_week?(token, dotw) end) ->
        {:day_of_the_week, day_of_the_week_number(token)}
      Regex.match?(ordinal_regex, token) ->
        %{"number" => number} = Regex.named_captures(ordinal_regex, token)
        {:number, String.to_integer(number)}
      Regex.match?(~r/\A\d+\Z/, token) ->
        {:number, String.to_integer(token)}
      Regex.match?(time_regex, token) ->
        process_time(time_regex, token)
      Regex.match?(~r/\A\w+\Z/, token) ->
        {:word, token }
      true ->
        nil
    end
  end

  def matches_month?(token, month) do
    String.starts_with?(token, month)
  end

  defp month_number(token) do
    Enum.find_index(@abbr_months, fn (month) -> matches_month?(token, month) end) + 1
  end

  defp matches_day_of_the_week?(token, day_of_the_week) do
    day_of_the_week == token || String.starts_with?(day_of_the_week, token)
  end

  defp day_of_the_week_number(token) do
    Enum.find_index(@day_names, fn (day_of_the_week) -> matches_day_of_the_week?(token, day_of_the_week) end)
  end

  defp process_time(time_regex, token) do
    %{
      "hour" => hour,
      "minute" => minute,
      "second" => second,
      "microsecond" => microsecond,
      "am_or_pm" => am_or_pm
    } = Regex.named_captures(time_regex, token)
    hour = String.to_integer(hour)
    hour = shift_hour(hour, am_or_pm)
    minute = if minute == "", do: 0, else: String.to_integer(minute)
    second = if second == "", do: 0, else: String.to_integer(second)
    microsecond = if microsecond == "", do: 0, else: String.to_integer(microsecond)

    { :time, [hour: hour, minute: minute, second: second, microsecond: {microsecond,6}] }
  end

  defp shift_hour(12, "am"), do: 0
  defp shift_hour(12, "pm"), do: 12
  defp shift_hour(hr, "pm"), do: hr + 12
  defp shift_hour(hr, _   ), do: hr
end
