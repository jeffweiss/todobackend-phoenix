defmodule Todobackend.Router do
  use Todobackend.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
  end

  pipeline :api do
    plug :cors
    plug :accepts, ["json"]
  end

  scope "/", Todobackend do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
  end

  # Other scopes may use custom stacks.
  scope "/api", Todobackend do
    pipe_through :api
    resources "/todos", TodoController
    options "/todos", TodoController, :options
  end

  def cors(conn, _opts) do
    conn
    |> put_resp_header("access-control-allow-origin", "*")
    |> put_resp_header("access-control-allow-headers", "content-type")
  end
end
