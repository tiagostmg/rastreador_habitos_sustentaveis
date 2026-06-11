defmodule RastreadorHabitosSustentaveis.HabitsFixtures do
  @moduledoc """
  This module defines test helpers for creating habits.
  """

  alias RastreadorHabitosSustentaveis.Habits

  def valid_habit_attributes(attrs \\ %{}) do
    Enum.into(attrs, %{
      name: "Economizar água",
      description: "Fechar a torneira enquanto escova os dentes.",
      category: "agua",
      points: 10
    })
  end

  def habit_fixture(scope, attrs \\ %{}) do
    {:ok, habit} =
      scope
      |> Habits.create_habit(valid_habit_attributes(attrs))

    habit
  end
end
