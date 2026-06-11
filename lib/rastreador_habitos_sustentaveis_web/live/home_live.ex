defmodule RastreadorHabitosSustentaveisWeb.HomeLive do
  use RastreadorHabitosSustentaveisWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="hero min-h-[70vh] bg-base-200 rounded-box shadow-xl overflow-hidden relative">
        <!-- Decorative background elements -->
        <!--div class="absolute top-0 right-0 -mr-20 -mt-20 w-64 h-64 rounded-full bg-primary/20 blur-3xl">
        </div>
        <div class="absolute bottom-0 left-0 -ml-20 -mb-20 w-80 h-80 rounded-full bg-secondary/20 blur-3xl">
        </div>-->

        <div class=" text-center z-10">
          <div class="max-w-md">
            <h1 class="text-5xl font-bold bg-clip-text text-transparent bg-gradient-to-r from-primary to-secondary">
              Bem-vindo, {@current_scope.user.name || "Sustentável"}!
            </h1>
            <p class="py-6 text-lg text-base-content/80">
              Estamos felizes em ter você aqui. Acompanhe seus hábitos diários, ganhe pontos e ajude a construir um futuro mais sustentável para todos nós.
            </p>
            <div class="flex gap-4 justify-center mt-4">
              <.link
                navigate={~p"/habits"}
                class="btn btn-primary btn-lg shadow-lg shadow-primary/30 transition-transform hover:scale-105"
              >
                Meus Hábitos
              </.link>
              <.link
                navigate={~p"/users/settings"}
                class="btn btn-outline btn-lg transition-transform hover:scale-105"
              >
                Configurações
              </.link>
            </div>
          </div>
        </div>
      </div>
    </Layouts.app>
    """
  end
end
