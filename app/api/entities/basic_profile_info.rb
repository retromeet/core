# frozen_string_literal: true

module API
  module Entities
    # Represents the profile info entity for the API
    class BasicProfileInfo < Grape::Entity
      format_with(:iso_timestamp) { |date| date&.iso8601 }
      expose :id, documentation: { type: String }
      expose :display_name, documentation: { type: String }
      expose :created_at, format_with: :iso_timestamp, documentation: { type: String }
    end
  end
end
