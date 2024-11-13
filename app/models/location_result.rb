# frozen_string_literal: true

module Models
  LocationResult = Data.define(:latitude, :longitude, :display_name, :osm_id, :country_code)
end
