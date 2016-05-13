defmodule Chronic.PlainTimeTest do
  use ExUnit.Case, async: true
  use Chronic.TestHelpers

  test "11am" do
    { :ok, time, offset } = Chronic.parse("11am", currently: frozen_time)

    assert time == %Calendar.NaiveDateTime{year: 2015, month: 5, day: 9, hour: 11, min: 0, sec: 0, usec: 0}
    assert offset == 0
  end

  test "10 to 8" do
    { :ok, time, offset } = Chronic.parse("10 to 8", currently: frozen_time)

    assert time == %Calendar.NaiveDateTime{year: 2015, month: 5, day: 9, hour: 7, min: 50, sec: 0, usec: 0}
    assert offset == 0
  end

  test "10 to 8pm" do
    { :ok, time, offset } = Chronic.parse("10 to 8pm", currently: frozen_time)

    assert time == %Calendar.NaiveDateTime{year: 2015, month: 5, day: 9, hour: 19, min: 50, sec: 0, usec: 0}
    assert offset == 0
  end

  test "half past 2" do
    { :ok, time, offset } = Chronic.parse("half past 2", currently: frozen_time)

    assert time == %Calendar.NaiveDateTime{year: 2015, month: 5, day: 9, hour: 2, min: 30, sec: 0, usec: 0}
    assert offset == 0
  end
end
