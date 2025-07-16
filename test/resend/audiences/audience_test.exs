defmodule Resend.Audiences.AudienceTest do
  use ExUnit.Case, async: true

  alias Resend.Audiences.Audience

  describe "cast/1" do
    test "casts a valid audience map to struct" do
      audience_map = %{
        "id" => "78261eea-8f8b-4381-83c6-79fa7120f1cf",
        "name" => "Registered Users",
        "created_at" => "2023-10-06T22:59:55.977Z"
      }

      result = Audience.cast(audience_map)

      assert %Audience{
               id: "78261eea-8f8b-4381-83c6-79fa7120f1cf",
               name: "Registered Users",
               created_at: ~U[2023-10-06 22:59:55.977Z],
               deleted: nil
             } = result
    end

    test "casts an audience map with deleted flag" do
      audience_map = %{
        "id" => "78261eea-8f8b-4381-83c6-79fa7120f1cf",
        "name" => "Registered Users",
        "created_at" => "2023-10-06T22:59:55.977Z",
        "deleted" => true
      }

      result = Audience.cast(audience_map)

      assert %Audience{
               id: "78261eea-8f8b-4381-83c6-79fa7120f1cf",
               name: "Registered Users",
               created_at: ~U[2023-10-06 22:59:55.977Z],
               deleted: true
             } = result
    end

    test "casts a minimal audience map" do
      audience_map = %{
        "id" => "78261eea-8f8b-4381-83c6-79fa7120f1cf"
      }

      result = Audience.cast(audience_map)

      assert %Audience{
               id: "78261eea-8f8b-4381-83c6-79fa7120f1cf",
               name: nil,
               created_at: nil,
               deleted: nil
             } = result
    end

    test "handles nil datetime" do
      audience_map = %{
        "id" => "78261eea-8f8b-4381-83c6-79fa7120f1cf",
        "name" => "Test Audience",
        "created_at" => nil
      }

      result = Audience.cast(audience_map)

      assert %Audience{
               id: "78261eea-8f8b-4381-83c6-79fa7120f1cf",
               name: "Test Audience",
               created_at: nil,
               deleted: nil
             } = result
    end
  end
end
