defmodule RastreadorHabitosSustentaveis.Habits.Habit do
  use Ecto.Schema
  import Ecto.Changeset

  @categories ~w(alimentacao transporte energia agua residuos)

  schema "habits" do
    field :name, :string
    field :description, :string
    field :category, :string
    field :points, :integer

    belongs_to :user, RastreadorHabitosSustentaveis.Accounts.User

    timestamps(type: :utc_datetime)
  end

  def categories, do: @categories

  def changeset(habit, attrs) do
    habit
    |> cast(attrs, [:name, :description, :category, :points])
    |> validate_required([:name, :description, :category, :points])
    |> validate_length(:name, min: 3, max: 100)
    |> validate_length(:description, min: 5, max: 500)
    |> validate_inclusion(:category, @categories)
    |> validate_number(:points, greater_than: 0, less_than_or_equal_to: 100)
    |> unique_constraint(:name, name: :habits_user_id_name_index)
  end
end
