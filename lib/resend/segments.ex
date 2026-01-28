defmodule Resend.Segments do
  @moduledoc """
  Manage segments in Resend.
  """

  alias Resend.Segments.Segment

  @doc """
  Creates a new segment.

  ## Options

    * `:name` - The name of the segment (required)
    * `:audience_id` - The audience ID (required)

  """
  @spec create(Keyword.t()) :: Resend.Client.response(Segment.t())
  @spec create(Resend.Client.t(), Keyword.t()) :: Resend.Client.response(Segment.t())
  def create(client \\ Resend.client(), opts) do
    Resend.Client.post(
      client,
      Segment,
      "/segments",
      %{
        name: opts[:name],
        audience_id: opts[:audience_id]
      }
    )
  end

  @doc """
  Lists all segments.

  ## Options

    * `:audience_id` - Filter segments by audience ID

  """
  @spec list() :: Resend.Client.response(Resend.List.t(Segment.t()))
  @spec list(Keyword.t()) :: Resend.Client.response(Resend.List.t(Segment.t()))
  @spec list(Resend.Client.t(), Keyword.t()) :: Resend.Client.response(Resend.List.t(Segment.t()))
  def list(client_or_opts \\ [])

  def list(%Resend.Client{} = client), do: do_list(client, [])
  def list(opts) when is_list(opts), do: do_list(Resend.client(), opts)

  def list(%Resend.Client{} = client, opts) when is_list(opts), do: do_list(client, opts)

  defp do_list(client, opts) do
    query = if opts[:audience_id], do: [audience_id: opts[:audience_id]], else: []
    Resend.Client.get(client, Resend.List.of(Segment), "/segments", query: query)
  end

  @doc """
  Gets a segment by ID.
  """
  @spec get(String.t()) :: Resend.Client.response(Segment.t())
  @spec get(Resend.Client.t(), String.t()) :: Resend.Client.response(Segment.t())
  def get(client \\ Resend.client(), segment_id) do
    Resend.Client.get(client, Segment, "/segments/:id", opts: [path_params: [id: segment_id]])
  end

  @doc """
  Removes a segment.
  """
  @spec remove(String.t()) :: Resend.Client.response(Resend.Empty.t())
  @spec remove(Resend.Client.t(), String.t()) ::
          Resend.Client.response(Resend.Empty.t())
  def remove(client \\ Resend.client(), segment_id) do
    Resend.Client.delete(client, Resend.Empty, "/segments/:id", %{},
      opts: [path_params: [id: segment_id]]
    )
  end
end
