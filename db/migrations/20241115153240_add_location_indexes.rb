# frozen_string_literal: true

Sequel.migration do
  change do
    add_index :locations, :geom, type: :gist
    add_index :locations, Sequel.lit("geography(geom)"), type: :gist, name: :locations_geography_geom_index
  end
end
