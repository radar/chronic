defmodule Chronic.DayOfTheWeekTest do
  use ExUnit.Case, async: true
  use Chronic.TestHelpers

  test "tuesday" do
    { :ok, time, offset } = Chronic.parse("tuesday", currently: frozen_time)
    assert time == %Calendar.NaiveDateTime{year: 2015, month: 5, day: 12, hour: 12, min: 0, sec: 0, usec: 0}
    assert offset == 0
  end

  test "Tuesday" do
    { :ok, time, offset } = Chronic.parse("Tuesday", currently: frozen_time)
    assert time == %Calendar.NaiveDateTime{year: 2015, month: 5, day: 12, hour: 12, min: 0, sec: 0, usec: 0}
    assert offset == 0
  end

  test "tue" do
    { :ok, time, offset } = Chronic.parse("tue", currently: frozen_time)
    assert time == %Calendar.NaiveDateTime{year: 2015, month: 5, day: 12, hour: 12, min: 0, sec: 0, usec: 0}
    assert offset == 0
  end

  test "Tuesday 9am" do
    { :ok, time, offset } = Chronic.parse("Tuesday 9am", currently: frozen_time)
    assert time == %Calendar.NaiveDateTime{year: 2015, month: 5, day: 12, hour: 9, min: 0, sec: 0, usec: 0}
    assert offset == 0
  end

  test "Tuesday at 9am" do
    { :ok, time, offset } = Chronic.parse("Tuesday at 9am", currently: frozen_time)
    assert time == %Calendar.NaiveDateTime{year: 2015, month: 5, day: 12, hour: 9, min: 0, sec: 0, usec: 0}
    assert offset == 0
  end
end
