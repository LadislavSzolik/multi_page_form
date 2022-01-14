defmodule MultiPageFormWeb.PageController do
  use MultiPageFormWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
