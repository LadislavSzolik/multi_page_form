defmodule MultiPageForm.CodersFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `MultiPageForm.Coders` context.
  """

  @doc """
  Generate a coder.
  """
  def coder_fixture(attrs \\ %{}) do
    {:ok, coder} =
      attrs
      |> Enum.into(%{
        city: "some city",
        country: "some country",
        framework: "some framework",
        name: "some name"
      })
      |> MultiPageForm.Coders.create_coder()

    coder
  end
end
