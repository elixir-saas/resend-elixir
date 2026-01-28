defmodule Resend.IntegrationTest do
  @moduledoc """
  Full integration test that exercises every API endpoint.

  Only runs when RESEND_KEY environment variable is set.
  Run with: RESEND_KEY=re_xxx mix test test/resend/integration_test.exs

  CAUTION: This test creates and deletes real resources in your Resend account.
  """
  use ExUnit.Case, async: false

  # Only run these tests when we have a real API key
  @moduletag :integration

  # Test email addresses - use your verified domain
  @test_from "onboarding@resend.dev"
  @test_to "delivered@resend.dev"

  setup_all do
    api_key = System.get_env("RESEND_KEY")

    unless api_key do
      raise """
      Integration tests require RESEND_KEY environment variable.
      Run with: RESEND_KEY=re_xxx mix test test/resend/integration_test.exs --include integration
      """
    end

    # Create a client that bypasses the mock plug and uses the real API
    client = Resend.Client.new(api_key: api_key, req_options: [])

    {:ok, client: client}
  end

  describe "API Keys" do
    test "create, list, and remove API key", %{client: client} do
      name = "integration-test-#{System.unique_integer([:positive])}"

      # Create - only returns id and token
      {:ok, api_key} =
        Resend.ApiKeys.create(client,
          name: name,
          permission: "sending_access"
        )

      assert api_key.id
      assert api_key.token

      # List - returns full objects including name
      {:ok, %Resend.List{data: api_keys}} = Resend.ApiKeys.list(client)
      assert is_list(api_keys)
      listed_key = Enum.find(api_keys, &(&1.id == api_key.id))
      assert listed_key
      assert listed_key.name == name

      # Remove
      {:ok, %Resend.Empty{}} = Resend.ApiKeys.remove(client, api_key.id)

      # Verify removal
      {:ok, %Resend.List{data: api_keys_after}} = Resend.ApiKeys.list(client)
      refute Enum.any?(api_keys_after, &(&1.id == api_key.id))
    end
  end

  describe "Domains" do
    test "list and get domains", %{client: client} do
      # List domains (should have at least one if account is set up)
      {:ok, %Resend.List{data: domains}} = Resend.Domains.list(client)
      assert is_list(domains)

      # If we have domains, test get
      if length(domains) > 0 do
        domain = hd(domains)
        {:ok, fetched_domain} = Resend.Domains.get(client, domain.id)
        assert fetched_domain.id == domain.id
        assert fetched_domain.name == domain.name
      end
    end

    # Note: We skip create/remove for domains as they require DNS setup
    # and removing a domain could break production email sending
  end

  describe "Contact Properties" do
    test "create, list, get, update, and remove contact property", %{client: client} do
      key = "test_prop_#{System.unique_integer([:positive])}"

      # Create - only returns id
      {:ok, property} =
        Resend.ContactProperties.create(client,
          key: key,
          type: "string",
          fallback_value: "default"
        )

      assert property.id

      # List
      {:ok, %Resend.List{data: properties}} = Resend.ContactProperties.list(client)
      assert is_list(properties)
      assert Enum.any?(properties, &(&1.id == property.id))

      # Get - returns full object
      {:ok, fetched} = Resend.ContactProperties.get(client, property.id)
      assert fetched.id == property.id
      assert fetched.key == key

      # Update
      {:ok, updated} =
        Resend.ContactProperties.update(client, property.id, fallback_value: "updated")

      assert updated.id == property.id

      # Remove
      {:ok, %Resend.Empty{}} = Resend.ContactProperties.remove(client, property.id)
    end
  end

  describe "Segments" do
    test "create, list, get, and remove segment", %{client: client} do
      name = "Integration Test Segment #{System.unique_integer([:positive])}"

      # Create
      {:ok, segment} = Resend.Segments.create(client, name: name)
      assert segment.id
      assert segment.name == name

      # List
      {:ok, %Resend.List{data: segments}} = Resend.Segments.list(client)
      assert is_list(segments)
      assert Enum.any?(segments, &(&1.id == segment.id))

      # List with pagination
      {:ok, %Resend.List{data: _paginated}} = Resend.Segments.list(client, limit: 5)

      # Get
      {:ok, fetched} = Resend.Segments.get(client, segment.id)
      assert fetched.id == segment.id
      assert fetched.name == name

      # Remove
      {:ok, %Resend.Empty{}} = Resend.Segments.remove(client, segment.id)
    end
  end

  describe "Topics" do
    test "create, list, get, update, and remove topic", %{client: client} do
      name = "Test Topic #{System.unique_integer([:positive])}"

      # Create - only returns id
      {:ok, topic} =
        Resend.Topics.create(client,
          name: name,
          default_subscription: "opt_in",
          description: "Integration test topic",
          visibility: "private"
        )

      assert topic.id

      # List
      {:ok, %Resend.List{data: topics}} = Resend.Topics.list(client)
      assert is_list(topics)
      assert Enum.any?(topics, &(&1.id == topic.id))

      # List with pagination
      {:ok, %Resend.List{data: _paginated}} = Resend.Topics.list(client, limit: 5)

      # Get - returns full object
      {:ok, fetched} = Resend.Topics.get(client, topic.id)
      assert fetched.id == topic.id
      assert fetched.name == name
      assert fetched.default_subscription == "opt_in"

      # Update
      {:ok, updated} =
        Resend.Topics.update(client, topic.id,
          name: "#{name} Updated",
          description: "Updated description"
        )

      assert updated.id == topic.id

      # Remove
      {:ok, %Resend.Empty{}} = Resend.Topics.remove(client, topic.id)
    end
  end

  describe "Audiences (legacy)" do
    test "create, list, get, and remove audience", %{client: client} do
      name = "Integration Test Audience #{System.unique_integer([:positive])}"

      # Create
      {:ok, audience} = Resend.Audiences.create(client, name: name)
      assert audience.id
      assert audience.name == name

      # List
      {:ok, %Resend.List{data: audiences}} = Resend.Audiences.list(client)
      assert is_list(audiences)
      assert Enum.any?(audiences, &(&1.id == audience.id))

      # Get
      {:ok, fetched} = Resend.Audiences.get(client, audience.id)
      assert fetched.id == audience.id

      # Remove
      {:ok, %Resend.Empty{}} = Resend.Audiences.remove(client, audience.id)
    end
  end

  describe "Contacts with Segments and Topics" do
    test "full contact lifecycle with segments and topics", %{client: client} do
      # First create a segment and topic to use
      segment_name = "Contact Test Segment #{System.unique_integer([:positive])}"
      {:ok, segment} = Resend.Segments.create(client, name: segment_name)

      topic_name = "Contact Test Topic #{System.unique_integer([:positive])}"

      {:ok, topic} =
        Resend.Topics.create(client,
          name: topic_name,
          default_subscription: "opt_in"
        )

      email = "test-#{System.unique_integer([:positive])}@example.com"

      # Create contact - only returns id
      {:ok, contact} =
        Resend.Contacts.create(client,
          email: email,
          first_name: "Integration",
          last_name: "Test"
        )

      assert contact.id

      # List contacts
      {:ok, %Resend.List{data: contacts}} = Resend.Contacts.list(client)
      assert is_list(contacts)
      assert Enum.any?(contacts, &(&1.id == contact.id))

      # Get contact by ID
      {:ok, fetched} = Resend.Contacts.get(client, contact.id)
      assert fetched.id == contact.id

      # Get contact by email
      {:ok, fetched_by_email} = Resend.Contacts.get(client, email)
      assert fetched_by_email.id == contact.id

      # Update contact - only returns id
      {:ok, updated} =
        Resend.Contacts.update(client, contact.id,
          first_name: "Updated",
          last_name: "Name"
        )

      assert updated.id == contact.id

      # Verify update via GET
      {:ok, updated_contact} = Resend.Contacts.get(client, contact.id)
      assert updated_contact.first_name == "Updated"

      # Add to segment
      {:ok, %Resend.Empty{}} = Resend.Contacts.add_to_segment(client, contact.id, segment.id)

      # List contact's segments
      {:ok, %Resend.List{data: contact_segments}} =
        Resend.Contacts.list_segments(client, contact.id)

      assert Enum.any?(contact_segments, &(&1.id == segment.id))

      # List contact's topics
      {:ok, %Resend.List{data: _contact_topics}} =
        Resend.Contacts.list_topics(client, contact.id)

      # Update topic subscription
      {:ok, %Resend.List{}} =
        Resend.Contacts.update_topics(client, contact.id, [
          %{id: topic.id, subscription: "opt_in"}
        ])

      # Remove from segment
      {:ok, %Resend.Empty{}} =
        Resend.Contacts.remove_from_segment(client, contact.id, segment.id)

      # Cleanup
      {:ok, %Resend.Empty{}} = Resend.Contacts.remove(client, contact.id)
      {:ok, %Resend.Empty{}} = Resend.Segments.remove(client, segment.id)
      {:ok, %Resend.Empty{}} = Resend.Topics.remove(client, topic.id)
    end
  end

  describe "Webhooks" do
    test "create, list, get, update, and remove webhook", %{client: client} do
      endpoint = "https://example.com/webhook/#{System.unique_integer([:positive])}"

      # Create - only returns id and signing_secret
      {:ok, webhook} =
        Resend.Webhooks.create(client,
          endpoint: endpoint,
          events: ["email.sent", "email.delivered"]
        )

      assert webhook.id
      assert webhook.signing_secret

      # List
      {:ok, %Resend.List{data: webhooks}} = Resend.Webhooks.list(client)
      assert is_list(webhooks)
      assert Enum.any?(webhooks, &(&1.id == webhook.id))

      # Get - returns full object
      {:ok, fetched} = Resend.Webhooks.get(client, webhook.id)
      assert fetched.id == webhook.id
      assert fetched.endpoint == endpoint
      assert fetched.events == ["email.sent", "email.delivered"]

      # Update
      {:ok, updated} =
        Resend.Webhooks.update(client, webhook.id,
          events: ["email.sent", "email.delivered", "email.bounced"]
        )

      assert updated.id == webhook.id

      # Remove
      {:ok, %Resend.Empty{}} = Resend.Webhooks.remove(client, webhook.id)
    end
  end

  describe "Broadcasts" do
    test "create, list, get, update, and remove broadcast", %{client: client} do
      # First create a segment for the broadcast
      segment_name = "Broadcast Test Segment #{System.unique_integer([:positive])}"
      {:ok, segment} = Resend.Segments.create(client, name: segment_name)

      # Create broadcast (draft) - only returns id
      {:ok, broadcast} =
        Resend.Broadcasts.create(client,
          segment_id: segment.id,
          from: @test_from,
          subject: "Integration Test Broadcast",
          html: "<p>Test broadcast content</p>",
          name: "Test Broadcast #{System.unique_integer([:positive])}"
        )

      assert broadcast.id

      # List
      {:ok, %Resend.List{data: broadcasts}} = Resend.Broadcasts.list(client)
      assert is_list(broadcasts)
      assert Enum.any?(broadcasts, &(&1.id == broadcast.id))

      # Get - returns full object
      {:ok, fetched} = Resend.Broadcasts.get(client, broadcast.id)
      assert fetched.id == broadcast.id
      assert fetched.status == "draft"

      # Update
      {:ok, updated} =
        Resend.Broadcasts.update(client, broadcast.id, subject: "Updated Subject")

      assert updated.id == broadcast.id

      # Note: We don't call send() to avoid actually sending emails

      # Remove (only works for drafts)
      {:ok, %Resend.Empty{}} = Resend.Broadcasts.remove(client, broadcast.id)

      # Cleanup segment
      {:ok, %Resend.Empty{}} = Resend.Segments.remove(client, segment.id)
    end
  end

  describe "Emails" do
    test "send, get, and list emails", %{client: client} do
      # Send a test email
      {:ok, email} =
        Resend.Emails.send(client, %{
          from: @test_from,
          to: @test_to,
          subject: "Integration Test #{System.unique_integer([:positive])}",
          html: "<p>This is an integration test email.</p>",
          text: "This is an integration test email.",
          tags: [%{name: "test", value: "integration"}]
        })

      assert email.id

      # Brief pause to let the email be processed
      Process.sleep(1000)

      # Get the email
      {:ok, fetched} = Resend.Emails.get(client, email.id)
      assert fetched.id == email.id

      # List emails
      {:ok, %Resend.List{data: emails}} = Resend.Emails.list(client)
      assert is_list(emails)
    end

    test "send batch emails", %{client: client} do
      emails = [
        %{
          from: @test_from,
          to: @test_to,
          subject: "Batch Test 1 - #{System.unique_integer([:positive])}",
          html: "<p>Batch email 1</p>"
        },
        %{
          from: @test_from,
          to: @test_to,
          subject: "Batch Test 2 - #{System.unique_integer([:positive])}",
          html: "<p>Batch email 2</p>"
        }
      ]

      {:ok, %Resend.Emails.BatchResponse{data: results}} =
        Resend.Emails.send_batch(client, emails)

      assert length(results) == 2
      assert Enum.all?(results, & &1.id)
    end

    test "schedule and cancel email", %{client: client} do
      # Schedule an email for 1 hour from now
      scheduled_at =
        DateTime.utc_now()
        |> DateTime.add(3600, :second)
        |> DateTime.to_iso8601()

      {:ok, email} =
        Resend.Emails.send(client, %{
          from: @test_from,
          to: @test_to,
          subject: "Scheduled Test #{System.unique_integer([:positive])}",
          html: "<p>This is a scheduled test email.</p>",
          scheduled_at: scheduled_at
        })

      assert email.id

      # Brief pause
      Process.sleep(500)

      # Cancel the scheduled email
      {:ok, cancelled} = Resend.Emails.cancel(client, email.id)
      assert cancelled.id == email.id
    end
  end
end
