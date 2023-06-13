defmodule Resend.Error do
  @moduledoc """
  Castable module for returning structured errors from the Resend API.
  """

  @behaviour Resend.Castable

  @type t() :: %__MODULE__{
          name: String.t(),
          message: String.t(),
          status_code: integer()
        }

  defstruct [
    :name,
    :message,
    :status_code
  ]

  @impl true
  def cast(error) when is_map(error) do
    %__MODULE__{
      name: error["name"],
      message: error["message"],
      status_code: error["statusCode"]
    }
  end
end
