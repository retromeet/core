# frozen_string_literal: true

require_relative "../../test_helper"

describe NominatimClient do
  it "calls nominatim and gets a response" do
    expected_response = [
      { lat: "-22.90173", lon: "-43.2797093", display_name: "Méier, Rio de Janeiro, Região Geográfica Imediata do Rio de Janeiro, Região Metropolitana do Rio de Janeiro, Região Geográfica Intermediária do Rio de Janeiro, Rio de Janeiro, Região Sudeste, Brasil" }
    ]
    stub_request(:get, "https://nominatim.openstreetmap.org/search?featureType=settlement&format=jsonv2&language=en&layer=address&limit=10&q=M%C3%A9ier,%20Rio%20de%20Janeiro")
      .to_return(webfixture_json_file("nominatim.meier"))

    assert_equal expected_response, NominatimClient.search(query: "Méier, Rio de Janeiro", language: "en")
  end
end
