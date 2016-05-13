defmodule Chronic.Processors.MonthAndDay do
  defmacro __using__(_) do
    quote do
      # Aug 2
      def process([month: month, number: day], [currently: currently]) do
        { :ok, combine(currently, month: month, day: day) }
      end

      # Aug 2 9am
      def process([month: month, number: day, time: time], [currently: currently]) do
        { :ok, combine(currently, month: month, day: day, time: time) }
      end

      # Aug 2 at 9am
      def process([month: month, number: day, word: "at", time: time], [currently: currently]) do
        { :ok, combine(currently, month: month, day: day, time: time) }
      end
    end
  end
end
