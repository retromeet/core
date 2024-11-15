# frozen_string_literal: true

require_relative "../../test_helper"

describe NominatimClient do
  it "calls nominatim and gets a response" do
    expected_response = [
      Models::LocationResult.new(latitude: -22.90173, longitude: -43.2797093, display_name: "Méier, Rio de Janeiro, Região Metropolitana do Rio de Janeiro, Brasil", country_code: "br", osm_id: 5_520_336, osm_type: "suburb", language: "en")
    ]
    stub_request(:get, "https://nominatim.openstreetmap.org/search?featureType=settlement&format=jsonv2&language=en&layer=address&limit=10&q=M%C3%A9ier,%20Rio%20de%20Janeiro&addressdetails=1")
      .to_return(webfixture_json_file("nominatim.meier"))

    assert_equal expected_response, NominatimClient.search(query: "Méier, Rio de Janeiro", language: "en")
  end
end
