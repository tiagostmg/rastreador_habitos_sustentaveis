defmodule RastreadorHabitosSustentaveis.Repo.Migrations.CreateHabits do
  use Ecto.Migration

  def change do
    create table(:habits) do
      add :name, :string, null: false
      add :description, :string, null: false
      add :category, :string, null: false
      add :points, :integer, null: false
      add :user_id, references(:users, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:habits, [:user_id])
    create index(:habits, [:category])
    create unique_index(:habits, [:user_id, :name])
  end
end
