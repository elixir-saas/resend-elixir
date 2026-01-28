defmodule Resend.Emails.BatchResponse do
  @moduledoc """
  Resend Batch Email Response struct.
  """

  @behaviour Resend.Castable

  @type email_id() :: %{id: String.t()}

  @type t() :: %__MODULE__{
          data: list(email_id())
        }

  defstruct [:data]

  @impl true
  def cast(map) do
    %__MODULE__{
      data: cast_email_ids(map["data"])
    }
  end

  defp cast_email_ids(nil), do: nil

  defp cast_email_ids(data) when is_list(data) do
    Enum.map(data, fn item ->
      %{id: item["id"]}
    end)
  end
end
