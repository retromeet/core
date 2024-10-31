# frozen_string_literal: true

require_relative "../../test_helper"

describe NominatimClient do
  it "calls nominatim and gets a response" do
    expected_response = []
    stub_request(:get, "https://nominatim.openstreetmap.org/search?featureType=settlement&format=jsonv2&language=en&layer=address&limit=10&q=M%C3%A9ier,%20Rio%20de%20Janeiro")
      .to_return(webfixture_json_file("nominatim.meier"))

    assert_equal expected_response, NominatimClient.search(query: "Méier, Rio de Janeiro", language: "en")
  end
end
