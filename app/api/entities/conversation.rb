# frozen_string_literal: true

module API
  module Entities
    # Represents a conversation entity for the API
    class Conversation < Grape::Entity
      expose :id, documentation: { type: String }
      expose :other_profile, using: API::Entities::OtherProfileInfo
      expose :created_at, documentation: { type: DateTime }
      expose :last_seen_at, documentation: { type: [NilClass, DateTime] }
    end
  end
end
