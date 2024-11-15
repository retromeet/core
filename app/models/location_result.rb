# frozen_string_literal: true

module Models
  LocationResult = Data.define(:latitude, :longitude, :display_name, :osm_id, :osm_type, :country_code, :language) do
    def initialize(latitude:, longitude:, display_name:, osm_id:, osm_type:, country_code:, language:)
      country_code = country_code.downcase
      super
    end
  end
end
