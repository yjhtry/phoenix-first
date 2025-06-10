defmodule HeadsUp.Incidents.Incident do
  use Ecto.Schema
  import Ecto.Changeset

  schema "incidents" do
    field :name, :string
    field :priority, :integer, default: 1
    field :status, Ecto.Enum, values: [:pending, :resolved, :canceled], default: :pending
    field :description, :string
    field :image_path, :string, default: "/images/placeholder.jpg"

    belongs_to :category, HeadsUp.Categories.Category
    belongs_to :heroic_response, HeadsUp.Responses.Response

    has_many :responses, HeadsUp.Responses.Response

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(incident, attrs) do
    incident
    |> cast(attrs, [
      :name,
      :description,
      :status,
      :priority,
      :image_path,
      :category_id,
      :heroic_response_id
    ])
    |> validate_required([:name, :description, :status, :priority, :image_path, :category_id])
    |> validate_length(:description, min: 10)
    |> validate_inclusion(:priority, 1..3)
    |> assoc_constraint(:category)
  end
end
