# frozen_string_literal: true

module Persistence
  module Repository
    # Contains database logic around profile blocks
    module Blocks
      extend Datasets
      ProfileNotFound = Class.new(StandardError)

      class << self
        # @param profile_id [String] A uuid for the profile creating the block
        # @param target_profile_id [String] A uuid for the profile being targeted by the block, will be searched in the DB
        # @raise [ProfileNotFound] If +target_profile_id+ is not found in the DB.
        # @return [void]
        def block_profile(profile_id:, target_profile_id:)
          raise ProfileNotFound unless profiles.where(id: target_profile_id).get(:id)

          profile_blocks.insert(profile_id:, target_profile_id:)
        end
      end
    end
  end
end
