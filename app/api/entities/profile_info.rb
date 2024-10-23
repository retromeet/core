# frozen_string_literal: true

module API
  module Entities
    # Represents the profile info entity for the API
    class ProfileInfo < BasicProfileInfo
      expose :about_me, documentation: { type: String }
      expose :genders, documentation: { type: String, is_array: true }
      expose :orientations, documentation: { type: String, is_array: true }
      expose :languages, documentation: { type: String, is_array: true }
      expose :relationship_status, documentation: { type: String }
      expose :relationship_type, documentation: { type: String }
      expose :tobacco, documentation: { type: String }
      expose :alcohol, documentation: { type: String }
      expose :marijuana, documentation: { type: String }
      expose :other_recreational_drugs, documentation: { type: String }
      expose :pets, documentation: { type: String }
      expose :wants_pets, documentation: { type: String }
      expose :kids, documentation: { type: String }
      expose :wants_kids, documentation: { type: String }
      expose :religion, documentation: { type: String }
      expose :religion_importance, documentation: { type: String }
    end
  end
end
