defmodule Housefit.Repo do
  use Ecto.Repo,
    otp_app: :housefit,
    adapter: Ecto.Adapters.Postgres
end
