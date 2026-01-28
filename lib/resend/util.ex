defmodule Resend.Util do
  @moduledoc """
  Module for utility functions.
  """

  @doc """
  Parses a iso8601 data string to a `DateTime`. Returns nil if argument is nil.
  """
  @spec parse_iso8601(String.t() | nil) :: DateTime.t() | nil
  def parse_iso8601(nil), do: nil

  def parse_iso8601(date_string) do
    {:ok, date_time, 0} = DateTime.from_iso8601(date_string)
    date_time
  end

  @doc """
  Removes nil values from a map. Used to avoid sending null values to the API.
  """
  @spec compact(map()) :: map()
  def compact(map) when is_map(map) do
    map
    |> Enum.reject(fn {_k, v} -> is_nil(v) end)
    |> Map.new()
  end
end
