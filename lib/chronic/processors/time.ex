defmodule Chronic.Processors.Time do
  defmacro __using__(_) do
    quote do
      # 9am
      # 9:30am
      # 9:30:15am
      # 9:30:15.123456am
      def process([time: time], [currently: currently]) do
        combine(currently, time: time)
      end
    end
  end
end
