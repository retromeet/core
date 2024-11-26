# frozen_string_literal: true

# This module encapsulates the Committee gem to be used in the tests.
# It will produce the Swagger documentation needed for the tests.
module SwaggerHelper
  class RequestMaker
    include RackHelper

    def make_request
      get "/api/swagger_doc"

      JSON.parse(last_response.body)
    end
  end

  class << self
    def prepare!
      oapi_doc = RequestMaker.new.make_request

      # These types are generated by grape-swagger and should not error in the validation
      JsonSchema.configure do |c|
        c.register_format "int32", ->(data) { }
        c.register_format "int64", ->(data) { }
        c.register_format "float", ->(data) { }
      end

      @committee_options = { schema: Committee::Drivers.load_from_data(oapi_doc) }
      # @committee_options[:schema_coverage] = Committee::Test::SchemaCoverage.new(@committee_options[:schema]) # Committee only support oapiv3 for schema coverage, add when https://github.com/ruby-grape/grape-swagger/issues/603 is done
    end

    attr_reader :committee_options
  end

  module TestMethods
    include RackHelper
    include Committee::Test::Methods

    def request_object
      last_request
    end

    def response_data
      [last_response.status, last_response.headers, last_response.body]
    end

    def committee_options
      SwaggerHelper.committee_options
    end
  end
end