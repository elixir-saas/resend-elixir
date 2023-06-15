defmodule Resend.Domains.Domain do
  @moduledoc """
  Resend Domain struct.
  """

  alias Resend.Util
  alias Resend.Castable
  alias Resend.Domains.Domain.Record

  @behaviour Resend.Castable

  @type t() :: %__MODULE__{
          id: String.t(),
          name: String.t() | nil,
          status: list(String.t()) | nil,
          region: list(String.t()) | nil,
          records: list(Record.t()) | nil,
          created_at: DateTime.t() | nil,
          deleted: boolean() | nil
        }

  @enforce_keys [:id]
  defstruct [
    :id,
    :name,
    :status,
    :region,
    :records,
    :created_at,
    :deleted
  ]

  @impl true
  def cast(map) do
    %__MODULE__{
      id: map["id"],
      name: map["name"],
      status: map["status"],
      region: map["region"],
      records: Castable.cast_list(Record, map["records"]),
      created_at: Util.parse_iso8601(map["created_at"]),
      deleted: map["deleted"]
    }
  end
end
