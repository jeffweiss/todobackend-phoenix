defmodule Todobackend.TodoControllerTest do
  use Todobackend.ConnCase

  alias Todobackend.Todo
  @valid_params todo: %{completed: true, order: 42, title: "some content"}
  @invalid_params todo: %{}

  setup do
    conn = conn() |> put_req_header("accept", "application/json")
    {:ok, conn: conn}
  end

  test "GET /todos", %{conn: conn} do
    conn = get conn, todo_path(conn, :index)
    assert json_response(conn, 200)["data"] == []
  end

  test "GET /todos/:id", %{conn: conn} do
    todo = Repo.insert %Todo{}
    conn = get conn, todo_path(conn, :show, todo)
    assert json_response(conn, 200)["data"] == %{
      "id" => todo.id
    }
  end

  test "POST /todos with valid data", %{conn: conn} do
    conn = post conn, todo_path(conn, :create), @valid_params
    assert json_response(conn, 200)["data"]["id"]
  end

  test "POST /todos with invalid data", %{conn: conn} do
    conn = post conn, todo_path(conn, :create), @invalid_params
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "PUT /todos/:id with valid data", %{conn: conn} do
    todo = Repo.insert %Todo{}
    conn = put conn, todo_path(conn, :update, todo), @valid_params
    assert json_response(conn, 200)["data"]["id"]
  end

  test "PUT /todos/:id with invalid data", %{conn: conn} do
    todo = Repo.insert %Todo{}
    conn = put conn, todo_path(conn, :update, todo), @invalid_params
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "DELETE /todos/:id", %{conn: conn} do
    todo = Repo.insert %Todo{}
    conn = delete conn, todo_path(conn, :delete, todo)
    assert json_response(conn, 200)["data"]["id"]
    refute Repo.get(Todo, todo.id)
  end
end
