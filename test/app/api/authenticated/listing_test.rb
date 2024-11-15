# frozen_string_literal: true

require_relative "../../../test_helper"

describe API::Authenticated::Profile do
  include RackHelper
  before(:all) do
    @login = "foo@retromeet.social"
    @password = "bogus123"
    @account = create(:account, email: @login, password: @password, account_information: { display_name: "Foo", created_at: Time.new(2024, 9, 20, 16, 50, 0) })
  end

  describe "get /listing" do
    before do
      @auth = login(login: @login, password: @password)
      @endpoint = "/api/listing"
    end

    it "Gets a list of the nearest profiles in order" do
      expected_response = { display_name: "Foo", created_at: Time.new(2024, 9, 20, 16, 50, 0) }
      authorized_get @auth, "/api/profile/info"

      assert_predicate last_response, :ok?
      assert_equal expected_response, JSON.parse(last_response.body, symbolize_names: true)
    end
  end
end
