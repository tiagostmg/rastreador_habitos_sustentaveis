defmodule RastreadorHabitosSustentaveisWeb.HabitLive.Index do
  use RastreadorHabitosSustentaveisWeb, :live_view

  alias RastreadorHabitosSustentaveis.Habits

  @categories ~w(alimentacao transporte energia agua residuos)

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Meus Hábitos
        <:subtitle>
          Cadastre, filtre e gerencie seus hábitos sustentáveis do dia a dia.
        </:subtitle>
        <:actions>
          <.button navigate={~p"/habits/new"} variant="primary">
            <.icon name="hero-plus" class="size-4" /> Novo hábito
          </.button>
        </:actions>
      </.header>

      <.form for={@filter_form} id="habit-filter-form" phx-change="filter" class="mb-6">
        <.input
          field={@filter_form[:category]}
          type="select"
          label="Filtrar por categoria"
          prompt="Todas as categorias"
          options={@category_options}
        />
      </.form>

      <div id="habits" phx-update="stream" class="space-y-3">
        <div class="hidden only:block rounded-box border border-dashed border-base-300 bg-base-200/60 p-8 text-center">
          <.icon name="hero-sparkles" class="mx-auto mb-3 size-8 text-primary" />
          <p class="font-semibold">Nenhum hábito encontrado.</p>
          <p class="text-sm text-base-content/70">
            Crie seu primeiro hábito sustentável ou ajuste o filtro selecionado.
          </p>
        </div>

        <article
          :for={{id, habit} <- @streams.habits}
          id={id}
          class="rounded-box border border-base-300 bg-base-100 p-4 shadow-sm transition hover:-translate-y-0.5 hover:shadow-md"
        >
          <div class="flex flex-col gap-4 sm:flex-row sm:items-start sm:justify-between">
            <div class="min-w-0">
              <div class="flex flex-wrap items-center gap-2">
                <h2 class="text-lg font-semibold">{habit.name}</h2>
                <span class="badge badge-primary badge-soft">
                  {Habits.category_label(habit.category)}
                </span>
                <span class="badge badge-secondary badge-soft">
                  {habit.points} pts
                </span>
              </div>
              <p class="mt-2 text-sm leading-6 text-base-content/75">{habit.description}</p>
            </div>

            <div class="flex shrink-0 gap-2">
              <.link
                navigate={~p"/habits/#{habit}/edit"}
                class="btn btn-sm btn-outline transition-transform hover:scale-105"
              >
                <.icon name="hero-pencil-square" class="size-4" /> Editar
              </.link>
              <button
                id={"delete-habit-#{habit.id}"}
                class="btn btn-sm btn-error btn-soft transition-transform hover:scale-105"
                phx-click="delete"
                phx-value-id={habit.id}
                data-confirm="Remover este hábito?"
              >
                <.icon name="hero-trash" class="size-4" /> Remover
              </button>
            </div>
          </div>
        </article>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:category_options, Habits.category_options())
     |> assign_filter_form(%{})
     |> stream(:habits, [])}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    filters = filter_params(params)
    habits = Habits.list_habits(socket.assigns.current_scope, filters)

    {:noreply,
     socket
     |> assign_filter_form(filters)
     |> stream(:habits, habits, reset: true)}
  end

  @impl true
  def handle_event("filter", %{"filter" => filter}, socket) do
    category = Map.get(filter, "category")

    path =
      if category in Habits.list_categories(),
        do: ~p"/habits?category=#{category}",
        else: ~p"/habits"

    {:noreply, push_patch(socket, to: path)}
  end

  def handle_event("delete", %{"id" => id}, socket) do
    habit = Habits.get_habit!(socket.assigns.current_scope, id)
    {:ok, _habit} = Habits.delete_habit(socket.assigns.current_scope, habit)

    {:noreply,
     socket
     |> put_flash(:info, "Hábito removido com sucesso.")
     |> stream_delete(:habits, habit)}
  end

  defp assign_filter_form(socket, filters) do
    assign(socket, :filter_form, to_form(filters, as: :filter))
  end

  defp filter_params(%{"category" => category}) when category in @categories,
    do: %{"category" => category}

  defp filter_params(_params), do: %{}
end
