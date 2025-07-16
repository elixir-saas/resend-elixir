defmodule Resend.Broadcasts.BroadcastTest do
  use Resend.TestCase, async: true

  alias Resend.Broadcasts.Broadcast

  describe "cast/1" do
    test "casts a valid broadcast map to struct" do
      map = %{
        "id" => "b6d24b8e-af0b-4c3c-be0c-359bbd97381e",
        "audience_id" => "78261eea-8f8b-4381-83c6-79fa7120f1cf",
        "name" => "Monthly Newsletter",
        "from" => "news@example.com",
        "subject" => "Your Monthly Update",
        "reply_to" => "support@example.com",
        "preview_text" => "Check out what's new this month",
        "status" => "draft",
        "created_at" => "2023-10-06T22:59:55.977Z",
        "scheduled_at" => "2023-10-10T09:00:00.000Z",
        "sent_at" => "2023-10-10T09:01:15.123Z",
        "deleted" => false
      }

      broadcast = Broadcast.cast(map)

      assert broadcast.id == "b6d24b8e-af0b-4c3c-be0c-359bbd97381e"
      assert broadcast.audience_id == "78261eea-8f8b-4381-83c6-79fa7120f1cf"
      assert broadcast.name == "Monthly Newsletter"
      assert broadcast.from == "news@example.com"
      assert broadcast.subject == "Your Monthly Update"
      assert broadcast.reply_to == "support@example.com"
      assert broadcast.preview_text == "Check out what's new this month"
      assert broadcast.status == "draft"
      assert broadcast.created_at == ~U[2023-10-06 22:59:55.977Z]
      assert broadcast.scheduled_at == ~U[2023-10-10 09:00:00.000Z]
      assert broadcast.sent_at == ~U[2023-10-10 09:01:15.123Z]
      assert broadcast.deleted == false
    end

    test "handles reply_to as string" do
      map = %{
        "id" => "b6d24b8e-af0b-4c3c-be0c-359bbd97381e",
        "reply_to" => "single@example.com"
      }

      broadcast = Broadcast.cast(map)

      assert broadcast.reply_to == "single@example.com"
    end

    test "handles reply_to as list of strings" do
      map = %{
        "id" => "b6d24b8e-af0b-4c3c-be0c-359bbd97381e",
        "reply_to" => ["support@example.com", "help@example.com", "info@example.com"]
      }

      broadcast = Broadcast.cast(map)

      assert broadcast.reply_to == ["support@example.com", "help@example.com", "info@example.com"]
    end

    test "handles minimal broadcast map" do
      map = %{
        "id" => "b6d24b8e-af0b-4c3c-be0c-359bbd97381e"
      }

      broadcast = Broadcast.cast(map)

      assert broadcast.id == "b6d24b8e-af0b-4c3c-be0c-359bbd97381e"
      assert is_nil(broadcast.audience_id)
      assert is_nil(broadcast.name)
      assert is_nil(broadcast.from)
      assert is_nil(broadcast.subject)
      assert is_nil(broadcast.reply_to)
      assert is_nil(broadcast.preview_text)
      assert is_nil(broadcast.status)
      assert is_nil(broadcast.created_at)
      assert is_nil(broadcast.scheduled_at)
      assert is_nil(broadcast.sent_at)
      assert is_nil(broadcast.deleted)
    end

    test "handles nil datetime fields" do
      map = %{
        "id" => "b6d24b8e-af0b-4c3c-be0c-359bbd97381e",
        "created_at" => nil,
        "scheduled_at" => nil,
        "sent_at" => nil
      }

      broadcast = Broadcast.cast(map)

      assert is_nil(broadcast.created_at)
      assert is_nil(broadcast.scheduled_at)
      assert is_nil(broadcast.sent_at)
    end

    test "handles deleted flag" do
      map = %{
        "id" => "b6d24b8e-af0b-4c3c-be0c-359bbd97381e",
        "deleted" => true
      }

      broadcast = Broadcast.cast(map)

      assert broadcast.deleted == true
    end

    test "handles broadcast with various statuses" do
      statuses = ["draft", "scheduled", "sending", "sent", "cancelled"]

      for status <- statuses do
        map = %{
          "id" => "b6d24b8e-af0b-4c3c-be0c-359bbd97381e",
          "status" => status
        }

        broadcast = Broadcast.cast(map)

        assert broadcast.status == status
      end
    end

    test "handles empty strings for optional fields" do
      map = %{
        "id" => "b6d24b8e-af0b-4c3c-be0c-359bbd97381e",
        "preview_text" => "",
        "reply_to" => ""
      }

      broadcast = Broadcast.cast(map)

      assert broadcast.preview_text == ""
      assert broadcast.reply_to == ""
    end

    test "handles valid datetime formats" do
      map = %{
        "id" => "b6d24b8e-af0b-4c3c-be0c-359bbd97381e",
        "created_at" => "2023-10-06T22:59:55.977Z",
        "scheduled_at" => "2023-12-25T09:00:00.000Z",
        "sent_at" => "2023-12-25T09:01:15.123Z"
      }

      broadcast = Broadcast.cast(map)

      assert broadcast.created_at == ~U[2023-10-06 22:59:55.977Z]
      assert broadcast.scheduled_at == ~U[2023-12-25 09:00:00.000Z]
      assert broadcast.sent_at == ~U[2023-12-25 09:01:15.123Z]
    end

    test "preserves fields not in struct definition" do
      map = %{
        "id" => "b6d24b8e-af0b-4c3c-be0c-359bbd97381e",
        "extra_field" => "should be ignored",
        "another_field" => 123
      }

      broadcast = Broadcast.cast(map)

      assert broadcast.id == "b6d24b8e-af0b-4c3c-be0c-359bbd97381e"
      # Extra fields should not be in the struct
      refute Map.has_key?(broadcast, :extra_field)
      refute Map.has_key?(broadcast, :another_field)
    end

    test "handles broadcast response from API after creation" do
      # Typical response after creating a broadcast
      map = %{
        "object" => "broadcast",
        "id" => "b6d24b8e-af0b-4c3c-be0c-359bbd97381e",
        "audience_id" => "78261eea-8f8b-4381-83c6-79fa7120f1cf",
        "name" => "Welcome Campaign",
        "from" => "hello@example.com",
        "subject" => "Welcome!",
        "status" => "draft",
        "created_at" => "2023-10-06T22:59:55.977Z"
      }

      broadcast = Broadcast.cast(map)

      assert broadcast.id == "b6d24b8e-af0b-4c3c-be0c-359bbd97381e"
      assert broadcast.audience_id == "78261eea-8f8b-4381-83c6-79fa7120f1cf"
      assert broadcast.name == "Welcome Campaign"
      assert broadcast.from == "hello@example.com"
      assert broadcast.subject == "Welcome!"
      assert broadcast.status == "draft"
      assert broadcast.created_at == ~U[2023-10-06 22:59:55.977Z]
    end

    test "handles broadcast response from API after sending" do
      # Typical response after sending a broadcast
      map = %{
        "object" => "broadcast",
        "id" => "b6d24b8e-af0b-4c3c-be0c-359bbd97381e",
        "audience_id" => "78261eea-8f8b-4381-83c6-79fa7120f1cf",
        "name" => "Monthly Newsletter",
        "from" => "news@example.com",
        "subject" => "October Update",
        "status" => "sending",
        "created_at" => "2023-10-06T22:59:55.977Z",
        "sent_at" => "2023-10-07T09:00:00.000Z"
      }

      broadcast = Broadcast.cast(map)

      assert broadcast.status == "sending"
      assert broadcast.sent_at == ~U[2023-10-07 09:00:00.000Z]
    end

    test "handles broadcast response from API after deletion" do
      # Typical response after deleting a broadcast
      map = %{
        "object" => "broadcast",
        "id" => "b6d24b8e-af0b-4c3c-be0c-359bbd97381e",
        "deleted" => true
      }

      broadcast = Broadcast.cast(map)

      assert broadcast.id == "b6d24b8e-af0b-4c3c-be0c-359bbd97381e"
      assert broadcast.deleted == true
    end
  end
end
