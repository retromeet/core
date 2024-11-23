# frozen_string_literal: true

module API
  module Authenticated
    # This class contains any profile-related endpoints
    class Conversations < Grape::API
      desc "Returns a list of nearby profiles to the logged-in user.",
           success: { model: API::Entities::Conversations, message: "A list of profiles" },
           failure: Authenticated::FAILURES,
           produces: Authenticated::PRODUCES,
           consumes: Authenticated::CONSUMES
      namespace :conversations do
        helpers do
          # @param conversation [Hash{Symbol => Object}] A hash containing conversation information, will be modified!
          # @return [Hash{Symbol => Object}] The modified conversation object
          def filter_conversation_for_current_profile!(conversation)
            if conversation[:profile1_id] == rodauth.session[:profile_id]
              conversation[:other_profile_id] = conversation.delete(:profile2_id)
              conversation[:last_seen_at] = conversation.delete(:profile1_last_seen_at)
              conversation.delete(:profile1_id)
              conversation.delete(:profile2_last_seen_at)
            elsif conversation[:profile2_id] == rodauth.session[:profile_id]
              conversation[:other_profile_id] = conversation.delete(:profile1_id)
              conversation[:last_seen_at] = conversation.delete(:profile2_last_seen_at)
              conversation.delete(:profile2_id)
              conversation.delete(:profile1_last_seen_at)
            end
            conversation[:other_profile] = Persistence::Repository::Account.profile_info(id: conversation[:other_profile_id])
            conversation
          end
        end

        get "/" do
          conversations = Persistence::Repository::Messages.find_conversations(profile_id: rodauth.session[:profile_id])
          conversations.each do |conversation|
            filter_conversation_for_current_profile!(conversation)
          end
          present conversations, with: Entities::Conversations
        end

        params do
          requires :other_profile_id, type: String, regexp: /\A[0-9A-F]{8}-[0-9A-F]{4}-7[0-9A-F]{3}-[89AB][0-9A-F]{3}-[0-9A-F]{12}\z/i
        end
        post "/" do
          conversation_id = Persistence::Repository::Messages.upsert_conversation(profile1_id: rodauth.session[:profile_id], profile2_id: params[:other_profile_id])
          conversation = { id: conversation_id }
          present conversation, with: Entities::Conversation
        end

        namespace ":conversation_id" do
          params do
            requires :conversation_id, type: String, regexp: /\A[0-9A-F]{8}-[0-9A-F]{4}-7[0-9A-F]{3}-[89AB][0-9A-F]{3}-[0-9A-F]{12}\z/i
          end

          get "/" do
            conversation = Persistence::Repository::Messages.find_conversation(profile_id: rodauth.session[:profile_id], conversation_id: params[:conversation_id])

            filter_conversation_for_current_profile!(conversation)

            present conversation, with: Entities::Conversation
          end

          namespace :messages do
            params do
              optional :min_id, type: Integer, documentation: { desc: "The min id to filter by, can be used to get new messages after the one the user has" }
              optional :max_id, type: Integer, documentation: { desc: "The max id to filter by, should be used to paginate messages back in time" }
            end
            get "/" do
              present Persistence::Repository::Messages.find_messages(conversation_id: params[:conversation_id], min_id: params[:min_id], max_id: params[:max_id]), with: Entities::Messages
            end

            params do
              requires :content, type: String, documentation: { desc: "The content of the message" }
            end
            post "/" do
              message_id = Persistence::Repository::Messages.insert_message(conversation_id: params[:conversation_id], profile_id: rodauth.session[:profile_id], content: params[:content])
              present Persistence::Repository::Messages.find_messages(conversation_id: params[:conversation_id], min_id: message_id - 1).first, with: Entities::Message
            end
          end
        end
      end
    end
  end
end
