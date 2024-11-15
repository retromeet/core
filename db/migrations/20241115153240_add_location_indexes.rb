# frozen_string_literal: true

Sequel.migration do
  change do
    add_index :locations, :geom, type: :gist # rubocop:disable Sequel:ConcurrentIndex
    add_index :locations, Sequel.lit("geography(geom)"), type: :gist, name: :locations_geography_geom_index # rubocop:disable Sequel:ConcurrentIndex
  end
end
