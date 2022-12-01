defmodule Dashboard.Campuses.Campus do
  use Ecto.Schema
  import Ecto.Changeset

  schema "campus" do
    field :name, :string

    timestamps()
  end

  @doc false
  def changeset(campus, attrs) do
    campus
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
