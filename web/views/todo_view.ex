defmodule Todobackend.TodoView do
  use Todobackend.Web, :view

  def render("index.json", %{todos: todos}) do
    render_many(todos, "todo.json")
  end

  def render("show.json", %{todo: todo}) do
    render_one(todo, "todo.json")
  end

  def render("todo.json", %{todo: todo}) do
    %{id: todo.id,
      title: todo.title,
      order: todo.order,
      completed: todo.completed,
      url: todo_path(Todobackend.Endpoint, :show, todo),
    }
  end
end
