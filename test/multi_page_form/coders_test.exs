defmodule MultiPageForm.CodersTest do
  use MultiPageForm.DataCase

  alias MultiPageForm.Coders

  describe "coders" do
    alias MultiPageForm.Coders.Coder

    import MultiPageForm.CodersFixtures

    @invalid_attrs %{city: nil, country: nil, framework: nil, name: nil}

    test "list_coders/0 returns all coders" do
      coder = coder_fixture()
      assert Coders.list_coders() == [coder]
    end

    test "get_coder!/1 returns the coder with given id" do
      coder = coder_fixture()
      assert Coders.get_coder!(coder.id) == coder
    end

    test "create_coder/1 with valid data creates a coder" do
      valid_attrs = %{city: "some city", country: "some country", framework: "some framework", name: "some name"}

      assert {:ok, %Coder{} = coder} = Coders.create_coder(valid_attrs)
      assert coder.city == "some city"
      assert coder.country == "some country"
      assert coder.framework == "some framework"
      assert coder.name == "some name"
    end

    test "create_coder/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Coders.create_coder(@invalid_attrs)
    end

    test "update_coder/2 with valid data updates the coder" do
      coder = coder_fixture()
      update_attrs = %{city: "some updated city", country: "some updated country", framework: "some updated framework", name: "some updated name"}

      assert {:ok, %Coder{} = coder} = Coders.update_coder(coder, update_attrs)
      assert coder.city == "some updated city"
      assert coder.country == "some updated country"
      assert coder.framework == "some updated framework"
      assert coder.name == "some updated name"
    end

    test "update_coder/2 with invalid data returns error changeset" do
      coder = coder_fixture()
      assert {:error, %Ecto.Changeset{}} = Coders.update_coder(coder, @invalid_attrs)
      assert coder == Coders.get_coder!(coder.id)
    end

    test "delete_coder/1 deletes the coder" do
      coder = coder_fixture()
      assert {:ok, %Coder{}} = Coders.delete_coder(coder)
      assert_raise Ecto.NoResultsError, fn -> Coders.get_coder!(coder.id) end
    end

    test "change_coder/1 returns a coder changeset" do
      coder = coder_fixture()
      assert %Ecto.Changeset{} = Coders.change_coder(coder)
    end
  end
end
