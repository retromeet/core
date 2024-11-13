# frozen_string_literal: true

require_relative "../../test_helper"

describe PhotonClient do
  it "calls photon and gets a response" do
    expected_response = [
      { latitude: -22.90173, longitude: -43.2797093, display_name: "Méier, Rio de Janeiro, Região Metropolitana do Rio de Janeiro, Brazil" },
      { latitude: 53.7028752, longitude: 13.9440022, display_name: "Meiersberg, Vorpommern-Greifswald, Mecklenburg-Vorpommern, Germany" },
      { latitude: 51.58844725, longitude: 5.516390104700668, display_name: "Meierijstad, North Brabant, Netherlands" },
      { latitude: 48.432506, longitude: 12.966444, display_name: "Meier, 84347 Pfarrkirchen, Germany" },
      { latitude: 48.417125, longitude: 13.169217, display_name: "Meier, 94137 Bayerbach an der Rott, Germany" }
    ]
    stub_request(:get, "https://photon.komoot.io/api?q=M%C3%A9ier&layer=state&layer=county&layer=city&layer=district&limit=10&lang=en")
      .to_return(webfixture_json_file("photon.meier"))

    assert_equal expected_response, PhotonClient.search(query: "Méier", language: "en")
  end
end
