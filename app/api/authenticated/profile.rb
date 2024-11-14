# frozen_string_literal: true

module API
  module Authenticated
    # This class contains any profile-related endpoints
    class Profile < Grape::API
      namespace :profile do
        desc "Returns basic profile information that can be used to display information about the current logged-in user",
             success: { model: API::Entities::ProfileInfo, message: "The profile info for the authenticated user" },
             failure: Authenticated::FAILURES,
             produces: Authenticated::PRODUCES,
             consumes: Authenticated::CONSUMES
        get :info do
          profile_info = Persistence::Repository::Account.basic_profile_info(account_id: rodauth.session[:account_id])
          Entities::BasicProfileInfo.represent(profile_info)
        end

        desc "Returns the complete profile information of the logged-in user. This can be used to display how their profile currently looks like to others.",
             success: { model: API::Entities::ProfileInfo, message: "The profile for the authenticated user" },
             failure: Authenticated::FAILURES,
             produces: Authenticated::PRODUCES,
             consumes: Authenticated::CONSUMES
        get :complete do
          profile_info = Persistence::Repository::Account.profile_info(account_id: rodauth.session[:account_id])
          Entities::ProfileInfo.represent(profile_info)
        end

        desc "Updates the current user's profile with the given parameters. The return will only contain fields that could have been modified.",
             success: { status: 200, model: API::Entities::ProfileInfo, message: "The profile for the authenticated user" },
             failure: Authenticated::FAILURES,
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
        end
        post :complete do
          declared_params = declared(params, include_missing: false)
          # (renatolond, 2024-10-30) empty arrays or nil are functionally the same, so we always coerce to nil
          coerce_empty_array_param_to_nil(declared_params, :genders)
          coerce_empty_array_param_to_nil(declared_params, :orientations)
          coerce_empty_array_param_to_nil(declared_params, :languages)
          error!({ error: :AT_LEAST_ONE_PARAMETER_NEEDED, detail: "You need to provide at least one parameter to be changed, none given" }, :bad_request) if declared_params.empty?

          Persistence::Repository::Account.update_profile_info(account_id: rodauth.session[:account_id], **declared_params)
          profile_info = Persistence::Repository::Account.profile_info(account_id: rodauth.session[:account_id])
          status :ok
          Entities::ProfileInfo.represent(profile_info, only: declared_params.keys.map(&:to_sym))
        end

        desc "Updates the current user's profile location with the given place.",
             success: { status: 200, model: API::Entities::ProfileInfo, message: "The profile for the authenticated user" },
             failure: Authenticated::FAILURES,
             produces: Authenticated::PRODUCES,
             consumes: Authenticated::CONSUMES
        params do
          requires :location, type: String, desc: "The place you're updating to. It should be one of the responses from /api/search/address"
        end
        post :location do
          results = LocationServiceProxy.search(query: params[:location])
          error!({ error: :UNEXPECTED_RESULTS_SIZE, detail: "Expected to have exactly one location with the given name, had #{results.size} instead" }, :unprocessable_content) if results.size != 1

          Persistence::Repository::Account.update_profile_location(account_id: rodauth.session[:account_id], location_result: results.first)
          profile_info = Persistence::Repository::Account.profile_info(account_id: rodauth.session[:account_id])
          status :ok
          Entities::ProfileInfo.represent(profile_info, only: %i[location_display_name])
        end
      end
    end
  end
end
