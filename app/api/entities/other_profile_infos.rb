# frozen_string_literal: true

module API
  module Entities
    # represents a collection of other users' profiles
    class OtherProfileInfos < Grape::Entity
      present_collection true
      expose :items, as: "profiles", using: API::Entities::OtherProfileInfo, documentation: { is_array: true, required: false }
    end
  end
end
