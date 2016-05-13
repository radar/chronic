defmodule Chronic.ISO8601Test do
  use ExUnit.Case, async: true
  use Chronic.TestHelpers

  test "iso8601 time" do
    { :ok, time, offset } = Chronic.parse("2012-08-02T13:00:00")
    assert time == %Calendar.NaiveDateTime{year: 2012, month: 8, day: 2, hour: 13, min: 0, sec: 0, usec: nil}
    assert offset == nil
  end

  test "iso8601 time with offset" do
    { :ok, time, offset } = Chronic.parse("2012-08-02T13:00:00+01:00")
    assert time == %Calendar.NaiveDateTime{year: 2012, month: 8, day: 2, hour: 13, min: 0, sec: 0, usec: nil}
    assert offset == 3600
  end

  test "iso8601 time with offset and ms" do
    { :ok, time, offset } = Chronic.parse("2013-08-01T19:30:00.345-07:00")
    assert time == %Calendar.NaiveDateTime{year: 2013, month: 8, day: 1, hour: 19, min: 30, sec: 0, usec: 345000}
    assert offset == -25200
  end

  test "iso8601 with UTC zone" do
    { :ok, time, offset } = Chronic.parse("2012-08-02T12:00:00Z")
    assert time == %Calendar.NaiveDateTime{year: 2012, month: 8, day: 2, hour: 12, min: 0, sec: 0, usec: nil}
    assert offset == 0
  end

  test "iso8601 with ms" do
    { :ok, time, offset } = Chronic.parse("2012-01-03 01:00:00.234567")
    assert time == %Calendar.NaiveDateTime{year: 2012, month: 1, day: 3, hour: 1, min: 0, sec: 0, usec: 234567}
    assert offset == nil
  end
end
