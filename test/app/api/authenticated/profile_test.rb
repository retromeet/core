# frozen_string_literal: true

require_relative "../../../test_helper"

describe API::Authenticated::Profile do
  include RackHelper

  describe "get /profile/info" do
    before do
      password = "bogus123"
      hash = BCrypt::Password.create(password, cost: BCrypt::Engine::MIN_COST)
      login = "foo@retromeet.social"
      account_id = Database.connection[:accounts].insert(email: login, status_id: 2)
      Database.connection[:account_password_hashes].insert(id: account_id, password_hash: hash)
      Database.connection[:account_informations].insert(account_id:, display_name: "Foo", created_at: Time.new(2024, 9, 20, 16, 50, 0))
      @auth = login(login:, password:)
    end

    it "has the information expected" do
      expected_response = { display_name: "Foo", created_at: Time.new(2024, 9, 20, 16, 50, 0) }
      authorized_get @auth, "/api/profile/info"
      assert last_response.ok?
      assert_equal expected_response, JSON.parse(last_response.body, symbolize_names: true)
    end
  end
end
