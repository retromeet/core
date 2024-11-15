# frozen_string_literal: true

module Persistence
  module Repository
    # Contains database logic around locations
    module Location
      class << self
        # @param location_result [Models::LocationResult]
        def upsert_location(location_result:)
          display_name_json = Sequel.pg_jsonb_wrap({ location_result.language => location_result.display_name })
          geom = Sequel.lit("POINT(#{location_result.longitude}, #{location_result.latitude})::geometry")
          # TODO: (renatolond, 2024-11-14) It seems .returning(:id) is only supported for merge on pg >=17
          # For now doing two operations, but fix to do only one when possible

          locations.merge_using(Database.connection.select(Sequel.as(location_result.osm_id, :osm_id)).as(:u), Sequel[:locations][:osm_id] => Sequel[:u][:osm_id])
                   .merge_insert(osm_id: location_result.osm_id, display_name: display_name_json, country_code: location_result.country_code, geom:)
                   .merge_update(Sequel.pg_jsonb_op(:display_name)[location_result.language] => Sequel.pg_jsonb_wrap(location_result.display_name), country_code: location_result.country_code, geom:)
                   .merge

          locations.where(osm_id: location_result.osm_id).get(:id)
        end

        private

          # @return [Sequel::Postgres::Dataset]
          def locations
            Database.connection[:locations]
          end
      end
    end
  end
end
