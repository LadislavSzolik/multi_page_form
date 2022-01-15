defmodule MultiPageForm.Repo.Migrations.CreateCoders do
  use Ecto.Migration

  def change do
    create table(:coders) do
      add :name, :string
      add :city, :string
      add :country, :string
      add :framework, :string

      timestamps()
    end
  end
end
