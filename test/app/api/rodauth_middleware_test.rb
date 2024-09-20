# frozen_string_literal: true

require_relative "../../test_helper"

describe API::RodauthMiddleware do
  include RackHelper

  it "Tests that newly created accounts have an associated account information" do
    expected_response = { success: "Your account has been created" }
    header "content-type", "application/json"
    login = "john@retromeet.info"
    assert_difference("Database.connection[:account_informations].count", 1) do
      post "/create-account", { login:, password: Faker::Internet.password }.to_json
      assert last_response.ok?
      assert_equal expected_response, JSON.parse(last_response.body, symbolize_names: true)
    end
    inserted = Database.connection[:account_informations].order(:account_id).last
    assert_equal "john", inserted[:display_name]
  end
end
