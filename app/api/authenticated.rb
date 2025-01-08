# frozen_string_literal: true

module API
  module Authenticated
    FAILURES = {
      400 => [400, "Bad request", Entities::Error].freeze,
      401 => [401, "Unauthorized", Entities::Error].freeze,
      404 => [404, "Not found", Entities::Error].freeze,
      422 => [422, "Unprocessable entity", Entities::Error].freeze,
      500 => [500, "Server error", Entities::Error].freeze
    }.freeze

    PRODUCES = ["application/json"].freeze
    CONSUMES = ["application/json"].freeze

    class << self
      # This is a helper method that will build an array to be used for the Swagger doucumentation
      # It convert the codes passed on to it to the array.
      # Any codes need to be in the +FAILURES+ constant.
      # @param codes [Array<Integer>] An ordered list of codes to be converted. If the list is not sorted the method will also work, but will create a new list and cache it
      # @return [Array<List<Integer, String, Class>>]
      def failures(codes = [401, 500])
        @failures ||= {}
        @failures[codes] ||= begin
          f = codes.map do |code|
            raise ArgumentError, "#{code} needs to be defined in the FAILURES constant" if FAILURES[code].nil?

            FAILURES[code]
          end
          f.freeze
        end
      end
    end
  end
end
