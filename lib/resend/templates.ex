defmodule Resend.Templates do
  @moduledoc """
  Manage templates in Resend.
  """

  alias Resend.Templates.Template

  @doc """
  Creates a new template.

  ## Options

    * `:name` - The name of the template (required)
    * `:subject` - The email subject
    * `:from` - The sender email address
    * `:html` - The HTML content
    * `:text` - The plain text content

  """
  @spec create(Keyword.t()) :: Resend.Client.response(Template.t())
  @spec create(Resend.Client.t(), Keyword.t()) :: Resend.Client.response(Template.t())
  def create(client \\ Resend.client(), opts) do
    Resend.Client.post(client, Template, "/templates", %{
      name: opts[:name],
      subject: opts[:subject],
      from: opts[:from],
      html: opts[:html],
      text: opts[:text]
    })
  end

  @doc """
  Lists all templates.
  """
  @spec list() :: Resend.Client.response(Resend.List.t(Template.t()))
  @spec list(Resend.Client.t()) :: Resend.Client.response(Resend.List.t(Template.t()))
  def list(client \\ Resend.client()) do
    Resend.Client.get(client, Resend.List.of(Template), "/templates")
  end

  @doc """
  Gets a template by ID.
  """
  @spec get(String.t()) :: Resend.Client.response(Template.t())
  @spec get(Resend.Client.t(), String.t()) :: Resend.Client.response(Template.t())
  def get(client \\ Resend.client(), template_id) do
    Resend.Client.get(client, Template, "/templates/:id", opts: [path_params: [id: template_id]])
  end

  @doc """
  Updates a template.

  ## Options

    * `:name` - The name of the template
    * `:subject` - The email subject
    * `:from` - The sender email address
    * `:html` - The HTML content
    * `:text` - The plain text content

  """
  @spec update(String.t(), Keyword.t()) :: Resend.Client.response(Template.t())
  @spec update(Resend.Client.t(), String.t(), Keyword.t()) :: Resend.Client.response(Template.t())
  def update(client \\ Resend.client(), template_id, opts) do
    Resend.Client.patch(
      client,
      Template,
      "/templates/:id",
      %{
        name: opts[:name],
        subject: opts[:subject],
        from: opts[:from],
        html: opts[:html],
        text: opts[:text]
      },
      opts: [path_params: [id: template_id]]
    )
  end

  @doc """
  Removes a template.
  """
  @spec remove(String.t()) :: Resend.Client.response(Resend.Empty.t())
  @spec remove(Resend.Client.t(), String.t()) :: Resend.Client.response(Resend.Empty.t())
  def remove(client \\ Resend.client(), template_id) do
    Resend.Client.delete(client, Resend.Empty, "/templates/:id", %{},
      opts: [path_params: [id: template_id]]
    )
  end

  @doc """
  Duplicates a template.
  """
  @spec duplicate(String.t()) :: Resend.Client.response(Template.t())
  @spec duplicate(Resend.Client.t(), String.t()) :: Resend.Client.response(Template.t())
  def duplicate(client \\ Resend.client(), template_id) do
    Resend.Client.post(client, Template, "/templates/:id/duplicate", %{},
      opts: [path_params: [id: template_id]]
    )
  end

  @doc """
  Publishes a template.
  """
  @spec publish(String.t()) :: Resend.Client.response(Template.t())
  @spec publish(Resend.Client.t(), String.t()) :: Resend.Client.response(Template.t())
  def publish(client \\ Resend.client(), template_id) do
    Resend.Client.post(client, Template, "/templates/:id/publish", %{},
      opts: [path_params: [id: template_id]]
    )
  end
end
