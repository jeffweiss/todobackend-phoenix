defmodule Todobackend.PageController do
  use Todobackend.Web, :controller

  plug :action

  def index(conn, _params) do
    render conn, "index.html"
  end
end
