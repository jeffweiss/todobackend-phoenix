defmodule Todobackend.TodoView do
  use Todobackend.Web, :view

  def render("index.json", %{todos: todos}) do
    %{data: render_many(todos, "todo.json")}
  end

  def render("show.json", %{todo: todo}) do
    %{data: render_one(todo, "todo.json")}
  end

  def render("todo.json", %{todo: todo}) do
    todo
  end
end
