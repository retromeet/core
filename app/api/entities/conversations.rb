# frozen_string_literal: true

module API
  module Entities
    # Represents a collection of conversations
    class Conversations < Grape::Entity
      present_collection true
      expose :items, as: "conversations", using: API::Entities::Conversation, documentation: { is_array: true }
    end
  end
end
