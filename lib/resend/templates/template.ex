defmodule Resend.Templates.Template do
  @moduledoc """
  Resend Template struct.
  """

  alias Resend.Util

  @behaviour Resend.Castable

  @type t() :: %__MODULE__{
          id: String.t(),
          name: String.t() | nil,
          subject: String.t() | nil,
          from: String.t() | nil,
          html: String.t() | nil,
          text: String.t() | nil,
          created_at: DateTime.t() | nil,
          updated_at: DateTime.t() | nil
        }

  @enforce_keys [:id]
  defstruct [
    :id,
    :name,
    :subject,
    :from,
    :html,
    :text,
    :created_at,
    :updated_at
  ]

  @impl true
  def cast(map) do
    %__MODULE__{
      id: map["id"],
      name: map["name"],
      subject: map["subject"],
      from: map["from"],
      html: map["html"],
      text: map["text"],
      created_at: Util.parse_iso8601(map["created_at"]),
      updated_at: Util.parse_iso8601(map["updated_at"])
    }
  end
end
