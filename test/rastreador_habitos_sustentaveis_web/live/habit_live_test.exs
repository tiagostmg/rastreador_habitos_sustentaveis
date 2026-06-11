defmodule RastreadorHabitosSustentaveisWeb.HabitLiveTest do
  use RastreadorHabitosSustentaveisWeb.ConnCase

  import Phoenix.LiveViewTest
  import RastreadorHabitosSustentaveis.AccountsFixtures
  import RastreadorHabitosSustentaveis.HabitsFixtures

  alias RastreadorHabitosSustentaveis.Accounts.Scope
  alias RastreadorHabitosSustentaveis.Habits

  @create_attrs %{
    name: "Compostagem doméstica",
    description: "Separar resíduos orgânicos para compostagem.",
    category: "residuos",
    points: 20
  }
  @update_attrs %{
    name: "Transporte ativo",
    description: "Ir a pé ou de bicicleta em trajetos curtos.",
    category: "transporte",
    points: 15
  }
  @invalid_attrs %{name: "", description: "", category: "", points: 0}

  describe "Index" do
    setup [:register_and_log_in_user]

    test "lists current user's habits", %{conn: conn, scope: scope} do
      habit = habit_fixture(scope)
      other_scope = Scope.for_user(user_fixture())
      habit_fixture(other_scope, %{name: "Hábito invisível"})

      {:ok, view, _html} = live(conn, ~p"/habits")

      assert has_element?(view, "#habits-#{habit.id}")
      refute render(view) =~ "Hábito invisível"
    end

    test "filters habits by category", %{conn: conn, scope: scope} do
      habit = habit_fixture(scope)
      other_habit = habit_fixture(scope, %{name: "Usar bicicleta", category: "transporte"})

      {:ok, view, _html} = live(conn, ~p"/habits")

      view
      |> element("#habit-filter-form")
      |> render_change(%{"filter" => %{"category" => "agua"}})

      assert has_element?(view, "#habits-#{habit.id}")
      refute has_element?(view, "#habits-#{other_habit.id}")
    end

    test "deletes habit in listing", %{conn: conn, scope: scope} do
      habit = habit_fixture(scope)

      {:ok, view, _html} = live(conn, ~p"/habits")

      view
      |> element("#delete-habit-#{habit.id}")
      |> render_click()

      refute has_element?(view, "#habits-#{habit.id}")
      assert_raise Ecto.NoResultsError, fn -> Habits.get_habit!(scope, habit.id) end
    end
  end

  describe "New" do
    setup [:register_and_log_in_user]

    test "renders form", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/habits/new")

      assert has_element?(view, "#habit-form")
    end

    test "creates habit and redirects", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/habits/new")

      view
      |> form("#habit-form", habit: @create_attrs)
      |> render_submit()

      assert_redirect(view, ~p"/habits")
    end

    test "renders errors with invalid data", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/habits/new")

      html =
        view
        |> form("#habit-form", habit: @invalid_attrs)
        |> render_submit()

      assert html =~ "can&#39;t be blank"
      assert html =~ "must be greater than 0"
    end
  end

  describe "Edit" do
    setup [:register_and_log_in_user]

    test "updates habit and redirects", %{conn: conn, scope: scope} do
      habit = habit_fixture(scope)

      {:ok, view, _html} = live(conn, ~p"/habits/#{habit}/edit")

      view
      |> form("#habit-form", habit: @update_attrs)
      |> render_submit()

      assert_redirect(view, ~p"/habits")
      assert Habits.get_habit!(scope, habit.id).name == "Transporte ativo"
    end

    test "does not allow editing another user's habit", %{conn: conn} do
      other_scope = Scope.for_user(user_fixture())
      habit = habit_fixture(other_scope)

      assert_raise Ecto.NoResultsError, fn ->
        live(conn, ~p"/habits/#{habit}/edit")
      end
    end
  end

  describe "Authentication" do
    test "redirects index when user is not logged in", %{conn: conn} do
      assert {:error, redirect} = live(conn, ~p"/habits")
      assert {:redirect, %{to: path}} = redirect
      assert path == ~p"/users/log-in"
    end

    test "redirects new when user is not logged in", %{conn: conn} do
      assert {:error, redirect} = live(conn, ~p"/habits/new")
      assert {:redirect, %{to: path}} = redirect
      assert path == ~p"/users/log-in"
    end
  end
end
