# frozen_string_literal: true

require_relative "../../test_helper"

describe PhotonClient do
  it "calls photon and gets a response" do
    expected_response = [
      { lat: -22.90173, lon: -43.2797093, display_name: "Méier, Rio de Janeiro, Região Metropolitana do Rio de Janeiro, Brazil" },
      { lat: 53.7028752, lon: 13.9440022, display_name: "Meiersberg, Vorpommern-Greifswald, Mecklenburg-Vorpommern, Germany" },
      { lat: 51.58844725, lon: 5.516390104700668, display_name: "Meierijstad, North Brabant, Netherlands" },
      { lat: 48.432506, lon: 12.966444, display_name: "Meier, 84347 Pfarrkirchen, Germany" },
      { lat: 48.417125, lon: 13.169217, display_name: "Meier, 94137 Bayerbach an der Rott, Germany" }
    ]
    stub_request(:get, "https://photon.komoot.io/api?q=M%C3%A9ier&layer=state&layer=county&layer=city&layer=district&limit=10&lang=en")
      .to_return(webfixture_json_file("photon.meier"))

    assert_equal expected_response, PhotonClient.search(query: "Méier", language: "en")
  end
end
