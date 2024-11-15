# frozen_string_literal: true

require_relative "../../test_helper"

describe PhotonClient do
  it "calls photon and gets a response" do
    expected_response = [
      Models::LocationResult.new(latitude: -22.90173, longitude: -43.2797093, display_name: "Méier, Rio de Janeiro, Região Metropolitana do Rio de Janeiro, Brazil", country_code: "BR", osm_id: 5_520_336, osm_type: "suburb", language: "en"),
      Models::LocationResult.new(latitude: 53.7028752, longitude: 13.9440022, display_name: "Meiersberg, Vorpommern-Greifswald, Mecklenburg-Vorpommern, Germany", country_code: "DE", osm_id: 1_408_068, osm_type: "village", language: "en"),
      Models::LocationResult.new(latitude: 51.58844725, longitude: 5.516390104700668, display_name: "Meierijstad, North Brabant, Netherlands", country_code: "NL", osm_id: 6_838_008, osm_type: "administrative", language: "en"),
      Models::LocationResult.new(latitude: 48.432506, longitude: 12.966444, display_name: "Meier, 84347 Pfarrkirchen, Germany", country_code: "DE", osm_id: 3_204_975_107, osm_type: "hamlet", language: "en"),
      Models::LocationResult.new(latitude: 48.417125, longitude: 13.169217, display_name: "Meier, 94137 Bayerbach an der Rott, Germany", country_code: "DE", osm_id: 888_754_893, osm_type: "hamlet", language: "en")
    ]
    stub_request(:get, "https://photon.komoot.io/api?q=M%C3%A9ier&layer=state&layer=county&layer=city&layer=district&limit=10&lang=en")
      .to_return(webfixture_json_file("photon.meier"))

    assert_equal expected_response, PhotonClient.search(query: "Méier", language: "en")
  end
end
