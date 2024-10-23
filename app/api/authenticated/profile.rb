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
      end
    end
  end
end
