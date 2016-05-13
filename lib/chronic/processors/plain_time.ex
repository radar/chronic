defmodule Chronic.Processors.PlainTime do
  defmacro __using__(_) do
    quote do
      # 9am
      # 9:30am
      # 9:30:15am
      # 9:30:15.123456am
      def process([time: time], [currently: currently]) do
        { :ok, combine(currently, time: time) }
      end

      # 10 to 8
      def process([{:number, minutes}, "to", {:number, hour}], [currently: currently]) do
        {{year, month, day}, _} = currently

        time = combine(year: year, month: month, day: day, hour: hour, minute: 0, second: 0, usec: 0)

        time |> Calendar.NaiveDateTime.subtract(minutes * 60)
      end

      # 10 to 8am
      def process([{:number, minutes}, "to", {:time, time}], [currently: currently]) do
        {{year, month, day}, _} = currently

        ([year: year, month: month, day: day] ++ parse_time(time)) 
          |> combine
          |> Calendar.NaiveDateTime.subtract(minutes * 60)
      end
    end
  end
end
