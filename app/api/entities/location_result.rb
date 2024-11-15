# frozen_string_literal: true

module API
  module Entities
    # Represents the profile info entity for the API
    class LocationResult < Grape::Entity
      expose :latitude, documentation: { type: Float }
      expose :longitude, documentation: { type: Float }
      expose :display_name, documentation: { type: String }
      expose :osm_id, documentation: { type: Integer }
      expose :osm_type, documentation: { type: String }
    end
  end
end
