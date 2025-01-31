# frozen_string_literal: true

module API
  module Entities
    # Represents standard errors raised by grape
    class ErrorDetail < Grape::Entity
      expose :fields, documentation: { type: String, is_array: true }
      expose :errors, documentation: { type: String, is_array: true }
    end
  end
end
