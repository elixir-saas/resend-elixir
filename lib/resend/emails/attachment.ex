defmodule Resend.Emails.Attachment do
  @moduledoc """
  Resend Email Attachment struct.
  """
  @behaviour Resend.Castable
  @derive Jason.Encoder

  @type t() :: map()

  defstruct [
    :content,
    :content_type,
    :filename,
    path: ""
  ]

  @impl true
  def cast(map) do
    %__MODULE__{
      content: map["content"],
      content_type: map["content_type"],
      filename: map["filename"],
      path: map["path"]
    }
  end
end
