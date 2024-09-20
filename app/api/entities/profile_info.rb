# frozen_string_literal: true

module API
  module Entities
    # Represents the profile info entity for the API
    class ProfileInfo < Grape::Entity
      format_with(:iso_timestamp, &:iso8601)
      expose :display_name, documentation: { type: String }
      expose :created_at, format_with: :iso_timestamp, documentation: { type: String }
    end
  end
end
