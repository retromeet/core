# frozen_string_literal: true

require_relative "../../test_helper"

describe API::RodauthMiddleware do
  include RackHelper
  before(:all) do
    @login = "foo@retromeet.social"
    @password = "bogus123"
    @account = create(:account, email: @login, password: @password, profile: { display_name: "Foo", created_at: Time.new(2024, 9, 20, 16, 50, 0) })
  end

  it "Tests that newly created accounts have an associated account information" do
    expected_response = { success: "Your account has been created" }
    login = "john@retromeet.info"
    body = { login:, password: Faker::Internet.password }
    assert_difference("Profile.count", 1) do
      json_post "/create-account", body.to_json
    end

    assert_predicate last_response, :ok?
    assert_equal expected_response, JSON.parse(last_response.body, symbolize_names: true)
    inserted = Database.connection[:profiles].order(:account_id).last

    assert_equal "john", inserted[:display_name]
  end

  describe "/login" do
    it "logs in with the wrong password and gets a proper error" do
      body = { login: @login, password: "nonono" }
      json_post "/login", body.to_json

      expected_response = { "field-error": ["password", "invalid password"], error: "There was an error logging in" }

      assert_predicate last_response, :unauthorized?
      assert_equal expected_response, JSON.parse(last_response.body, symbolize_names: true)
    end

    it "logs in with the wrong login and gets a proper error" do
      body = { login: "ohno@no.no", password: "nonono" }
      json_post "/login", body.to_json

      expected_response = { "field-error": ["login", "no matching login"], error: "There was an error logging in" }

      assert_predicate last_response, :unauthorized?
      assert_equal expected_response, JSON.parse(last_response.body, symbolize_names: true)
    end
  end
end
