defmodule MultiPageForm.Repo do
  use Ecto.Repo,
    otp_app: :multi_page_form,
    adapter: Ecto.Adapters.Postgres
end
