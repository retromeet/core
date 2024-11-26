# frozen_string_literal: true

module API
  module Entities
    # Represents a collection of conversations
    class Messages < Grape::Entity
      present_collection true
      expose :items, as: "messages", using: API::Entities::Message, documentation: { is_array: true }
    end
  end
end
