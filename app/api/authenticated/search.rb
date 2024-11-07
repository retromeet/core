# frozen_string_literal: true

module API
  module Authenticated
    # This class contains any profile-related endpoints
    class Search < Grape::API
      namespace :search do
        desc "Given an address, searches for a geolocation using one location provider. It takes the language of the current user in consideration.",
             success: { model: API::Entities::ProfileInfo, message: "The profile for the authenticated user" },
             failure: Authenticated::FAILURES,
             produces: Authenticated::PRODUCES,
             consumes: Authenticated::CONSUMES
        params do
          requires :query, type: String, desc: "The place you want to look for", documentation: { example: "Méier, Rio de Janeiro, Brasil" }
          optional :limit, type: Integer, default: NominatimClient::MAX_SEARCH_RESULTS, desc: "The maximum number of results to return", values: 0..NominatimClient::MAX_SEARCH_RESULTS
        end
        post :address do
          status :ok
          NominatimClient.search(query: params[:query], limit: params[:limit])
        end
      end
    end
  end
end
