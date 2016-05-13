ExUnit.start()

defmodule Chronic.TestHelpers do
  defmacro __using__(_) do
    quote do
      def frozen_time do
        {{2015, 5, 9}, {9, 0, 0}}
      end

      def current_year do
        {{year, _, _}, _} = :calendar.universal_time
        year
      end
    end
  end
end
