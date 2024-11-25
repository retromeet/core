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
        # @return [Hash{Symbol => Object}] A hash with the recently inserted message
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

          message = messages.returning(Sequel.lit("*")).insert(conversation_id:, sender:, content:).first
          message[:sender] = if message[:sender] == "profile1"
            conversation[:profile1_id]
          else
            conversation[:profile2_id]
          end
          message
        end

        # @param profile_id (see .insert_message)
        # @return [Array<Hash>]
        def find_conversations(profile_id:)
          profile1_query = conversations.where(profile1_id: profile_id)
          profile2_query = conversations.where(profile2_id: profile_id)

          # TODO: (renatolond, 2024-11-20) I think this needs an index to support this query, look into it
          profile1_query.union(profile2_query, from_self: false)
                        .to_a
        end

        # @param profile_id (see .insert_message)
        # @param conversation_id (see .insert_message)
        # @return [Array<Hash>]
        def find_conversation(profile_id:, conversation_id:)
          conversations.where(profile1_id: profile_id)
                       .or(profile2_id: profile_id)
                       .where(id: conversation_id)
                       .first
        end

        # @param profile_id (see .insert_message)
        # @param conversation_id (see .insert_message)
        # @return [void]
        def update_view_time(conversation_id:, profile_id:)
          conversation = conversations.where(id: conversation_id).first
          raise ConversationNotFound, "Conversation with given id was not found" if conversation.nil?

          sender = if profile_id == conversation[:profile1_id]
            :profile1
          elsif profile_id == conversation[:profile2_id]
            :profile2
          else
            raise ArgumentError, "profile_id is not part of this conversation"
          end

          conversations.where(id: conversation_id).update("#{sender}_last_seen_at": Sequel.function(:statement_timestamp))
        end

        # @param conversation_id (see .insert_message)
        # @param sender [String] Either "profile1" or "profile2", will be used to check if there's messages from that user
        # @param since [DateTime] Time to check against
        # @return [nil,Content] Returns nil if there's no messages, or a single message content if there are
        def new_messages(conversation_id:, sender:, since:)
          since ||= Sequel.function(:to_timestamp, 0)
          messages.where(conversation_id:, sender:)
                  .where { sent_at > since }
                  .order(Sequel[:sent_at].desc)
                  .get(:content)
        end

        # Returns the last 20 messages from a conversation
        # Only max_id or min_id should be passed, if both are passed the response will be empty.
        #
        # @param conversation_id (see .insert_message)
        # @param max_id [Integer, nil] Used for pagination, will only look for messages with id smaller than the given one
        # @param min_id [Integer, nil] Used for pagination, will only look for messages with id bigger than the given one
        # @return [Array<Hash>]
        def find_messages(conversation_id:, max_id: nil, min_id: nil)
          # TODO: (renatolond, 2024-11-20) I think this needs an index to support this query, look into it
          m = messages.join(:conversations, id: conversation_id)
                      .select_all(:messages)
                      .select_append(Sequel.case({ "profile1" => :profile1_id }, :profile2_id, :sender).as(:sender))
                      .where(conversation_id:)
                      .order(Sequel[:id].desc)
                      .limit(20)

          m = m.where { Sequel[:messages][:id] < max_id } if max_id
          m = m.where { Sequel[:messages][:id] > min_id } if min_id
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
