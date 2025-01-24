# frozen_string_literal: true

module API
  module Entities
    # Represents standard errors raised by grape
    class Error < Grape::Entity
      expose :error, documentation: { type: String }
      expose :details, using: API::Entities::ErrorDetail, documentation: { is_array: true }
    end
  end
end
