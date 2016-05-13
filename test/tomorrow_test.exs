defmodule Chronic.TomorrowTest do
  use ExUnit.Case, async: true
  use Chronic.TestHelpers
  
  test "tomorrow at 10am" do
    { :ok, time, offset } = Chronic.parse("tomorrow at 10am", currently: frozen_time)
    assert time == %Calendar.NaiveDateTime{year: 2015, month: 5, day: 10, hour: 10, min: 0, sec: 0, usec: 0}
    assert offset == 0
  end
end
