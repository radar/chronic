defmodule Chronic.DayOfTheWeekTest do
  use ExUnit.Case, async: true

  def currently do
    {{ 2015, 5, 9 }, { 9, 0, 0}}
  end

  test "tuesday" do
    { :ok, time, offset } = Chronic.parse("tuesday", currently: currently)
    assert time == %Calendar.NaiveDateTime{year: 2015, month: 5, day: 12, hour: 12, min: 0, sec: 0, usec: 0}
    assert offset == 0
  end

  test "Tuesday" do
    { :ok, time, offset } = Chronic.parse("Tuesday", currently: currently)
    assert time == %Calendar.NaiveDateTime{year: 2015, month: 5, day: 12, hour: 12, min: 0, sec: 0, usec: 0}
    assert offset == 0
  end

  test "tue" do
    { :ok, time, offset } = Chronic.parse("tue", currently: currently)
    assert time == %Calendar.NaiveDateTime{year: 2015, month: 5, day: 12, hour: 12, min: 0, sec: 0, usec: 0}
    assert offset == 0
  end

  test "Tuesday 9am" do
    { :ok, time, offset } = Chronic.parse("Tuesday 9am", currently: currently)
    assert time == %Calendar.NaiveDateTime{year: 2015, month: 5, day: 12, hour: 9, min: 0, sec: 0, usec: 0}
    assert offset == 0
  end

  test "Tuesday at 9am" do
    { :ok, time, offset } = Chronic.parse("Tuesday at 9am", currently: currently)
    assert time == %Calendar.NaiveDateTime{year: 2015, month: 5, day: 12, hour: 9, min: 0, sec: 0, usec: 0}
    assert offset == 0
  end
end
