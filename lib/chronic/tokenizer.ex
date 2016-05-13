defmodule Chronic.Tokenizer do
  @day_names ["sunday", "monday", "tuesday", "wednesday", "thursday", "friday", "saturday"]
  @abbr_months ["jan", "feb", "mar", "apr", "may", "jun", "jul", "aug", "sep", "oct", "nov", "dec"]

  def tokenize([token | remainder]) do
    [tokenize(token) | tokenize(remainder)]
  end

  def tokenize([]) do
    []
  end

  def tokenize("at") do
    "at"
  end

  def tokenize("yesterday") do
    "yesterday"
  end

  def tokenize("tomorrow") do
    "tomorrow"
  end

  def tokenize(token) do
    ordinal_regex = ~r/\A(?<number>\d+)(st|nd|rd|th)\Z/
    time_regex = ~r/(?<hour>\d{1,2}):?(?<minute>\d{1,2})?:?(?<second>\d{1,2})?\.?(?<usec>\d{1,6})?(?<am_or_pm>am|pm)?/

    month_matcher = fn (month) ->
      token = String.downcase(token)
      String.starts_with?(token, month)
    end

    cond do
      Enum.any?(@abbr_months, month_matcher) ->
        {:month, month_number(token)}
      Enum.any?(@day_names, fn (dotw) -> String.downcase(token) == dotw end) ->
        {:day_of_the_week, day_of_the_week_number(token)}
      Regex.match?(ordinal_regex, token) ->
        %{"number" => number} = Regex.named_captures(ordinal_regex, token)
        {:number, number}
      Regex.match?(~r/\A\d+\Z/, token) ->
        {:number, token}
      Regex.match?(time_regex, token) ->
        %{
          "hour" => hour,
          "minute" => minute,
          "second" => second,
          "usec" => usec,
          "am_or_pm" => am_or_pm 
        } = Regex.named_captures(time_regex, token)
        { :time, hour: hour, minute: minute, second: second, usec: usec, am_or_pm: am_or_pm }
      true ->
        raise "Unrecognised token #{token}"
    end
  end

  defp month_number(token) do
    index = Enum.find_index(@abbr_months, fn (month) ->
      token = String.downcase(token)
      # "aug" or "aug."
      month == token || "#{month}." == token
    end)
    index + 1
  end

  defp day_of_the_week_number(token) do
    Enum.find_index(@day_names, fn (dotw) ->
      dotw == String.downcase(token)
    end)
  end
end
