defmodule RastreadorHabitosSustentaveisWeb.PageController do
  use RastreadorHabitosSustentaveisWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
