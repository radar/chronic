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

        %{ year: year, month: month, day: day } = find_next_day_of_the_week(current_date, day_of_the_week)

        { :ok, {{ year, month, day}, { 12, 0, 0}} |> Calendar.NaiveDateTime.from_erl!(0) }
      end

      # Tuesday 9am
      def process([day_of_the_week: day_of_the_week, time: time], [currently: currently]) do
        {current_date, _} = currently

        %{ year: year, month: month, day: day } = find_next_day_of_the_week(current_date, day_of_the_week)

        { :ok, combine(year: year, month: month, day: day, time: time) }
      end

      # Tuesday at 9am
      def process([{:day_of_the_week, day_of_the_week}, "at", {:time, time}], [currently: currently]) do
        {current_date, _} = currently

        %{ year: year, month: month, day: day } = find_next_day_of_the_week(current_date, day_of_the_week)

        { :ok,  combine(year: year, month: month, day: day, time: time) }
      end
    end
  end
end
