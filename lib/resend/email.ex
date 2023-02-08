defmodule Resend.Email do
  @behaviour Resend.Castable

  @type t() :: %__MODULE__{
          id: String.t(),
          from: String.t(),
          to: String.t()
        }

  defstruct [:id, :from, :to]

  @impl true
  def cast(map) do
    %__MODULE__{
      id: map["id"],
      from: map["from"],
      to: map["to"]
    }
  end

  @spec send(map()) :: Resend.Client.response(t())
  def send(opts) do
    Resend.Client.post("/email", __MODULE__, %{
      subject: opts[:subject],
      to: opts[:to],
      from: opts[:from],
      cc: opts[:cc],
      bcc: opts[:bcc],
      reply_to: opts[:reply_to],
      html: opts[:html],
      text: opts[:text]
    })
  end
end
