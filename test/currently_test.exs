defmodule Chronic.CurrentlyTest do
  use ExUnit.Case
  doctest Chronic

  test "currently option" do
    currently = {{2015, 5, 9}, {9, 0, 0}}
    { :ok, time, offset } = Chronic.parse("aug 3", currently: currently)
    assert time == %Calendar.NaiveDateTime{year: 2015, month: 8, day: 3, hour: 0, min: 0, sec: 0, usec: nil}
    assert offset == 0
  end

  test "tomorrow at 10am" do
    currently = {{2015, 5, 9}, {9, 0, 0}}
    { :ok, time, offset } = Chronic.parse("tomorrow at 10am", currently: currently)
    assert time == %Calendar.NaiveDateTime{year: 2015, month: 5, day: 10, hour: 10, min: 0, sec: 0, usec: 0}
    assert offset == 0
  end

  test "yesterday at 10am" do
    currently = {{2015, 5, 9}, {9, 0, 0}}
    { :ok, time, offset } = Chronic.parse("yesterday at 10am", currently: currently)
    assert time == %Calendar.NaiveDateTime{year: 2015, month: 5, day: 8, hour: 10, min: 0, sec: 0, usec: 0}
    assert offset == 0
  end

  test "tuesday" do
    currently = {{2015, 5, 9}, {9, 0, 0}}
    { :ok, time, offset } = Chronic.parse("tuesday", currently: currently)
    assert time == %Calendar.NaiveDateTime{year: 2015, month: 5, day: 12, hour: 12, min: 0, sec: 0, usec: 0}
    assert offset == 0
  end

  test "Tuesday" do
    currently = {{2015, 5, 9}, {9, 0, 0}}
    { :ok, time, offset } = Chronic.parse("Tuesday", currently: currently)
    assert time == %Calendar.NaiveDateTime{year: 2015, month: 5, day: 12, hour: 12, min: 0, sec: 0, usec: 0}
    assert offset == 0
  end
end
