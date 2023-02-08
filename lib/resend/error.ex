defmodule Resend.Error do
  @moduledoc """
  Castable module for returning structured errors from the Resend API.
  """

  @behaviour Resend.Castable

  @type t() :: %__MODULE__{
          code: integer(),
          type: String.t(),
          message: String.t()
        }

  defstruct [
    :code,
    :type,
    :message
  ]

  @impl true
  def cast(%{"error" => error}) do
    %__MODULE__{
      code: error["code"],
      type: error["type"],
      message: error["message"]
    }
  end
end
