defmodule Todobackend.TodoController do
  use Todobackend.Web, :controller

  alias Todobackend.Todo

  plug :scrub_params, "todo" when action in [:create, :update]
  plug :action

  def index(conn, _params) do
    todos = Repo.all(Todo)
    render(conn, "index.json", todos: todos)
  end

  def create(conn, todo_params) do
    changeset = Todo.changeset(%Todo{}, todo_params)

    if changeset.valid? do
      todo = Repo.insert(changeset)
      render(conn, "show.json", todo: todo)
    else
      conn
      |> put_status(:unprocessable_entity)
      |> render(Todobackend.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    todo = Repo.get(Todo, id)
    render conn, "show.json", todo: todo
  end

  def update(conn, %{"id" => id, "todo" => todo_params}) do
    todo = Repo.get(Todo, id)
    changeset = Todo.changeset(todo, todo_params)

    if changeset.valid? do
      todo = Repo.update(changeset)
      render(conn, "show.json", todo: todo)
    else
      conn
      |> put_status(:unprocessable_entity)
      |> render(Todobackend.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    todo = Repo.get(Todo, id)

    todo = Repo.delete(todo)
    render(conn, "show.json", todo: todo)
  end

  def options(conn, _params) do
    conn
    |> send_resp(200, "GET,HEAD,POST,DELETE,OPTIONS,PUT")
  end
end
