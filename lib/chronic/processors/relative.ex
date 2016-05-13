defmodule Chronic.Processors.Relative do
  defmacro __using__(_) do
    quote do
      # Yesterday at 9am
      def process([word: "yesterday", word: "at", time: time], [currently: currently]) do
        process_yesterday(currently, time)
      end

      # Yesterday 9am
      def process([word: "yesterday", time: time], [currently: currently]) do
        process_yesterday(currently, time)
      end

      defp process_yesterday({{year, month, day}, _}, time) do
        { :ok, datetime } = combine([year: year, month: month, day: day] ++ time)
                            |> Calendar.NaiveDateTime.subtract(86400)

        { :ok, datetime }
      end

      # Tomorrow at 9am
      def process([word: "tomorrow", word: "at", time: time], [currently: currently]) do
        process_tomorrow(currently, time)
      end

      # Today 9am
      def process([word: "tomorrow", word: "at", time: time], [currently: currently]) do
        process_tomorrow(currently, time)
      end

      def process_tomorrow({{year, month, day}, _}, time) do
        # Tomorrow at 9am
        { :ok, datetime } = combine([year: year, month: month, day: day] ++ time)
                            |> Calendar.NaiveDateTime.add(86400)

        { :ok, datetime }
      end

      # Today 9am
      def process([word: "today", time: time], [currently: currently]) do
        process_today(currently, time)
      end

      # Today at 9am
      def process([word: "today", word: "at", time: time], [currently: currently]) do
        process_today(currently, time)
      end

      defp process_today(currently, time) do
        { :ok, date_for(currently) |> date_with_time(time) }
      end

      # Tueesday
      def process([day_of_the_week: day_of_the_week], [currently: { current_date, _}]) do
        parts = find_next_day_of_the_week(current_date, day_of_the_week) ++ [hour: 12, minute: 0, second: 0, usec: 0]
        { :ok, combine(parts) }
      end

      # Tuesday 9am
      def process([day_of_the_week: day_of_the_week, time: time], [currently: currently]) do
        process_day_of_the_week_with_time(currently, day_of_the_week, time)
      end

      # Tuesday at 9am
      def process([day_of_the_week: day_of_the_week, word: "at", time: time], [currently: currently]) do
        process_day_of_the_week_with_time(currently, day_of_the_week, time)
      end

      defp process_day_of_the_week_with_time(currently, day_of_the_week, time) do
        parts = (date_for(currently) |> find_next_day_of_the_week(day_of_the_week))

        { :ok, combine(parts ++ time) }
      end

      # 6 in the morning
      def process([number: hour, word: "in", word: "the", word: "morning"], [currently: {{year, month, day}, _}]) do
        { :ok, combine(year: year, month: month, day: day, hour: hour, minute: 0, second: 0, usec: 0) }
      end

      # 6 in the evening
      def process([number: hour, word: "in", word: "the", word: "evening"], [currently: {{year, month, day}, _}]) do
        { :ok, combine(year: year, month: month, day: day, hour: hour + 12, minute: 0, second: 0, usec: 0) }
      end

      # sat 7 in the evening
      def process([day_of_the_week: day_of_the_week, number: hour, word: "in", word: "the", word: "evening"], [currently: currently]) do
        hour = hour + 12
        date = date_for(currently) |> find_next_day_of_the_week(day_of_the_week)

        { :ok, combine(date ++ [hour: hour, minute: 0, second: 0, usec: 0]) }
      end
    end
  end
end
