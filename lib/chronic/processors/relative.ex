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

      defp process_yesterday(currently, time) do
        {{ _, month, day }, _} = currently

        { :ok, datetime } = combine(currently, month: month, day: day, time: time)
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

      def process_tomorrow(currently, time) do
        # Tomorrow at 9am
        {{ _, month, day }, _} = currently

        { :ok, datetime } = combine(currently, month: month, day: day, time: time)
                            |> Calendar.NaiveDateTime.add(86400)

        { :ok, datetime }
      end

      # Today 9am
      def process([word: "today", time: time], [currently: currently]) do
        { :ok, date_for(currently) |> date_with_time(time) }
      end

      # Today at 9am
      def process([word: "today", word: "at", time: time], [currently: currently]) do
        { :ok, date_for(currently) |> date_with_time(time) }
      end

      # Tueesday
      def process([day_of_the_week: day_of_the_week], [currently: currently]) do
        {current_date, _} = currently

        parts = find_next_day_of_the_week(current_date, day_of_the_week) ++ [hour: 12, minute: 0, second: 0, usec: 0]
        { :ok, combine(parts) }
      end

      # Tuesday 9am
      def process([day_of_the_week: day_of_the_week, time: time], [currently: currently]) do
        {current_date, _} = currently

        parts = find_next_day_of_the_week(current_date, day_of_the_week) ++ parse_time(time)

        { :ok, combine(parts) }
      end

      # Tuesday at 9am
      def process([day_of_the_week: day_of_the_week, word: "at", time: time], [currently: currently]) do
        {current_date, _} = currently

        parts = find_next_day_of_the_week(current_date, day_of_the_week) ++ parse_time(time)

        { :ok, combine(parts) }
      end

      # 6 in the morning
      def process([number: hour, word: "in", word: "the", word: "morning"], [currently: currently]) do
        {{year, month, day}, _} = currently

        { :ok, combine(year: year, month: month, day: day, hour: hour, minute: 0, second: 0, usec: 0) }
      end

      # 6 in the evening
      def process([number: hour, word: "in", word: "the", word: "evening"], [currently: currently]) do
        {{year, month, day}, _} = currently

        { :ok, combine(year: year, month: month, day: day, hour: hour + 12, minute: 0, second: 0, usec: 0) }
      end
    end
  end
end
