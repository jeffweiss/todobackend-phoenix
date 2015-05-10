defmodule Todobackend.Todo do
  use Todobackend.Web, :model

  schema "todos" do
    field :title, :string
    field :order, :integer
    field :completed, :boolean, default: false

    timestamps
  end

  @required_fields ~w(title order completed)
  @optional_fields ~w()

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
