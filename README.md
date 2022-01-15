# Multi-page form using Phoenix Framework

## Multi-page form requirements

- Break down complex models into multiple pages for better UX
- Perform native browser validation on submit
- Display previously entered values on back navigation (using the buttons, not browser)
- Persist the model only on the last Submit
- Navigate back using browser button

## Getting started

- Create a new Phoenix project as per https://hexdocs.pm/phoenix/up_and_running.html#content
- (Optional) Add TailwindCSS for styling https://pragmaticstudio.com/tutorials/adding-tailwind-css-to-phoenix

## Create Model Context

Coder

- Name
- City
- Country
- Preferred Framework (Django, Ruby on Rails, Phoenix)

`mix phx.gen.context Coders Coder coders name:string city:string country:string framework:string`

`mix ecto.migrate`

`Coders.create_coder(%{name: "Martin Code", country: "UK", city: "London", framework: "Django"})`

## Preparing routes

```elixir
scope "/", MultiPageFormWeb do
    pipe_through :browser

    live "/", List

    live "/coders/new/name", NewLive, :name
    live "/coders/new/location", NewLive, :location
    live "/coders/new/framework", NewLive, :framework
  end
```
