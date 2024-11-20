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
        get "/" do
          conversations = Persistence::Repository::Messages.find_conversations(profile_id: rodauth.session[:profile_id])
          conversations.each do |conversation|
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
      end
    end
  end
end
