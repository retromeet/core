# frozen_string_literal: true

require_relative "../../../test_helper"

describe API::Authenticated::Profile do
  include RackHelper
  before(:all) do
    # Create a few locations to create accounts around
    @schaerbeek = create(:location, latitude: 50.8676041, longitude: 4.3737121, language: "en", name: "Schaerbeek - Schaarbeek, Brussels-Capital, Belgium", country_code: "be", osm_id: 58_260)
    @etterbeek = create(:location, latitude: 50.8361447, longitude: 4.3861737, language: "en", name: "Etterbeek, 1040 Brussels-Capital, Belgium", country_code: "be", osm_id: 58_252)
    @amsterdam = create(:location, latitude: 52.3730796, longitude: 4.8924534, language: "en", name: "Amsterdam, North Holland, Netherlands", country_code: "nl", osm_id: 271_110)
    @cologne = create(:location, latitude: 50.938361, longitude: 6.959974, language: "en", name: "Cologne, North Rhine-Westphalia, Germany", country_code: "de", osm_id: 62_578)
    @paris = create(:location, latitude: 48.8534951, longitude: 2.3483915, language: "en", name: "Paris, France", country_code: "fr", osm_id: 71_525)

    @login = "foo@retromeet.social"
    @password = "bogus123"
    @account = create(:account, email: @login, password: @password, account_information: { display_name: "Foo", created_at: Time.new(2024, 9, 20, 16, 50, 0), location_id: @schaerbeek.id })
    @etterbeek_account = create(:account, account_information: { display_name: "Etterbeek account", location_id: @etterbeek.id })
    @amsterdam_account = create(:account, account_information: { display_name: "Amsterdam account", location_id: @amsterdam.id })
    @cologne_account = create(:account, account_information: { display_name: "Cologne account", location_id: @cologne.id })
    @paris_account = create(:account, account_information: { display_name: "Paris account", location_id: @paris.id })
  end

  describe "get /listing" do
    before do
      @auth = login(login: @login, password: @password)
      @endpoint = "/api/listing"
    end

    it "With the default distance, gets only the account in Etterbeek" do
      expected_response = { profiles: [] }
      authorized_get @auth, @endpoint

      assert_predicate last_response, :ok?
      assert_equal expected_response, JSON.parse(last_response.body, symbolize_names: true)
    end
  end
end
