# frozen_string_literal: true

module API
  module Authenticated
    # This class contains any profile-related endpoints
    class Listing < Grape::API
      namespace :listing do
        get "/" do
          profiles = Persistence::Repository::Listing.nearby(account_id: rodauth.session[:account_id])
          present profiles, with: Entities::OtherProfileInfos
        end
      end
    end
  end
end
