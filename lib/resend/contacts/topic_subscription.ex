defmodule Resend.Contacts.TopicSubscription do
  @moduledoc """
  Resend Topic Subscription struct for contact topic associations.
  """

  @behaviour Resend.Castable

  @type t() :: %__MODULE__{
          topic_id: String.t(),
          topic_name: String.t() | nil,
          subscribed: boolean() | nil
        }

  @enforce_keys [:topic_id]
  defstruct [
    :topic_id,
    :topic_name,
    :subscribed
  ]

  @impl true
  def cast(map) do
    %__MODULE__{
      topic_id: map["topic_id"] || map["id"],
      topic_name: map["topic_name"] || map["name"],
      subscribed: map["subscribed"]
    }
  end
end
