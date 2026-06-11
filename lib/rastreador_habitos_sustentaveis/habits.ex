defmodule RastreadorHabitosSustentaveis.Habits do
  @moduledoc """
  The Habits context.
  """

  import Ecto.Query, warn: false

  alias RastreadorHabitosSustentaveis.Accounts.Scope
  alias RastreadorHabitosSustentaveis.Habits.Habit
  alias RastreadorHabitosSustentaveis.Repo

  @valid_categories ~w(alimentacao transporte energia agua residuos)

  def list_categories, do: Habit.categories()

  def category_options do
    [
      {"Alimentação", "alimentacao"},
      {"Transporte", "transporte"},
      {"Energia", "energia"},
      {"Água", "agua"},
      {"Resíduos", "residuos"}
    ]
  end

  def category_label("alimentacao"), do: "Alimentação"
  def category_label("transporte"), do: "Transporte"
  def category_label("energia"), do: "Energia"
  def category_label("agua"), do: "Água"
  def category_label("residuos"), do: "Resíduos"
  def category_label(category), do: category

  def list_habits(%Scope{user: %{id: user_id}}, filters \\ %{}) do
    Habit
    |> where([habit], habit.user_id == ^user_id)
    |> filter_by_category(filters)
    |> order_by([habit], asc: habit.name)
    |> Repo.all()
  end

  def get_habit!(%Scope{user: %{id: user_id}}, id) do
    Repo.get_by!(Habit, id: id, user_id: user_id)
  end

  def change_habit(%Scope{}, %Habit{} = habit, attrs \\ %{}) do
    Habit.changeset(habit, attrs)
  end

  def create_habit(%Scope{user: %{id: user_id}}, attrs) do
    %Habit{user_id: user_id}
    |> Habit.changeset(attrs)
    |> Repo.insert()
  end

  def update_habit(%Scope{user: %{id: user_id}}, %Habit{user_id: user_id} = habit, attrs) do
    habit
    |> Habit.changeset(attrs)
    |> Repo.update()
  end

  def update_habit(%Scope{}, %Habit{}, _attrs), do: {:error, :not_found}

  def delete_habit(%Scope{user: %{id: user_id}}, %Habit{user_id: user_id} = habit) do
    Repo.delete(habit)
  end

  def delete_habit(%Scope{}, %Habit{}), do: {:error, :not_found}

  defp filter_by_category(query, %{"category" => category}) when category in @valid_categories,
    do: where(query, [habit], habit.category == ^category)

  defp filter_by_category(query, %{category: category}) when category in @valid_categories,
    do: where(query, [habit], habit.category == ^category)

  defp filter_by_category(query, _filters), do: query
end
