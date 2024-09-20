# frozen_string_literal: true

module API
  module Authenticated
    FAILURES = [
      [401, "Unauthorized", Entities::Error]
    ].freeze

    PRODUCES = ["application/json"].freeze
    CONSUMES = ["application/json"].freeze
  end
end
