defmodule Todobackend.Repo.Migrations.CreateTodo do
  use Ecto.Migration

  def change do
    create table(:todos) do
      add :title, :string
      add :order, :integer, default: 0
      add :completed, :boolean, default: false

      timestamps
    end
  end
end
