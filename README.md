# Multi-page form using Phoenix LiveView

![Demo](demo.mov)

## Intro

### Multi-page form Requirements

- Display a database model in multiple steps for better UX
- Persist the model only on the last Submit
- When user hits Enter on keyboard, or clicks on "Next", the currently displayed form should be validated
- Display previously entered values on back navigation (using the buttons, not browser)
- After form submission user should not be able to navigate back

### Out of scope for this demo

- Show stepper indicator with completed and current steps
- Layout variations to display the input fields
- OnBlur validation
- Change "Next" button text on last step
- Alert user on leaving the drafted form without submission
- Installing CSS pre or post processor (I used TailwindCSS)
- App deployment to production

## Getting started

- Create a new Phoenix **LiveView** project

```elixir
mix phx.new my_app --live
```

- Follow the steps in the code comment
- More info in docs: https://hexdocs.pm/phoenix_live_view/installation.html

## Design considerations

- The <form> tag remains on the page all the time, only the form controls are changing
- To navigate between steps I used URL query parameter to allow navigation with the browser's back button
- All pages of the form are located in a signle file. Potentially they can be seperated into single functional components for large forms.

## Creating database schema

- For simplicity we use the following table:

```
Coders
  - Name
  - City
  - Country
  - Preferred Framework
```

```elixir
mix phx.gen.context Coders Coder coders name:string city:string country:string framework:string
```

```elixir
mix ecto.migrate
```

```elixir
Coders.create_coder(%{name: "Martin Code", country: "UK", city: "London", framework: "Django"})
```

## Modify context and schema to add partial validations

### Changes in schema

```elixir
#File: lib/multi_page_form/coders/coder.ex
defmodule MultiPageForm.Coders.Coder do
  use Ecto.Schema
  import Ecto.Changeset

  schema "coders" do
    field :city, :string
    field :country, :string
    field :framework, :string
    field :name, :string
    timestamps()
  end

  # 1. No change. We use this function for the final submission
  @doc false
  def changeset(coder, attrs) do
    coder
    |> cast(attrs, [:name, :city, :country, :framework])
    |> validate_required([:name, :city, :country, :framework])
  end

  # 2. Add functions to validate each step:

  # 2.1 Add function to validate step 1
  def changeset_step(1, coder, attrs) do
    coder
    # 2.2. Cast all attribute so that they are carried over from one step to other
    |> cast(attrs, [:name, :city, :country, :framework])
    # 2.3 Customize the validation required at this step
    |> validate_required([:name])
  end

  # 2.3. Add further function for other steps...
  def changeset_step(2, coder, attrs) do
    coder
    |> cast(attrs, [:name, :city, :country, :framework])
    |> validate_required([:city, :country])
  end
end
```

### Changes in context

I will not copy the whole file, only the changed function:

```elixir
  # File: lib/multi_page_form/coders.ex

  # 1. Add Schema as input parameter so that
  #    we can pass the intermediate scheme, which was created between steps.
  def create_coder(%Coder{} = coder, attrs \\ %{}) do
    coder
    |> Coder.changeset(attrs)
    |> Repo.insert()
  end
```

## Preparing routes

```elixir
# File: lib/multi_page_form_web/router.ex
scope "/", MultiPageFormWeb do
    pipe_through :browser

    live "/coders/new", NewLive # 1. Add route to the form
    live "/", List  # 2. (Optional) Add route to display stored data

  end
```

## Displaying the form

```elixir
# File: lib/multi_page_form_web/live/new_live.ex
defmodule MultiPageFormWeb.NewLive do
  # 1. Import modules
  # 1.1. Use live_view to avoid full page reload
  use MultiPageFormWeb, :live_view

  # 1.2. Alias Schema Coder, to use as form data container
  alias MultiPageForm.Coders.Coder
  # 1.3. Alias Context Coders, to use create_coders function
  alias MultiPageForm.Coders

  # 2. Include initial form data in the socket
  def mount(_params, _session, socket) do
    # 2.1. Init changeset, it will be used in the phoenix form to track changes and display errors
    changeset = Coders.change_coder(%Coder{})
    # 2.2. Init coder_data, it will hold form data between steps
    coder_data = %Coder{}
    # 2.3 Assign them in socket so that it is accessible in the template
    socket = assign(socket, changeset: changeset, coder_data: coder_data )
    {:ok, socket}
  end

  # 3. Include current step from the URL query param in the socket
  def handle_params(params, _url, socket) do
    step = String.to_integer(params["step"] || "1")
    socket = assign(socket, step: step)
    {:noreply, socket}
  end

  # 4. Render the form
  def render(assigns) do
  # 4.1 Render form using Phoenix helper function
  # 4.2 Render current step
  # 4.3 Render navigation buttons
    ~H"""
    <h1>New coder</h1>
    <.form let={f} for={@changeset} phx-submit="save" >

      <%= step_render(@step, f) %>

      <%= live_redirect "Cancel",
		      to: Routes.live_path(@socket, MultiPageFormWeb.List )  %>

      <%= if @step != 1 do%>
        <%= live_patch "Back",
          to: Routes.live_path(@socket, __MODULE__ , step: @step-1)  %>
      <% end %>

      <%= submit "Next" %>
    </.form>
    """
  end

  # 5. Handle form submission

  # 5.1 Add function to listen to "save" event and call process_step to process the form
  def handle_event("save", %{"coder" => params}, socket) do
    # 5.1.1 Getting params, which contains currently submitted partial data
    # 5.1.2 Extracting step and coder_data from socket, to perform validation and navigaton to the next step
    %{step: step, coder_data: coder_data} = socket.assigns

    # 5.1.3 Add function to create or change form data and navigate to the next step
    socket = process_step(step, socket, params, coder_data)
    {:noreply, socket}
  end

  # 5.2. Add function to handle final step (order matters), which persist the data and navigate away
  defp process_step(3, socket, params, coder_data) do
    case Coders.create_coder(coder_data, params) do
      {:ok, _coder} ->
        # 5.2.1. Notice the replace:true, this way user cannot navigate back
        push_redirect(socket,
          to: Routes.live_path(socket, MultiPageFormWeb.List),
          replace: true
        )
      {:error, %Ecto.Changeset{} = changeset} ->
        assign(socket, changeset: changeset)
    end
  end

  # 5.3. Add function to handle intermediate steps (order matters). It changes form data and navigate to next step
  defp process_step(step, socket, params, coder_data) do
    changeset = Coder.changeset_step(step, coder_data, params)
    # 5.3.1 Notice the apply_action, without this no validation errors are displayed.
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

  # 6. Render helpers for each step

  # 6.1. Add helper function to render step 1
  defp step_render(1, form) do
    assigns = %{form: form}
    ~H"""
     <div>
     <%= input_helper :name, @form  %>
     </div>
    """
  end

  # 6.2. Add helper function to render step 2
  defp step_render(2, form) do
    assigns = %{form: form}
    ~H"""
     <div>
     <%= input_helper :city, @form  %>
     <%= input_helper :country, @form  %>
     </div>
    """
  end

  # 6.3. Add helper function to render step 3
  defp step_render(3, form) do
    assigns = %{form: form}
    ~H"""
     <div>
     <%= input_helper :framework, @form  %>
     </div>
    """
  end

  # 6.4. Fallback step in a case of invalid step number
  defp step_render(step, form) do
    assigns = %{step: step, form: form}
    ~H"""
    <p>Invalid step: <%= @step %> </p>
    """
  end

  # 7. (Optional) Extract rendering the input into a function
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
```

## (Optional) Displaying the stored data

- If you want to quickly display the stored data:

```elixir
# File: lib/multi_page_form_web/live/list.ex
defmodule MultiPageFormWeb.List do
  # 1. This is a liveView to avoid full page reload on navigation
  use MultiPageFormWeb, :live_view

  # 2. Alias Coders context to fetch data
  alias MultiPageForm.Coders

  def mount(_args, _session, socket) do
    # 2. Fetch stored data and assign to socket, so that it can be used in template
    coders = Coders.list_coders()
    {:ok, assign(socket, coders: coders)}
  end

  def render(assigns) do
    # 3. Simple for loop displays stored data
    # 4. live_redirect used to navigate to the form without full page reload
    ~H"""
    <h1 >Coders</h1>
    <%= live_redirect "Add Coder",
		  to: Routes.live_path(@socket, MultiPageFormWeb.NewLive )  %>
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
```

## Homework

- Add stepper indicator. Do you prefer words? (1 out of 4) or a visual bar with steps?
- Change submit button text at the last step to "Submit" or "Finalize".
- Show alert if user want's to leave unsubmitted form
- Get in touch with me for further questions/ideas/improvements
