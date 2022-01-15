defmodule MultiPageFormWeb.List do
  use MultiPageFormWeb, :live_view

  alias MultiPageForm.Coders

  def mount(_args, _session, socket) do
    coders = Coders.list_coders()
    {:ok, assign(socket, coders: coders)}
  end

  def render(assigns) do
    ~H"""
    <h1 >Coders</h1>
    <%= live_redirect "Add Coder", to: Routes.live_path(@socket, MultiPageFormWeb.NewLive )  %>
    <%= for coder <- @coders do %>
      <p><%= coder.name %>,
      <%= coder.city %>,
      <%= coder.country %>,
      <%= coder.framework %>
      </p>
    <% end %>

    """
  end
end
