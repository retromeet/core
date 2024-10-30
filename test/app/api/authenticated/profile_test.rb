# frozen_string_literal: true

require_relative "../../../test_helper"

describe API::Authenticated::Profile do
  include RackHelper

  describe "get /profile/info" do
    before do
      login = "foo@retromeet.social"
      password = "bogus123"
      create(:account, email: login, password:, account_information: { display_name: "Foo", created_at: Time.new(2024, 9, 20, 16, 50, 0) })
      @auth = login(login:, password:)
    end

    it "has the information expected" do
      expected_response = { display_name: "Foo", created_at: Time.new(2024, 9, 20, 16, 50, 0) }
      authorized_get @auth, "/api/profile/info"

      assert_predicate last_response, :ok?
      assert_equal expected_response, JSON.parse(last_response.body, symbolize_names: true)
    end
  end

  describe "get /profile/complete" do
    before do
      @endpoint = "/api/profile/complete"

      login = "foo@retromeet.social"
      password = "bogus123"
      @account = create(:account, email: login, password:, account_information: { display_name: "Foo", created_at: Time.new(2024, 9, 20, 16, 50, 0) })
      @auth = login(login:, password:)
    end

    require "date"
    it "gets the user information" do
      account_information = @account.account_information
      expected_response = {
        about_me: account_information.about_me,
        created_at: account_information.created_at.iso8601,
        birth_date: account_information.birth_date.to_s,
        genders: account_information.genders,
        orientations: account_information.orientations,
        languages: account_information.languages,
        relationship_status: account_information.relationship_status,
        relationship_type: account_information.relationship_type,
        tobacco: account_information.tobacco,
        marijuana: account_information.marijuana,
        alcohol: account_information.alcohol,
        other_recreational_drugs: account_information.other_recreational_drugs,
        pets: account_information.pets,
        wants_pets: account_information.wants_pets,
        kids: account_information.kids,
        wants_kids: account_information.wants_kids,
        religion: account_information.religion,
        religion_importance: account_information.religion_importance,
        display_name: account_information.display_name
      }
      authorized_get @auth, @endpoint

      assert_predicate last_response, :ok?
      assert_equal expected_response, JSON.parse(last_response.body, symbolize_names: true)
    end
  end
end
