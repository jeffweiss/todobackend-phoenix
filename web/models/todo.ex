defmodule Todobackend.Todo do
  use Todobackend.Web, :model

  schema "todos" do
    field :title, :string
    field :order, :integer, default: 0
    field :completed, :boolean, default: false

    timestamps
  end

  @required_fields ~w(title order)
  @optional_fields ~w(completed)

  @doc """
  Creates a changeset based on the `model` and `params`.

  If `params` are nil, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ nil) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end
end
