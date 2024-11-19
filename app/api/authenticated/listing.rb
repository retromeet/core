# frozen_string_literal: true

module API
  module Authenticated
    # This class contains any profile-related endpoints
    class Listing < Grape::API
      desc "Returns a list of nearby profiles to the logged-in user.",
           success: { model: API::Entities::OtherProfileInfos, message: "A list of profiles" },
           failure: Authenticated::FAILURES,
           produces: Authenticated::PRODUCES,
           consumes: Authenticated::CONSUMES
      params do
        optional :max_distance, type: Integer, default: 5, values: 5..400, desc: "The maximum distance, in kilometers, to show the profiles away from the users'"
      end
      namespace :listing do
        get "/" do
          profiles = Persistence::Repository::Listing.nearby(account_id: rodauth.session[:account_id], max_distance_in_meters: params[:max_distance] * 1_000)
          present profiles, with: Entities::OtherProfileInfos, only: [{ profiles: %i[display_name account_id age genders orientations relationship_status location_display_name location_distance] }]
        end
      end
    end
  end
end