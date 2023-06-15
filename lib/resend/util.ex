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
end
