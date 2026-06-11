defmodule RastreadorHabitosSustentaveisWeb.HabitLive.Form do
  use RastreadorHabitosSustentaveisWeb, :live_view

  alias RastreadorHabitosSustentaveis.Habits
  alias RastreadorHabitosSustentaveis.Habits.Habit

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        {@page_title}
        <:subtitle>
          Informe os dados do hábito sustentável e a pontuação gerada por sua prática.
        </:subtitle>
      </.header>

      <.form for={@form} id="habit-form" phx-change="validate" phx-submit="save">
        <.input
          field={@form[:name]}
          type="text"
          label="Nome"
          autocomplete="off"
          required
          phx-mounted={JS.focus()}
        />
        <.input
          field={@form[:description]}
          type="textarea"
          label="Descrição"
          rows="4"
          required
        />
        <.input
          field={@form[:category]}
          type="select"
          label="Categoria"
          prompt="Selecione uma categoria"
          options={@category_options}
          required
        />
        <.input
          field={@form[:points]}
          type="number"
          label="Pontuação"
          min="1"
          max="100"
          required
        />

        <div class="mt-6 flex flex-col-reverse gap-3 sm:flex-row sm:justify-end">
          <.button navigate={~p"/habits"} class="btn btn-ghost">
            Cancelar
          </.button>
          <.button variant="primary" phx-disable-with="Salvando...">
            Salvar hábito
          </.button>
        </div>
      </.form>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :category_options, Habits.category_options())}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  @impl true
  def handle_event("validate", %{"habit" => habit_params}, socket) do
    form =
      socket.assigns.current_scope
      |> Habits.change_habit(socket.assigns.habit, habit_params)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, :form, form)}
  end

  def handle_event("save", %{"habit" => habit_params}, socket) do
    save_habit(socket, socket.assigns.live_action, habit_params)
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    habit = Habits.get_habit!(socket.assigns.current_scope, id)

    socket
    |> assign(:page_title, "Editar hábito")
    |> assign(:habit, habit)
    |> assign_form(Habits.change_habit(socket.assigns.current_scope, habit))
  end

  defp apply_action(socket, :new, _params) do
    habit = %Habit{}

    socket
    |> assign(:page_title, "Novo hábito")
    |> assign(:habit, habit)
    |> assign_form(Habits.change_habit(socket.assigns.current_scope, habit))
  end

  defp save_habit(socket, :edit, habit_params) do
    case Habits.update_habit(socket.assigns.current_scope, socket.assigns.habit, habit_params) do
      {:ok, _habit} ->
        {:noreply,
         socket
         |> put_flash(:info, "Hábito atualizado com sucesso.")
         |> push_navigate(to: ~p"/habits")}

      {:error, changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_habit(socket, :new, habit_params) do
    case Habits.create_habit(socket.assigns.current_scope, habit_params) do
      {:ok, _habit} ->
        {:noreply,
         socket
         |> put_flash(:info, "Hábito criado com sucesso.")
         |> push_navigate(to: ~p"/habits")}

      {:error, changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end
end
