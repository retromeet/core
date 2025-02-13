# frozen_string_literal: true

module API
  module Authenticated
    # This class contains any profile-related endpoints
    class Conversations < Grape::API
      namespace :conversations do
        helpers do
          # @param conversation [Hash{Symbol => Object}] A hash containing conversation information, will be modified!
          # @return [Hash{Symbol => Object}] The modified conversation object
          def filter_conversation_for_current_profile!(conversation)
            sender = nil # This is used to see if there are new messages in the conversation to be notified
            if conversation[:profile1_id] == @logged_in_profile_id
              sender = "profile2"
              conversation[:other_profile_id] = conversation.delete(:profile2_id)
              conversation[:last_seen_at] = conversation.delete(:profile1_last_seen_at)
              conversation.delete(:profile1_id)
              conversation.delete(:profile2_last_seen_at)
            elsif conversation[:profile2_id] == @logged_in_profile_id
              sender = "profile1"
              conversation[:other_profile_id] = conversation.delete(:profile1_id)
              conversation[:last_seen_at] = conversation.delete(:profile2_last_seen_at)
              conversation.delete(:profile2_id)
              conversation.delete(:profile1_last_seen_at)
            end
            conversation[:new_messages] = Persistence::Repository::Messages.new_messages(conversation_id: conversation[:id], sender:, since: conversation[:last_seen_at])
            conversation[:other_profile] = Persistence::Repository::Account.profile_info(id: conversation[:other_profile_id])
            conversation
          end
        end

        desc "Returns the conversations that the logged-in has going on",
             success: { model: Entities::Conversations, message: "A list of conversations" },
             failure: Authenticated.failures([400, 401, 500]),
             produces: Authenticated::PRODUCES,
             consumes: Authenticated::CONSUMES
        get "/" do
          conversations = Persistence::Repository::Messages.find_conversations(profile_id: @logged_in_profile_id)
          conversations.each do |conversation|
            filter_conversation_for_current_profile!(conversation)
          end
          present conversations, with: Entities::Conversations
        end

        desc "Creates a conversation with another user.",
             success: { model: Entities::Conversations, message: "A list of conversations" },
             failure: Authenticated.failures([400, 401, 404, 500]),
             produces: Authenticated::PRODUCES,
             consumes: Authenticated::CONSUMES
        params do
          requires :other_profile_id, type: String, documentation: { format: :uuid }, regexp: Utils::UUID7_RE
        end
        post "/" do
          conversation = Persistence::Repository::Messages.upsert_conversation(profile1_id: @logged_in_profile_id, profile2_id: params[:other_profile_id])
          conversation[:other_profile] = Persistence::Repository::Account.profile_info(id: params[:other_profile_id])
          present conversation, with: Entities::Conversation
        end

        params do
          requires :conversation_id, type: String, documentation: { format: :uuid }, regexp: Utils::UUID7_RE
        end
        namespace ":conversation_id" do
          desc "Returns a single conversation for the logged-in user",
               success: { model: Entities::Conversation, message: "A conversation" },
               failure: Authenticated.failures([400, 401, 500]),
               produces: Authenticated::PRODUCES,
               consumes: Authenticated::CONSUMES
          get "/" do
            conversation = Persistence::Repository::Messages.find_conversation(profile_id: @logged_in_profile_id, conversation_id: params[:conversation_id])

            filter_conversation_for_current_profile!(conversation)

            present conversation, with: Entities::Conversation
          end

          desc "Updates the last_seen_at for the current logged-in user",
               success: [{ code: 204, message: "Time was updated" }],
               failure: Authenticated.failures([400, 401, 500]),
               produces: Authenticated::PRODUCES,
               consumes: Authenticated::CONSUMES
          put :viewed do
            Persistence::Repository::Messages.update_view_time(conversation_id: params[:conversation_id], profile_id: @logged_in_profile_id)
            status :no_content
          end

          namespace :messages do
            desc "Returns 20 messages from the requested conversation. Params can be used to paginate the conversation and get more messages.",
                 success: { model: Entities::Messages, message: "A list of messages" },
                 failure: Authenticated.failures([400, 401, 500]),
                 produces: Authenticated::PRODUCES,
                 consumes: Authenticated::CONSUMES
            params do
              optional :min_id, type: Integer, documentation: { desc: "The min id to filter by, can be used to get new messages after the one the user has" }
              optional :max_id, type: Integer, documentation: { desc: "The max id to filter by, should be used to paginate messages back in time" }
            end
            get "/" do
              present Persistence::Repository::Messages.find_messages(conversation_id: params[:conversation_id], min_id: params[:min_id], max_id: params[:max_id]), with: Entities::Messages
            end

            desc "Creates a single message in the given conversation.",
                 success: { model: Entities::Message, message: "The recently created message" },
                 failure: Authenticated.failures([400, 401, 500]),
                 produces: Authenticated::PRODUCES,
                 consumes: Authenticated::CONSUMES
            params do
              requires :content, type: String, documentation: { desc: "The content of the message" }
            end
            post "/" do
              message = Persistence::Repository::Messages.insert_message(conversation_id: params[:conversation_id], profile_id: logged_in_profile_id, content: params[:content])
              Mails::MessageNotification.deliver!(conversation_id: params[:conversation_id], message: message)
              present message, with: Entities::Message
            end
          end
        end
      end
    end
  end
end
