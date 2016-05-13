defmodule Chronic.Tokenizer do
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
    month_matcher = fn (month) ->
      month == token || "#{month}." == token
    end

    ordinal_regex = ~r/\A(?<number>\d+)(st|nd|rd|th)\Z/
    time_regex = ~r/(?<hour>\d{1,2}):?(?<minute>\d{1,2})?:?(?<second>\d{1,2})?\.?(?<usec>\d{1,6})?(?<am_or_pm>am|pm)?/

    cond do
      index = Enum.find_index(@abbr_months, month_matcher) ->
        {:month, index + 1}
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
    end
  end
end
