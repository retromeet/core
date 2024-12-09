# frozen_string_literal: true

module API
  module Entities
    # Represents the profile info entity for the API
    class ProfileInfo < OtherProfileInfo
      format_with(:iso_timestamp) { |date| date&.iso8601 }
      unexpose :location_distance
      expose :birth_date, documentation: { type: Date }
      expose :created_at, format_with: :iso_timestamp, documentation: { type: String }
      expose :hide_age, documentation: { type: "boolean" }
    end
  end
end
