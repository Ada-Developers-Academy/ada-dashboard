defmodule Dashboard.Calendars.Event do
  use Ecto.Schema
  import Ecto.Changeset

  schema "events" do
    field :description, :string
    field :external_id, :string
    field :external_provider, :string
    field :name, :string

    timestamps()
  end

  @doc false
  def changeset(event, attrs) do
    event
    |> cast(attrs, [:name, :description, :external_id, :external_provider])
    |> unique_constraint([:external_id, :external_provider])
    |> validate_required([:name, :description, :external_id, :external_provider])
  end
end
