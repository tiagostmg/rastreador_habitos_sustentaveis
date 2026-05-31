defmodule RastreadorHabitosSustentaveis.Repo do
  use Ecto.Repo,
    otp_app: :rastreador_habitos_sustentaveis,
    adapter: Ecto.Adapters.SQLite3,
    database: "priv/data/dev.db"
end
