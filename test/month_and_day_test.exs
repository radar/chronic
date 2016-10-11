defmodule Chronic.MonthAndDayTest do
  use ExUnit.Case, async: true
  use Chronic.TestHelpers

  @doctest Chronic

  test "month and day" do
    { :ok, time, offset } = Chronic.parse("aug 3")

    assert time == %NaiveDateTime{year: current_year, month: 8, day: 3, hour: 0, minute: 0, second: 0, microsecond: {0, 6}}
    assert offset == 0
  end

  test "capitalised month and day" do
    { :ok, time, offset } = Chronic.parse("AUG 3")

    assert time == %NaiveDateTime{year: current_year, month: 8, day: 3, hour: 0, minute: 0, second: 0, microsecond: {0, 6}}
    assert offset == 0
  end

  test "month and ordinalized day" do
    { :ok, time, offset } = Chronic.parse("aug 3rd")

    assert time == %NaiveDateTime{year: current_year, month: 8, day: 3, hour: 0, minute: 0, second: 0, microsecond: {0, 6}}
    assert offset == 0
  end

  test "month with dot and date (aug. 3)" do
    { :ok, time, offset } = Chronic.parse("aug. 3")
    assert time == %NaiveDateTime{year: current_year, month: 8, day: 3, hour: 0, minute: 0, second: 0, microsecond: {0, 6}}
    assert offset == 0
  end

  test "month and day with dash" do
    { :ok, time, offset } = Chronic.parse("aug-20")
    assert time == %NaiveDateTime{year: current_year, month: 8, day: 20, hour: 0, minute: 0, second: 0, microsecond: {0, 6}}
    assert offset == 0
  end

  test "month with day, and PM time" do
    { :ok, time, offset } = Chronic.parse("aug 3 5:26pm")
    assert time == %NaiveDateTime{year: current_year, day: 3, hour: 17, minute: 26, month: 8, second: 0, microsecond: {0, 6}}
    assert offset == 0
  end

  test "month with day, and AM time" do
    { :ok, time, offset } = Chronic.parse("aug 3 9:26am")
    assert time == %NaiveDateTime{year: current_year, month: 8, day: 3, hour: 9, minute: 26, second: 0, microsecond: {0, 6}}
    assert offset == 0
  end

  test "month with day, with 'at' AM time" do
    { :ok, time, offset } = Chronic.parse("aug 3 at 9:26am")
    assert time == %NaiveDateTime{year: current_year, month: 8, day: 3, hour: 9, minute: 26, second: 0, microsecond: {0, 6}}
    assert offset == 0
  end

  test "month with day, with 'at' AM time with seconds" do
    { :ok, time, offset } = Chronic.parse("aug 3 at 9:26:15am")
    assert time == %NaiveDateTime{year: current_year, day: 3, hour: 9, minute: 26, month: 8, second: 15, microsecond: {0, 6}}
    assert offset == 0
  end

  test "month with day, with 'at' AM time with seconds and microseconds" do
    { :ok, time, offset } = Chronic.parse("may 28 at 5:32:19.764")
    assert time == %NaiveDateTime{year: current_year, month: 5, day: 28, hour: 5, minute: 32, second: 19, microsecond: {764,6}}
    assert offset == 0
  end

  test "parsing with year when all numbers are less than or equal to 31" do
    { :ok, time, offset } = Chronic.parse("20-aug-16")
    assert time == %NaiveDateTime{year: 2016, month: 8, day: 20, hour: 0, minute: 0, second: 0, microsecond: {0, 6}}
    assert offset == 0

    { :ok, time, offset } = Chronic.parse("16-aug-20")
    assert time == %NaiveDateTime{year: 2020, month: 8, day: 16, hour: 0, minute: 0, second: 0, microsecond: {0, 6}}
    assert offset == 0
  end

  test "parsing with year when one number is greater than 31" do
    { :ok, time, offset } = Chronic.parse("2016-aug-20")
    assert time == %NaiveDateTime{year: 2016, month: 8, day: 20, hour: 0, minute: 0, second: 0, microsecond: {0, 6}}
    assert offset == 0

    { :ok, time, offset } = Chronic.parse("16-aug-2020")
    assert time == %NaiveDateTime{year: 2020, month: 8, day: 16, hour: 0, minute: 0, second: 0, microsecond: {0, 6}}
    assert offset == 0
  end

end
