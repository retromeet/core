# frozen_string_literal: true

module API
  module Entities
    # Represents a conversation entity for the API
    class Message < Grape::Entity
      format_with(:iso_timestamp) { |date| date&.iso8601 }
      expose :id, documentation: { type: Integer }
      expose :sender, documentation: { type: String }
      expose :sent_at, format_with: :iso_timestamp, documentation: { type: DateTime }
      expose :content, documentation: { type: String }
    end
  end
end
