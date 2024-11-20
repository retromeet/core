# frozen_string_literal: true

module Persistence
  module Repository
    # Contains database logic around locations
    module Messages
      ConversationNotFound = Class.new(StandardError)

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

          merge_join_table = Database.connection
                                     .select(
                                       Sequel.as(Sequel.lit("?::uuid", profile1_id), :profile1_id),
                                       Sequel.as(Sequel.lit("?::uuid", profile2_id), :profile2_id)
                                     )
                                     .as(:u)

          conversations.merge_using(merge_join_table,
                                    Sequel[:conversations][:profile1_id] => Sequel[:u][:profile1_id],
                                    Sequel[:conversations][:profile2_id] => Sequel[:u][:profile2_id])
                       .merge_insert(profile1_id:, profile2_id:)
                       .merge

          conversations.where(profile1_id:, profile2_id:).get(:id)
        end

        # @param conversation_id [String] The uuid for the conversation
        # @param profile_id [String] The uuid for a profile
        # @param content [String] The message contents, will be save as-is
        # @raise [ArgumentError] If the profile does not belong to the conversation
        # @raise [ConversationNotFound] If there's no conversation with the given id
        # @return [Integer] The new message id
        def insert_message(conversation_id:, profile_id:, content:)
          conversation = conversations.where(id: conversation_id).first
          raise ConversationNotFound, "Conversation with given id was not found" if conversation.nil?

          sender = if profile_id == conversation[:profile1_id]
            "profile1"
          elsif profile_id == conversation[:profile2_id]
            "profile2"
          else
            raise ArgumentError, "profile_id is not part of this conversation"
          end

          messages.insert(conversation_id:, sender:, content:)
        end

        # @param profile_id (see .insert_message)
        # @return [Array<Hash>]
        def find_conversations(profile_id:)
          # TODO: (renatolond, 2024-11-20) I think this needs an index to support this query, look into it
          conversations.where(profile1_id: profile_id)
                       .union(conversations.where(profile2_id: profile_id), from_self: false)
                       .to_a
        end

        # Returns the last 20 messages from a conversation
        # @param conversation_id (see .insert_message)
        # @param max_id [Integer, nil] Used for pagination, will only look for messages with id smaller than the given one
        # @return [Array<Hash>]
        def find_messages(conversation_id:, max_id: nil)
          # TODO: (renatolond, 2024-11-20) I think this needs an index to support this query, look into it
          m = messages.where(conversation_id:)
                      .order(Sequel[:id].desc)
                      .limit(20)

          m = m.where { id < max_id } if max_id
          m.to_a
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
