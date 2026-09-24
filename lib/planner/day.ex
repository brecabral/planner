defmodule Planner.Day do
  @moduledoc """
  Supplies the server-side planning date without shared clock state.
  """

  @doc """
  Returns today's UTC date, or a date explicitly controlled by the caller.

  Contexts must capture this value once per query or command and reuse it
  throughout that operation. The optional date supports deterministic tests;
  browser parameters must never supply the authoritative planning date.
  """
  @spec current(Date.t()) :: Date.t()
  def current(%Date{} = date \\ Date.utc_today()), do: date
end
