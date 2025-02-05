# frozen_string_literal: true

require_relative "../../test_helper"

describe API::RodauthMiddleware do
  include RackHelper
  before(:all) do
    @login = "foo@retromeet.social"
    @password = "bogus123"
    @account = create(:account, email: @login, password: @password, profile: { display_name: "Foo", created_at: Time.new(2024, 9, 20, 16, 50, 0) })
  end

  describe "/create-account" do
    it "Tests that we refuse accounts without birth date" do
      login = "john@retromeet.info"
      body = { login:, password: Faker::Internet.password }
      assert_difference("Profile.count", 0) do
        json_post "/create-account", body.to_json
      end

      expected_response = { "field-error": ["birth_date", "must be present"], error: "There was an error creating your account" }

      assert_predicate last_response, :unprocessable?
      assert_equal expected_response, JSON.parse(last_response.body, symbolize_names: true)
    end

    it "Tests that we refuse accounts with birth date that can't be parsed" do
      login = "john@retromeet.info"
      body = { login:, password: Faker::Internet.password, birth_date: "2019-99-99" }
      assert_difference("Profile.count", 0) do
        json_post "/create-account", body.to_json
      end

      expected_response = { "field-error": ["birth_date", "must be a valid date"], error: "There was an error creating your account" }

      assert_predicate last_response, :unprocessable?
      assert_equal expected_response, JSON.parse(last_response.body, symbolize_names: true)
    end

    it "Tests that we refuse accounts that are too young" do
      login = "john@retromeet.info"
      body = { login:, password: Faker::Internet.password, birth_date: Date.yesterday }
      assert_difference("Profile.count", 0) do
        json_post "/create-account", body.to_json
      end

      expected_response = { "field-error": ["birth_date", "must be 18-year-old or older"], error: "There was an error creating your account" }

      assert_predicate last_response, :unprocessable?
      assert_equal expected_response, JSON.parse(last_response.body, symbolize_names: true)
    end

    it "Tests that newly created accounts have an associated account information" do
      expected_response = { success: "Your account has been created" }
      login = "john@retromeet.info"
      birth_date = Date.new(Date.today.year - 20, 1, 1)
      body = { login:, password: Faker::Internet.password, birth_date: }
      assert_difference("Profile.count", 1) do
        json_post "/create-account", body.to_json

        assert_predicate last_response, :ok?
      end

      assert_equal expected_response, JSON.parse(last_response.body, symbolize_names: true)
      inserted = Profile.last

      assert_equal "john", inserted.display_name
      assert_equal birth_date, inserted.birth_date
    end
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
