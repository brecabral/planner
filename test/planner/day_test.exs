defmodule Planner.DayTest do
  use ExUnit.Case, async: true

  alias Planner.Day

  test "the default day is the current UTC date" do
    before = Date.utc_today()
    day = Day.current()
    after_date = Date.utc_today()

    assert %Date{} = day
    assert day in [before, after_date]
  end

  test "a caller can advance the planning day without waiting for midnight" do
    assert Day.current(~D[2026-09-24]) == ~D[2026-09-24]
    assert Day.current(~D[2026-09-25]) == ~D[2026-09-25]
  end

  test "independent callers do not share their controlled date" do
    first = Task.async(fn -> Day.current(~D[2020-01-01]) end)
    second = Task.async(fn -> Day.current(~D[2030-12-31]) end)

    assert Task.await(first) == ~D[2020-01-01]
    assert Task.await(second) == ~D[2030-12-31]
    assert Day.current(~D[2020-01-01]) == ~D[2020-01-01]

    before = Date.utc_today()
    day = Day.current()
    assert day in [before, Date.utc_today()]
  end
end
