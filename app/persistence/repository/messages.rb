# frozen_string_literal: true

module Persistence
  module Repository
    # Contains database logic around locations
    module Messages
      class << self
        # Either finds an existing conversation or creates a new one between the two given profiles
        # Order does not matter, will always make sure the profiles are in the same order.
        #
        # @param profile1_id [String] The uuid for a profile
        # @param profile2_id [String] The uuid for a profile
        def upsert_conversation(profile1_id:, profile2_id:)
          raise ArgumentError, "Profiles cannot be the same" if profile1_id == profile2_id

          profile1_id, profile2_id = [profile1_id, profile2_id].sort

          # TODO: (renatolond, 2024-11-14) It seems .returning(:id) is only supported for merge on pg >=17
          # For now doing two operations, but fix to do only one when possible

          conversations.merge_using(Database.connection.select(Sequel.as(Sequel.lit("?::uuid", profile1_id), :profile1_id), Sequel.as(Sequel.lit("?::uuid", profile2_id), :profile2_id)).as(:u), Sequel[:conversations][:profile1_id] => Sequel[:u][:profile1_id], Sequel[:conversations][:profile2_id] => Sequel[:u][:profile2_id])
                       .merge_insert(profile1_id:, profile2_id:)
                       .merge

          conversations.where(profile1_id:, profile2_id:).get(:id)
        end

        private

          # @return [Sequel::Postgres::Dataset]
          def conversations
            Database.connection[:conversations]
          end

          # @return [Sequel::Postgres::Dataset]
          def messages
            Database.connection[:messages]
          end
      end
    end
  end
end
