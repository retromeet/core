# frozen_string_literal: true

require_relative "../../test_helper"

describe API::RodauthMiddleware do
  include SwaggerHelper::TestMethods

  describe "Unauthorized access" do
    it "Calls an API endpoint without a token and gets a 401" do
      get "/api/listing"

      assert_predicate last_response, :unauthorized?
      assert_response_schema_confirm(401)

      expected_response = { error: "UNAUTHORIZED", details: [{ fields: nil, errors: "Missing or invalid authorization token" }] }

      assert_equal expected_response, last_response_json_body
    end

    it "Calls an API endpoint with an invalid token and gets a 401" do
      token_mock = mock
      token_mock.expects(:token).returns("BAD_TOKEN")
      set_authorization_header(token_mock)
      get "/api/listing"

      assert_predicate last_response, :unauthorized?
      assert_response_schema_confirm(401)

      expected_response = { error: "UNAUTHORIZED", details: [{ fields: nil, errors: "Missing or invalid authorization token" }] }

      assert_equal expected_response, last_response_json_body
    end
  end
end
