defmodule Resend.Emails.Attachment do
  @moduledoc """
  Resend Email Attachment struct.
  """
  @behaviour Resend.Castable
  @derive Jason.Encoder

  @type t() :: %__MODULE__{
          content: String.t() | nil,
          content_type: String.t() | nil,
          filename: String.t() | nil,
          content_id: String.t() | nil,
          path: String.t()
        }

  defstruct [
    :content,
    :content_type,
    :filename,
    :content_id,
    path: ""
  ]

  @impl true
  def cast(map) do
    %__MODULE__{
      content: map["content"],
      content_type: map["content_type"],
      filename: map["filename"],
      content_id: map["content_id"],
      path: map["path"]
    }
  end
end
