# frozen_string_literal: true

module API
  module Authenticated
    # This class contains any profile-related endpoints
    class Profile < Grape::API
      namespace :profile do
        desc "Returns basic profile information that can be used to display information about the current logged-in user",
             success: { model: API::Entities::ProfileInfo, message: "The profile info for the authenticated user" },
             failure: Authenticated.failures,
             produces: Authenticated::PRODUCES,
             consumes: Authenticated::CONSUMES
        get :info do
          profile_info = Persistence::Repository::Account.basic_profile_info(id: logged_in_profile_id)
          Entities::BasicProfileInfo.represent(profile_info)
        end

        desc "Returns the complete profile information of the logged-in user. This can be used to display how their profile currently looks like to others.",
             success: { model: API::Entities::ProfileInfo, message: "The profile for the authenticated user" },
             failure: Authenticated.failures,
             produces: Authenticated::PRODUCES,
             consumes: Authenticated::CONSUMES
        get :complete do
          profile_info = Persistence::Repository::Account.profile_info(id: logged_in_profile_id)
          Entities::ProfileInfo.represent(profile_info)
        end

        desc "Updates the current user's profile with the given parameters. The return will only contain fields that could have been modified.",
             success: { code: 200, model: API::Entities::ProfileInfo, message: "The profile for the authenticated user" },
             failure: Authenticated.failures([400, 401, 500]),
             produces: Authenticated::PRODUCES,
             consumes: Authenticated::CONSUMES
        params do
          optional :about_me, type: String, desc: "The about me text for the profile"
          optional :display_name, type: String, desc: "The name that is displayed for other users"
          optional :genders, type: [String], values: Persistence::Repository::Account::GENDER_VALUES
          optional :orientations, type: [String], values: Persistence::Repository::Account::ORIENTATION_VALUES
          optional :languages, type: [String], values: Persistence::Repository::Account::LANGUAGE_VALUES
          optional :relationship_type, type: String, values: Persistence::Repository::Account::RELATIONSHIP_TYPE_VALUES
          optional :relationship_status, type: String, values: Persistence::Repository::Account::RELATIONSHIP_STATUS_VALUES
          optional :religion, type: String, values: Persistence::Repository::Account::RELIGION_VALUES
          optional :religion_importance, type: String, values: Persistence::Repository::Account::IMPORTANCE_VALUES
          optional :tobacco, type: String, values: Persistence::Repository::Account::FREQUENCY_VALUES
          optional :marijuana, type: String, values: Persistence::Repository::Account::FREQUENCY_VALUES
          optional :alcohol, type: String, values: Persistence::Repository::Account::FREQUENCY_VALUES
          optional :other_recreational_drugs, type: String, values: Persistence::Repository::Account::FREQUENCY_VALUES
          optional :kids, type: String, values: Persistence::Repository::Account::HAVES_OR_HAVE_NOTS_VALUES
          optional :wants_kids, type: String, values: Persistence::Repository::Account::WANTS_VALUES
          optional :pets, type: String, values: Persistence::Repository::Account::HAVES_OR_HAVE_NOTS_VALUES
          optional :wants_pets, type: String, values: Persistence::Repository::Account::WANTS_VALUES
          optional :pronouns, type: String
          optional :hide_age, type: Boolean
        end
        post :complete do
          declared_params = declared(params, include_missing: false)
          # (renatolond, 2024-10-30) empty arrays or nil are functionally the same, so we always coerce to nil
          coerce_empty_array_param_to_nil(declared_params, :genders)
          coerce_empty_array_param_to_nil(declared_params, :orientations)
          coerce_empty_array_param_to_nil(declared_params, :languages)
          error!({ error: :AT_LEAST_ONE_PARAMETER_NEEDED, detail: "You need to provide at least one parameter to be changed, none given" }, :bad_request) if declared_params.empty?

          Persistence::Repository::Account.update_profile_info(account_id: logged_in_account_id, **declared_params)
          profile_info = Persistence::Repository::Account.profile_info(id: logged_in_profile_id)
          status :ok
          Entities::ProfileInfo.represent(profile_info, only: declared_params.keys.map(&:to_sym))
        end

        desc "Updates the current user's profile location with the given place.",
             success: { code: 200, model: API::Entities::ProfileInfo, message: "The profile for the authenticated user" },
             failure: Authenticated.failures([400, 422, 401, 500]),
             produces: Authenticated::PRODUCES,
             consumes: Authenticated::CONSUMES
        params do
          requires :location, type: String, desc: "The place you're updating to. It should be one of the responses from /api/search/address"
          requires :osm_id, type: Integer, desc: "The id of the place you're updating to. It should be in one of the responses from /api/search/address"
        end
        post :location do
          results = LocationServiceProxy.search(query: params[:location])
          results.select! { |r| r.osm_id == params[:osm_id] }
          error!({ error: :UNEXPECTED_RESULTS_SIZE, detail: "Expected to have exactly one location with the given name, had #{results.size} instead" }, :unprocessable_content) if results.size != 1

          Persistence::Repository::Account.update_profile_location(account_id: logged_in_account_id, location_result: results.first)
          profile_info = Persistence::Repository::Account.profile_info(id: logged_in_profile_id)
          status :ok
          Entities::ProfileInfo.represent(profile_info, only: %i[location_display_name])
        end

        desc "Endpoint that accepts a new profile picture",
             success: [code: 204, message: "Updated sucessfully"],
             failure: Authenticated.failures,
             consumes: ["multipart/form-data"]
        params do
          requires :profile_picture, type: File
        end
        post :picture do
          attacher = ImageUploader::Attacher.from_data(Persistence::Repository::Account.profile_picture(account_id: logged_in_account_id))
          attacher.assign(params[:profile_picture], metadata: { type: :profile_picture, profile_id: logged_in_profile_id })
          attacher.finalize
          Persistence::Repository::Account.update_profile_picture(account_id: logged_in_account_id, picture: attacher.data)
          status :no_content
        end

        params do
          requires :id, type: String, documentation: { format: :uuid }, regexp: Utils::UUID7_RE
        end
        namespace ":id" do
          desc "Returns the complete profile information for the requested profile id.",
               success: { model: API::Entities::OtherProfileInfo, message: "The profile for the account id, if exists" },
               failure: Authenticated.failures([400, 401, 500]),
               produces: Authenticated::PRODUCES,
               consumes: Authenticated::CONSUMES
          get :complete do
            profile_info = Persistence::Repository::Account.profile_info(id: params[:id])
            error!({ error: :PROFILE_NOT_FOUND, detail: "The requested profile does not exist or you don't have permission to see it" }, :not_found) unless profile_info

            profile_info[:is_blocked] = true if Persistence::Repository::Blocks.block_info(profile_id: logged_in_profile_id, target_profile_id: params[:id]).present?
            Entities::OtherProfileInfo.represent(profile_info)
          end

          desc "Creates a block against the requested profile id",
               success: [code: 204, message: "Updated sucessfully"],
               failure: Authenticated.failures([401, 404, 500]),
               produces: Authenticated::PRODUCES,
               consumes: Authenticated::CONSUMES
          post :block do
            Persistence::Repository::Blocks.block_profile(target_profile_id: params[:id], profile_id: logged_in_profile_id)

            status :no_content
          end

          desc "Deletes a block against the requested profile id, if exist",
               success: [code: 204, message: "Updated sucessfully"],
               failure: Authenticated.failures([401, 404, 500]),
               produces: Authenticated::PRODUCES,
               consumes: Authenticated::CONSUMES
          delete :block do
            Persistence::Repository::Blocks.unblock_profile(target_profile_id: params[:id], profile_id: logged_in_profile_id)

            status :no_content
          end

          desc "Returns an existing conversation between the logged-in user and the user id, if it exists",
               success: { model: API::Entities::Conversation, message: "The profile for the account id, if exists" },
               failure: Authenticated.failures([400, 401, 404, 422, 500]),
               produces: Authenticated::PRODUCES,
               consumes: Authenticated::CONSUMES
          get :conversation do
            conversation = Persistence::Repository::Messages.conversation_between(profile1_id: logged_in_profile_id, profile2_id: params[:id])
            error!({ error: "NOT_FOUND", details: [{ fields: [], errors: ["conversation not found"] }], with: Entities::Error }, 404) unless conversation

            Entities::Conversation.represent(conversation)
          rescue ArgumentError
            error!({ error: "PROFILE_IS_THE_SAME", details: [{ fields: %i[id], errors: ["the requested profile is the user's"] }], with: Entities::Error }, 422)
          end
        end
      end
    end
  end
end
