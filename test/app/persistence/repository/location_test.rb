# frozen_string_literal: true

require_relative "../../../test_helper"

describe Persistence::Repository::Location do
  describe ".upsert_location" do
    it "calls with a location that does not exist yet and it gets inserted" do
      location_result = Models::LocationResult.new(latitude: -22.90173, longitude: -43.2797093, display_name: "Méier, Rio de Janeiro, Região Metropolitana do Rio de Janeiro, Brazil", country_code: "BR", osm_id: 5_520_336, osm_type: "foo", language: "en")

      assert_difference "Location.count", 1 do
        Persistence::Repository::Location.upsert_location(location_result:)
      end
      inserted_location = Location.find(osm_id: location_result.osm_id)
      expected_display_name = { location_result.language => location_result.display_name }

      assert_equal expected_display_name, inserted_location.display_name
      assert_equal location_result.country_code, inserted_location.country_code

      expected_geom = format("SRID=4326;POINT(%<longitude>.1f %<latitude>.1f)", longitude: location_result.longitude, latitude: location_result.latitude)

      geom = Database.connection[:locations].where(osm_id: location_result.osm_id).get(Sequel.function(:ST_AsEWKT, :geom, 1))

      assert_equal expected_geom, geom
    end

    it "calls with a location that already exists and things get properly upserted" do
      location_result = Models::LocationResult.new(latitude: -22.90173, longitude: -43.2797093, display_name: "Méier, Rio de Janeiro, Região Metropolitana do Rio de Janeiro, Brasil", country_code: "BR", osm_id: 5_520_336, osm_type: "foo", language: "pt")
      create(:location, osm_id: location_result.osm_id, latitude: location_result.latitude, longitude: location_result.longitude, display_name: { en: "Méier, Rio de Janeiro, Região Metropolitana do Rio de Janeiro, Brazil" }, country_code: "br")

      assert_difference "Location.count", 0 do
        Persistence::Repository::Location.upsert_location(location_result:)
      end
      inserted_location = Location.find(osm_id: location_result.osm_id)
      expected_display_name = { "en" => "Méier, Rio de Janeiro, Região Metropolitana do Rio de Janeiro, Brazil", location_result.language => location_result.display_name }

      assert_equal expected_display_name, inserted_location.display_name
      assert_equal location_result.country_code, inserted_location.country_code

      expected_geom = format("SRID=4326;POINT(%<longitude>.1f %<latitude>.1f)", longitude: location_result.longitude, latitude: location_result.latitude)

      geom = Database.connection[:locations].where(osm_id: location_result.osm_id).get(Sequel.function(:ST_AsEWKT, :geom, 1))

      assert_equal expected_geom, geom
    end
  end
end
