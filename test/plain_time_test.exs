defmodule Chronic.PlainTimeTest do
  use ExUnit.Case, async: true
  use Chronic.TestHelpers

  test "11am" do
    { :ok, time, offset } = Chronic.parse("11am", currently: frozen_time)

    assert time == %NaiveDateTime{year: 2015, month: 5, day: 9, hour: 11, minute: 0, second: 0, microsecond: {0, 6}}
    assert offset == 0
  end

  test "11 am" do
    { :ok, time, offset } = Chronic.parse("11 am", currently: frozen_time)

    assert time == %NaiveDateTime{year: 2015, month: 5, day: 9, hour: 11, minute: 0, second: 0, microsecond: {0, 6}}
    assert offset == 0
  end

  test "10 to 8" do
    { :ok, time, offset } = Chronic.parse("10 to 8", currently: frozen_time)

    assert time == %NaiveDateTime{year: 2015, month: 5, day: 9, hour: 7, minute: 50, second: 0, microsecond: {0, 6}}
    assert offset == 0
  end

  test "10 to 8pm" do
    { :ok, time, offset } = Chronic.parse("10 to 8pm", currently: frozen_time)

    assert time == %NaiveDateTime{year: 2015, month: 5, day: 9, hour: 19, minute: 50, second: 0, microsecond: {0, 6}}
    assert offset == 0
  end

  test "10 to 8 pm" do
    { :ok, time, offset } = Chronic.parse("10 to 8 pm", currently: frozen_time)

    assert time == %NaiveDateTime{year: 2015, month: 5, day: 9, hour: 19, minute: 50, second: 0, microsecond: {0, 6}}
    assert offset == 0
  end

  test "half past 2" do
    { :ok, time, offset } = Chronic.parse("half past 2", currently: frozen_time)

    assert time == %NaiveDateTime{year: 2015, month: 5, day: 9, hour: 2, minute: 30, second: 0, microsecond: {0, 6}}
    assert offset == 0
  end
end
