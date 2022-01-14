# Multi-page form using Phoenix Framework

## Multi-page form requirements

- Break down complex models into multiple pages for better UX
- Perform native browser validation on submit
- Display previously entered values on back navigation
- Persist the model only on the last Submit
- Navigate back using browser button

## Getting started

- Create a new Phoenix project as per https://hexdocs.pm/phoenix/up_and_running.html#content
- (Optional) Add TailwindCSS for styling https://pragmaticstudio.com/tutorials/adding-tailwind-css-to-phoenix

## Create Model Context

Developer

- Name
- City
- Country
- Preferred Framework (Django, Ruby on Rails, Phoenix)

`mix phx.gen.context Developers Developer developers name:string city:string country:string framework:string`

`mix ecto.migrate`

`Developers.create_developer(%{name: "Martin Code", country: "UK", city: "London", framework: "Django"})`
