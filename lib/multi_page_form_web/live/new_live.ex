defmodule MultiPageFormWeb.NewLive do
  use MultiPageFormWeb, :live_view

  alias MultiPageForm.Coders
  alias MultiPageForm.Coders.Coder

  def mount(_params, _session, socket) do
    changeset = Coders.change_coder(%Coder{})
    socket = assign(socket, changeset: changeset, coder_data: %Coder{})
    {:ok, socket}
  end

  def handle_params(params, _url, socket) do
    step = String.to_integer(params["step"] || "1")
    socket = assign(socket, step: step)

    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <h1>New coder</h1>
    <.form let={f} for={@changeset} phx-submit="save" >
      <%= step_render(@step, f) %>
      <%= live_redirect "Cancel", to: Routes.live_path(@socket, MultiPageFormWeb.List )  %>
      <%= live_patch "Back", to: Routes.live_path(@socket, __MODULE__, step: @step-1)  %>
      <%= submit "Next" %>
    </.form>
    """
  end

  def handle_event("save", %{"coder" => params}, socket) do
    %{step: step, coder_data: coder_data} = socket.assigns
    socket = process_step(step, socket, params, coder_data)
    {:noreply, socket}
  end

  defp process_step(3, socket, params, coder_data) do
    case Coders.create_coder(coder_data, params) do
      {:ok, _coder} ->
        push_redirect(socket,
          to: Routes.live_path(socket, MultiPageFormWeb.List),
          replace: true
        )

      {:error, %Ecto.Changeset{} = changeset} ->
        assign(socket, changeset: changeset)
    end
  end

  defp process_step(step, socket, params, coder_data) do
    changeset = Coder.changeset_step(step, coder_data, params)

    case Ecto.Changeset.apply_action(changeset, :insert) do
      {:ok, coder} ->
        socket = assign(socket, changeset: changeset, coder_data: coder)

        push_patch(socket,
          to: Routes.live_path(socket, __MODULE__, step: step + 1)
        )

      {:error, %Ecto.Changeset{} = changeset} ->
        assign(socket, changeset: changeset)
    end
  end

  defp step_render(1, form) do
    assigns = %{form: form}

    ~H"""
     <div>
     <%= input_helper :name, @form  %>
     </div>
    """
  end

  defp step_render(2, form) do
    assigns = %{form: form}

    ~H"""
     <div>
     <%= input_helper :city, @form  %>
     <%= input_helper :country, @form  %>
     </div>
    """
  end

  defp step_render(3, form) do
    assigns = %{form: form}

    ~H"""
     <div>
     <%= input_helper :framework, @form  %>
     </div>
    """
  end

  # Fallback step render
  defp step_render(step, form) do
    assigns = %{step: step, form: form}

    ~H"""
    <p>Invalid step: <%= @step %> </p>
    """
  end

  defp input_helper(field, form) do
    assigns = %{field: field, form: form}

    ~H"""
      <div>
      <%= label @form, @field %>
      <%= text_input @form, @field %>
      <%= error_tag @form, @field %>
      </div>
    """
  end
end
