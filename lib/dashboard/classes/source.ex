defmodule Dashboard.Classes.Source do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  schema "sources" do
    field :class_id, :id, primary_key: true
    field :calendar_id, :id, primary_key: true
  end

  @doc false
  def changeset(source, attrs) do
    source
    |> cast(attrs, [:class_id, :calendar_id])
    |> validate_required([:class_id, :calendar_id])
  end
end
