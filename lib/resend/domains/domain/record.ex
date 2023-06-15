defmodule Resend.Domains.Domain.Record do
  @moduledoc """
  Resend Domain Record struct.
  """

  @behaviour Resend.Castable

  @type t() :: %__MODULE__{
          name: String.t(),
          record: String.t(),
          status: list(String.t()),
          ttl: list(String.t()),
          type: list(String.t()),
          value: list(String.t())
        }

  @enforce_keys [:name, :record, :status, :ttl, :type, :value]
  defstruct [
    :name,
    :record,
    :status,
    :ttl,
    :type,
    :value
  ]

  @impl true
  def cast(map) do
    %__MODULE__{
      name: map["name"],
      record: map["record"],
      status: map["status"],
      ttl: map["ttl"],
      type: map["type"],
      value: map["value"]
    }
  end
end
