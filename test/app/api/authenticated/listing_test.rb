# frozen_string_literal: true

require_relative "../../../test_helper"

describe API::Authenticated::Profile do
  include SwaggerHelper::TestMethods
  before(:all) do
    # Create a few locations to create accounts around
    @schaerbeek = create(:location, latitude: 50.8676041, longitude: 4.3737121, language: "en", name: "Schaerbeek - Schaarbeek, Brussels-Capital, Belgium", country_code: "be", osm_id: 58_260)
    @etterbeek = create(:location, latitude: 50.8361447, longitude: 4.3861737, language: "en", name: "Etterbeek, 1040 Brussels-Capital, Belgium", country_code: "be", osm_id: 58_252)
    @amsterdam = create(:location, latitude: 52.3730796, longitude: 4.8924534, language: "en", name: "Amsterdam, North Holland, Netherlands", country_code: "nl", osm_id: 271_110)
    @cologne = create(:location, latitude: 50.938361, longitude: 6.959974, language: "en", name: "Cologne, North Rhine-Westphalia, Germany", country_code: "de", osm_id: 62_578)
    @paris = create(:location, latitude: 48.8534951, longitude: 2.3483915, language: "en", name: "Paris, France", country_code: "fr", osm_id: 71_525)

    @login = "foo@retromeet.social"
    @password = "bogus123"
    @account = create(:account, email: @login, password: @password, profile: { display_name: "Foo", created_at: Time.new(2024, 9, 20, 16, 50, 0), location_id: @schaerbeek.id })
    set_oauth_grant_with_token(oauth_grant_with_token(@account))
    @etterbeek_account = create(:account, profile: { display_name: "Etterbeek account", location_id: @etterbeek.id, birth_date: Date.new(1987, 1, 1) })
    @amsterdam_account = create(:account, profile: { display_name: "Amsterdam account", location_id: @amsterdam.id, birth_date: Date.new(1997, 1, 1) })
    @cologne_account = create(:account, profile: { display_name: "Cologne account", location_id: @cologne.id, birth_date: Date.new(2004, 1, 1) })
    @paris_account = create(:account, profile: { display_name: "Paris account", location_id: @paris.id, birth_date: Date.new(2004, 6, 1) })

    @etterbeek_profile = {
      id: @etterbeek_account.profile.id,
      display_name: "Etterbeek account",
      genders: @etterbeek_account.profile.genders,
      orientations: @etterbeek_account.profile.orientations,
      relationship_status: @etterbeek_account.profile.relationship_status,
      location_display_name: @etterbeek.display_name.transform_keys(&:to_sym),
      location_distance: 3.60585778981352,
      age: AgeHelper.age_from_date(@etterbeek_account.profile.birth_date)
    }
    @amsterdam_profile = {
      id: @amsterdam_account.profile.id,
      display_name: "Amsterdam account",
      genders: @amsterdam_account.profile.genders,
      orientations: @amsterdam_account.profile.orientations,
      relationship_status: @amsterdam_account.profile.relationship_status,
      location_display_name: @amsterdam.display_name.transform_keys(&:to_sym),
      location_distance: 171.18810403107398,
      age: AgeHelper.age_from_date(@amsterdam_account.profile.birth_date)
    }
    @cologne_profile = {
      id: @cologne_account.profile.id,
      display_name: "Cologne account",
      genders: @cologne_account.profile.genders,
      orientations: @cologne_account.profile.orientations,
      relationship_status: @cologne_account.profile.relationship_status,
      location_display_name: @cologne.display_name.transform_keys(&:to_sym),
      location_distance: 181.5191324427601,
      age: AgeHelper.age_from_date(@cologne_account.profile.birth_date)
    }
    @paris_profile = {
      id: @paris_account.profile.id,
      display_name: "Paris account",
      genders: @paris_account.profile.genders,
      orientations: @paris_account.profile.orientations,
      relationship_status: @paris_account.profile.relationship_status,
      location_display_name: @paris.display_name.transform_keys(&:to_sym),
      location_distance: 266.8743807484807,
      age: AgeHelper.age_from_date(@paris_account.profile.birth_date)
    }
  end

  describe "get /listing" do
    before do
      @endpoint = "/api/listing"
    end

    it "With the default distance, gets only the account in Etterbeek" do
      expected_response = { profiles: [@etterbeek_profile] }
      authorized_get @endpoint

      assert_predicate last_response, :ok?
      assert_schema_conform(200)
      parsed_response = JSON.parse(last_response.body, symbolize_names: true)

      assert_equal 1, parsed_response[:profiles].size
      assert_equal expected_response, parsed_response
    end

    it "With 200 kms, gets a few profiles around" do
      expected_response = { profiles: [@etterbeek_profile, @amsterdam_profile, @cologne_profile] }
      authorized_get @endpoint, { max_distance: 200 }

      assert_predicate last_response, :ok?
      assert_schema_conform(200)
      parsed_response = JSON.parse(last_response.body, symbolize_names: true)

      assert_equal 3, parsed_response[:profiles].size
      assert_equal expected_response, parsed_response
    end

    it "With 400 kms, gets all profiles" do
      expected_response = { profiles: [@etterbeek_profile, @amsterdam_profile, @cologne_profile, @paris_profile] }
      authorized_get @endpoint, { max_distance: 400 }

      assert_predicate last_response, :ok?
      assert_schema_conform(200)
      parsed_response = JSON.parse(last_response.body, symbolize_names: true)

      assert_equal 4, parsed_response[:profiles].size
      assert_equal expected_response, parsed_response
    end

    it "With the default distance, it does not show a blocked profile" do
      create(:profile_block, profile: @account.profile, target_profile: @etterbeek_account.profile)
      expected_response = { profiles: [] }
      authorized_get @endpoint

      assert_predicate last_response, :ok?
      assert_schema_conform(200)
      parsed_response = JSON.parse(last_response.body, symbolize_names: true)

      assert_equal 0, parsed_response[:profiles].size
      assert_equal expected_response, parsed_response
    end

    it "Gets a bad request with more than 400 distance" do
      authorized_get @endpoint, { max_distance: 401 }

      assert_predicate last_response, :bad_request?
      assert_response_schema_confirm(400)

      expected_response = {
        error: "VALIDATION_ERROR",
        details: [
          { fields: ["max_distance"], errors: ["does not have a valid value"] }
        ]
      }

      assert_equal expected_response, JSON.parse(last_response.body, symbolize_names: true)
    end
  end
end
