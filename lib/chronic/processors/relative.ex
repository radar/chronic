defmodule Chronic.Processors.Relative do
  defmacro __using__(_) do
    quote do
      # Yesterday at 9am
      def process(["yesterday", "at", { :time, time }], [currently: currently]) do
        {{ _, month, day }, _} = currently

        { :ok, datetime } = combine(currently, month: month, day: day, time: time)
                            |> Calendar.NaiveDateTime.subtract(86400)

        { :ok, datetime }
      end

      # Tomorrow at 9am
      def process(["tomorrow", "at", { :time, time }], [currently: currently]) do
        {{ _, month, day }, _} = currently

        { :ok, datetime } = combine(currently, month: month, day: day, time: time)
                            |> Calendar.NaiveDateTime.add(86400)

        { :ok, datetime }
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
      def process([{:day_of_the_week, day_of_the_week}, "at", {:time, time}], [currently: currently]) do
        {current_date, _} = currently

        parts = find_next_day_of_the_week(current_date, day_of_the_week) ++ parse_time(time)

        { :ok, combine(parts) }
      end
    end
  end
end
