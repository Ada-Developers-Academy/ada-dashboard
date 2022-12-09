alias Dashboard.Classes.Class

defmodule Dashboard.Campuses.Campus do
  use Ecto.Schema
  import Ecto.Changeset

  schema "campuses" do
    field :name, :string
    has_many :classes, Class

    timestamps()
  end

  @doc false
  def changeset(campus, attrs) do
    campus
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
