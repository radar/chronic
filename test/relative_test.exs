defmodule Chronic.RelativeTest do
  use ExUnit.Case, async: true
  use Chronic.TestHelpers

  test "tomorrow at 10am" do
    {:ok, time, offset} = Chronic.parse("tomorrow at 10am", currently: frozen_time())
    assert time == %NaiveDateTime{year: 2015, month: 5, day: 10, hour: 10, minute: 0, second: 0, microsecond: {0, 6}}
    assert offset == 0
  end

  test "yesterday at 10am" do
    {:ok, time, offset} = Chronic.parse("yesterday at 10am", currently: frozen_time())
    assert time == %NaiveDateTime{year: 2015, month: 5, day: 8, hour: 10, minute: 0, second: 0, microsecond: {0, 6}}
    assert offset == 0
  end

  test "today 10am" do
    {:ok, time, offset} = Chronic.parse("today 10am", currently: frozen_time())
    assert time == %NaiveDateTime{year: 2015, month: 5, day: 9, hour: 10, minute: 0, second: 0, microsecond: {0, 6}}
    assert offset == 0
  end

  test "today at 10am" do
    {:ok, time, offset} = Chronic.parse("today at 10am", currently: frozen_time())
    assert time == %NaiveDateTime{year: 2015, month: 5, day: 9, hour: 10, minute: 0, second: 0, microsecond: {0, 6}}
    assert offset == 0
  end

  test "tuesday" do
    {:ok, time, offset} = Chronic.parse("tuesday", currently: frozen_time())
    assert time == %NaiveDateTime{year: 2015, month: 5, day: 12, hour: 12, minute: 0, second: 0, microsecond: {0, 6}}
    assert offset == 0
  end

  test "Tuesday" do
    {:ok, time, offset} = Chronic.parse("Tuesday", currently: frozen_time())
    assert time == %NaiveDateTime{year: 2015, month: 5, day: 12, hour: 12, minute: 0, second: 0, microsecond: {0, 6}}
    assert offset == 0
  end

  test "tue" do
    {:ok, time, offset} = Chronic.parse("tue", currently: frozen_time())
    assert time == %NaiveDateTime{year: 2015, month: 5, day: 12, hour: 12, minute: 0, second: 0, microsecond: {0, 6}}
    assert offset == 0
  end

  test "Tuesday 9am" do
    {:ok, time, offset} = Chronic.parse("Tuesday 9am", currently: frozen_time())
    assert time == %NaiveDateTime{year: 2015, month: 5, day: 12, hour: 9, minute: 0, second: 0, microsecond: {0, 6}}
    assert offset == 0
  end

  test "Tuesday 4pm - at 9am same day" do
    {:ok, time, offset} = Chronic.parse("Tuesday 4pm", currently: {{2018, 9, 25}, {9, 0, 0}})
    assert time == %NaiveDateTime{year: 2018, month: 9, day: 25, hour: 16, minute: 0, second: 0, microsecond: {0, 6}}
    assert offset == 0
  end

  test "Tuesday 4pm - at 4pm same day" do
    {:ok, time, offset} = Chronic.parse("Tuesday 4pm", currently: {{2018, 9, 25}, {16, 0, 0}})
    assert time == %NaiveDateTime{year: 2018, month: 10, day: 2, hour: 16, minute: 0, second: 0, microsecond: {0, 6}}
    assert offset == 0
  end

  test "Tuesday at 9am" do
    {:ok, time, offset} = Chronic.parse("Tuesday at 9am", currently: frozen_time())
    assert time == %NaiveDateTime{year: 2015, month: 5, day: 12, hour: 9, minute: 0, second: 0, microsecond: {0, 6}}
    assert offset == 0
  end

  test "6 in the morning" do
    {:ok, time, offset} = Chronic.parse("6 in the morning", currently: frozen_time())
    assert time == %NaiveDateTime{year: 2015, month: 5, day: 9, hour: 6, minute: 0, second: 0, microsecond: {0, 6}}
    assert offset == 0
  end

  test "6 in the evening" do
    {:ok, time, offset} = Chronic.parse("6 in the evening", currently: frozen_time())
    assert time == %NaiveDateTime{year: 2015, month: 5, day: 9, hour: 18, minute: 0, second: 0, microsecond: {0, 6}}
    assert offset == 0
  end

  test "sat 7 in the evening" do
    {:ok, time, offset} = Chronic.parse("sat 7 in the evening", currently: frozen_time())
    assert time == %NaiveDateTime{year: 2015, month: 5, day: 16, hour: 19, minute: 0, second: 0, microsecond: {0, 6}}
    assert offset == 0
  end
end
