# frozen_string_literal: true

module API
  module Entities
    # Represents a conversation entity for the API
    class Conversation < Grape::Entity
      format_with(:iso_timestamp) { |date| date&.iso8601 }
      expose :id, documentation: { type: String }
      expose :other_profile, using: API::Entities::OtherProfileInfo
      expose :created_at, format_with: :iso_timestamp, documentation: { type: DateTime }
      expose :last_seen_at, format_with: :iso_timestamp, documentation: { type: [DateTime, NilClass] }
      expose :new_messages, as: :new_messages_preview, documentation: { type: String }, expose_nil: false
    end
  end
end
