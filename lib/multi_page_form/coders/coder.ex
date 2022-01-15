defmodule MultiPageForm.Coders.Coder do
  use Ecto.Schema
  import Ecto.Changeset

  schema "coders" do
    field :city, :string
    field :country, :string
    field :framework, :string
    field :name, :string

    timestamps()
  end

  @doc false
  def changeset(coder, attrs) do
    coder
    |> cast(attrs, [:name, :city, :country, :framework])
    |> validate_required([:name, :city, :country, :framework])
  end

  def changeset_step(1, coder, attrs) do
    coder
    |> cast(attrs, [:name, :city, :country, :framework])
    |> validate_required([:name])
  end

  def changeset_step(2, coder, attrs) do
    coder
    |> cast(attrs, [:name, :city, :country, :framework])
    |> validate_required([:city, :country])
  end
end
