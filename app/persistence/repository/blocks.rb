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
        # @return [Integer] the block id
        def block_profile(profile_id:, target_profile_id:)
          raise ProfileNotFound unless profiles.where(id: target_profile_id).get(:id)

          # TODO: (renatolond, 2025-01-08) It seems .returning(:id) is only supported for merge on pg >=17
          # For now doing two operations, but fix to do only one when possible
          merge_join_table = Database.connection
                                     .select(
                                       Sequel.as(Sequel.lit("?::uuid", profile_id), :profile_id),
                                       Sequel.as(Sequel.lit("?::uuid", target_profile_id), :target_profile_id)
                                     )
                                     .as(:u)

          profile_blocks.merge_using(merge_join_table,
                                     Sequel[:profile_blocks][:profile_id] => Sequel[:u][:profile_id],
                                     Sequel[:profile_blocks][:target_profile_id] => Sequel[:u][:target_profile_id])
                        .merge_insert(profile_id:, target_profile_id:)
                        .merge

          profile_blocks.where(profile_id:, target_profile_id:).get(:id)
        end

        # @param profile_id (see .block_profile)
        # @param target_profile_id (see .block_profile)
        # @raise [ProfileNotFound] If +target_profile_id+ is not found in the DB.
        # @return [void]
        def unblock_profile(profile_id:, target_profile_id:)
          raise ProfileNotFound unless profiles.where(id: target_profile_id).get(:id)

          profile_blocks.where(profile_id:, target_profile_id:).delete
        end

        # @param profile_id (see .block_profile)
        # @param target_profile_id (see .block_profile)
        # @return [Integer] the block id
        def block_info(profile_id:, target_profile_id:)
          profile_blocks.where(profile_id:, target_profile_id:).get(:id)
        end
      end
    end
  end
end
