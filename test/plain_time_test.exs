defmodule Chronic.PlainTimeTest do
  use ExUnit.Case, async: true
  use Chronic.TestHelpers

  test "11am" do
    { :ok, time, offset } = Chronic.parse("11am", currently: frozen_time)

    assert time == %Calendar.NaiveDateTime{year: 2015, month: 5, day: 9, hour: 11, min: 0, sec: 0, usec: 0}
    assert offset == 0
  end
end
