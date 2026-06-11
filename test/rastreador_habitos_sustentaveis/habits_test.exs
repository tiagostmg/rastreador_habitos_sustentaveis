defmodule RastreadorHabitosSustentaveis.HabitsTest do
  use RastreadorHabitosSustentaveis.DataCase

  alias RastreadorHabitosSustentaveis.Accounts.Scope
  alias RastreadorHabitosSustentaveis.Habits
  alias RastreadorHabitosSustentaveis.Habits.Habit

  import RastreadorHabitosSustentaveis.AccountsFixtures
  import RastreadorHabitosSustentaveis.HabitsFixtures

  describe "habits" do
    setup do
      user = user_fixture()
      scope = Scope.for_user(user)
      %{scope: scope}
    end

    test "list_habits/2 returns habits owned by the scoped user", %{scope: scope} do
      habit = habit_fixture(scope)

      other_user = user_fixture()
      other_scope = Scope.for_user(other_user)
      habit_fixture(other_scope, %{name: "Usar bicicleta", category: "transporte"})

      assert Habits.list_habits(scope) == [habit]
    end

    test "list_habits/2 filters habits by category", %{scope: scope} do
      habit = habit_fixture(scope)
      habit_fixture(scope, %{name: "Evitar descartáveis", category: "residuos"})

      assert Habits.list_habits(scope, %{"category" => "agua"}) == [habit]
    end

    test "get_habit!/2 returns the habit with given id", %{scope: scope} do
      habit = habit_fixture(scope)
      assert Habits.get_habit!(scope, habit.id) == habit
    end

    test "get_habit!/2 raises for another user's habit", %{scope: scope} do
      other_user = user_fixture()
      other_scope = Scope.for_user(other_user)
      habit = habit_fixture(other_scope)

      assert_raise Ecto.NoResultsError, fn ->
        Habits.get_habit!(scope, habit.id)
      end
    end

    test "create_habit/2 with valid data creates a habit for the scoped user", %{scope: scope} do
      attrs = valid_habit_attributes(%{name: "Separar resíduos"})

      assert {:ok, %Habit{} = habit} = Habits.create_habit(scope, attrs)
      assert habit.name == "Separar resíduos"
      assert habit.user_id == scope.user.id
    end

    test "create_habit/2 with invalid data returns changeset errors", %{scope: scope} do
      attrs = %{name: "", description: "", category: "invalida", points: 0}

      assert {:error, %Ecto.Changeset{} = changeset} = Habits.create_habit(scope, attrs)
      assert "can't be blank" in errors_on(changeset).name
      assert "is invalid" in errors_on(changeset).category
      assert "must be greater than 0" in errors_on(changeset).points
    end

    test "update_habit/3 updates owned habits", %{scope: scope} do
      habit = habit_fixture(scope)

      assert {:ok, %Habit{} = habit} =
               Habits.update_habit(scope, habit, %{name: "Banho rápido"})

      assert habit.name == "Banho rápido"
    end

    test "update_habit/3 refuses another user's habit", %{scope: scope} do
      other_user = user_fixture()
      other_scope = Scope.for_user(other_user)
      habit = habit_fixture(other_scope)

      assert Habits.update_habit(scope, habit, %{name: "Inválido"}) == {:error, :not_found}
    end

    test "delete_habit/2 deletes owned habits", %{scope: scope} do
      habit = habit_fixture(scope)

      assert {:ok, %Habit{}} = Habits.delete_habit(scope, habit)
      assert_raise Ecto.NoResultsError, fn -> Habits.get_habit!(scope, habit.id) end
    end

    test "delete_habit/2 refuses another user's habit", %{scope: scope} do
      other_user = user_fixture()
      other_scope = Scope.for_user(other_user)
      habit = habit_fixture(other_scope)

      assert Habits.delete_habit(scope, habit) == {:error, :not_found}
    end
  end
end
