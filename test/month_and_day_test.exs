defmodule Chronic.MonthAndDayTest do
  use ExUnit.Case, async: true
  use Chronic.TestHelpers

  test "month and day" do
    { :ok, time, offset } = Chronic.parse("aug 3")

    assert time == %Calendar.NaiveDateTime{year: current_year, month: 8, day: 3, hour: 0, min: 0, sec: 0, usec: nil}
    assert offset == 0
  end

  test "capitalised month and day" do
    { :ok, time, offset } = Chronic.parse("AUG 3")

    assert time == %Calendar.NaiveDateTime{year: current_year, month: 8, day: 3, hour: 0, min: 0, sec: 0, usec: nil}
    assert offset == 0
  end

  test "month and ordinalized day" do
    { :ok, time, offset } = Chronic.parse("aug 3rd")

    assert time == %Calendar.NaiveDateTime{year: current_year, month: 8, day: 3, hour: 0, min: 0, sec: 0, usec: nil}
    assert offset == 0
  end

  test "month with dot and date (aug. 3)" do
    { :ok, time, offset } = Chronic.parse("aug. 3")
    assert time == %Calendar.NaiveDateTime{year: current_year, month: 8, day: 3, hour: 0, min: 0, sec: 0, usec: nil}
    assert offset == 0
  end

  test "month and day with dash" do
    { :ok, time, offset } = Chronic.parse("aug-20")
    assert time == %Calendar.NaiveDateTime{year: current_year, month: 8, day: 20, hour: 0, min: 0, sec: 0, usec: nil}
    assert offset == 0
  end

  test "month with day, and PM time" do
    { :ok, time, offset } = Chronic.parse("aug 3 5:26pm")
    assert time == %Calendar.NaiveDateTime{year: current_year, day: 3, hour: 17, min: 26, month: 8, sec: 0, usec: 0}
    assert offset == 0
  end

  test "month with day, and AM time" do
    { :ok, time, offset } = Chronic.parse("aug 3 9:26am")
    assert time == %Calendar.NaiveDateTime{year: current_year, month: 8, day: 3, hour: 9, min: 26, sec: 0, usec: 0}
    assert offset == 0
  end

  test "month with day, with 'at' AM time" do
    { :ok, time, offset } = Chronic.parse("aug 3 at 9:26am")
    assert time == %Calendar.NaiveDateTime{year: current_year, month: 8, day: 3, hour: 9, min: 26, sec: 0, usec: 0}
    assert offset == 0
  end

  test "month with day, with 'at' AM time with seconds" do
    { :ok, time, offset } = Chronic.parse("aug 3 at 9:26:15am")
    assert time == %Calendar.NaiveDateTime{year: current_year, day: 3, hour: 9, min: 26, month: 8, sec: 15, usec: 0}
    assert offset == 0
  end

  test "month with day, with 'at' AM time with seconds and microseconds" do
    { :ok, time, offset } = Chronic.parse("may 28 at 5:32:19.764")
    assert time == %Calendar.NaiveDateTime{year: current_year, month: 5, day: 28, hour: 5, min: 32, sec: 19, usec: 764}
    assert offset == 0
  end
end
