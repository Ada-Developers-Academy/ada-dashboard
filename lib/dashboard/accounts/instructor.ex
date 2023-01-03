defmodule Dashboard.Accounts.Instructor do
  use Ecto.Schema
  import Ecto.Changeset

  alias Dashboard.Classes.Class

  schema "instructors" do
    field :background_color, :string
    field :email, :string
    field :external_id, :string
    field :external_provider, :string
    field :name, :string

    many_to_many :classes, Class, join_through: "affinities"

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(instructor, attrs) do
    # TODO: Validate colors
    instructor
    |> cast(attrs, [:name, :email, :external_id, :external_provider, :background_color])
    |> unique_constraint([:external_id, :external_provider])
    |> validate_required([:name, :email, :external_id, :external_provider])
  end
end