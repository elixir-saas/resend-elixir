defmodule Resend.Contacts.ContactTest do
  use ExUnit.Case, async: true

  alias Resend.Contacts.Contact

  describe "cast/1" do
    test "casts a valid contact map to struct" do
      contact_map = %{
        "id" => "e169aa45-1ecf-4183-9955-b1499d5701d3",
        "email" => "steve.wozniak@gmail.com",
        "first_name" => "Steve",
        "last_name" => "Wozniak",
        "created_at" => "2023-10-06T23:47:56.678Z",
        "unsubscribed" => false
      }

      result = Contact.cast(contact_map)

      assert %Contact{
               id: "e169aa45-1ecf-4183-9955-b1499d5701d3",
               email: "steve.wozniak@gmail.com",
               first_name: "Steve",
               last_name: "Wozniak",
               created_at: ~U[2023-10-06 23:47:56.678Z],
               unsubscribed: false,
               deleted: nil
             } = result
    end

    test "casts a contact map with deleted flag" do
      contact_map = %{
        "id" => "e169aa45-1ecf-4183-9955-b1499d5701d3",
        "email" => "steve.wozniak@gmail.com",
        "deleted" => true
      }

      result = Contact.cast(contact_map)

      assert %Contact{
               id: "e169aa45-1ecf-4183-9955-b1499d5701d3",
               email: "steve.wozniak@gmail.com",
               first_name: nil,
               last_name: nil,
               created_at: nil,
               unsubscribed: nil,
               deleted: true
             } = result
    end

    test "casts a minimal contact map" do
      contact_map = %{
        "id" => "e169aa45-1ecf-4183-9955-b1499d5701d3"
      }

      result = Contact.cast(contact_map)

      assert %Contact{
               id: "e169aa45-1ecf-4183-9955-b1499d5701d3",
               email: nil,
               first_name: nil,
               last_name: nil,
               created_at: nil,
               unsubscribed: nil,
               deleted: nil
             } = result
    end

    test "handles contact field in delete response" do
      contact_map = %{
        "contact" => "520784e2-887d-4c25-b53c-4ad46ad38100",
        "deleted" => true
      }

      result = Contact.cast(contact_map)

      assert %Contact{
               id: "520784e2-887d-4c25-b53c-4ad46ad38100",
               email: nil,
               first_name: nil,
               last_name: nil,
               created_at: nil,
               unsubscribed: nil,
               deleted: true
             } = result
    end

    test "handles nil datetime" do
      contact_map = %{
        "id" => "e169aa45-1ecf-4183-9955-b1499d5701d3",
        "email" => "test@example.com",
        "created_at" => nil
      }

      result = Contact.cast(contact_map)

      assert %Contact{
               id: "e169aa45-1ecf-4183-9955-b1499d5701d3",
               email: "test@example.com",
               created_at: nil
             } = result
    end

    test "handles unsubscribed status" do
      contact_map = %{
        "id" => "e169aa45-1ecf-4183-9955-b1499d5701d3",
        "email" => "test@example.com",
        "unsubscribed" => true
      }

      result = Contact.cast(contact_map)

      assert %Contact{
               id: "e169aa45-1ecf-4183-9955-b1499d5701d3",
               email: "test@example.com",
               unsubscribed: true
             } = result
    end
  end
end
