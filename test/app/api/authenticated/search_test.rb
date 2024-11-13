# frozen_string_literal: true

require_relative "../../../test_helper"

describe API::Authenticated::Search do
  include RackHelper

  before(:all) do
    @login = "foo@retromeet.social"
    @password = "bogus123"
    @account = create(:account, email: @login, password: @password, account_information: { display_name: "Foo", created_at: Time.new(2024, 9, 20, 16, 50, 0) })
  end

  describe "GET /api/search/address" do
    before do
      @endpoint = "/api/search/address"
      @auth = login(login: @login, password: @password)
    end

    it "gets a few search address results" do
      expected_response = [
        { latitude: -22.90173, longitude: -43.2797093, display_name: "Méier, Rio de Janeiro, Região Metropolitana do Rio de Janeiro, Brazil" },
        { latitude: 53.7028752, longitude: 13.9440022, display_name: "Meiersberg, Vorpommern-Greifswald, Mecklenburg-Vorpommern, Germany" },
        { latitude: 51.58844725, longitude: 5.516390104700668, display_name: "Meierijstad, North Brabant, Netherlands" },
        { latitude: 48.432506, longitude: 12.966444, display_name: "Meier, 84347 Pfarrkirchen, Germany" },
        { latitude: 48.417125, longitude: 13.169217, display_name: "Meier, 94137 Bayerbach an der Rott, Germany" }
      ]
      body = {
        query: "Méier"
      }

      stub_request(:get, "https://photon.komoot.io/api?q=M%C3%A9ier&layer=state&layer=county&layer=city&layer=district&limit=10&lang=en")
        .to_return(webfixture_json_file("photon.meier"))

      authorized_post @auth, @endpoint, body.to_json

      assert_predicate last_response, :ok?
      assert_equal expected_response, JSON.parse(last_response.body, symbolize_names: true)
    end
  end
end
