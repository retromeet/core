# frozen_string_literal: true

module API
  module Authenticated
    # Class containing all authenticated endpoints. If an endpoint needs no authentication it should instead go into +Base+.
    class Base < Grape::API
      helpers do
        # Makes it easier to access rodauth
        # @return [Rodauth::Auth]
        def rodauth
          env["rodauth"]
        end

        # If the user is not authenticated, returns a 401 error
        # @return [void]
        def authenticate!
          error!("401 Unauthorized", 401) unless authenticated?
        end

        # @return [Boolean]
        def authenticated?
          rodauth&.authenticated?
        end
      end

      before { authenticate! }

      mount API::Authenticated::Profile
      mount API::Authenticated::Search
      mount API::Authenticated::Listing
      mount API::Authenticated::Conversations
      mount API::Authenticated::Reports

      namespace :images do
        desc "",
             hidden: true
        get "*" do
          # (renatolond, 2024-12-03) This is a bit to hack-y for my tastes.
          # The idea is that if Shrine is configured to serve from disk, we use the rodauth authentication here as well.
          # It might be better to mount this apart from grape and just check auth first.
          # For the moment it will do
          new_env = request.env.dup
          new_env["PATH_INFO"] = request.path[("/api".length)..]
          status, headers, body = ImageUploader.download_response(new_env)
          content_type headers["content-type"]
          headers.each { |k, v| header k, v }
          status status
          stream body.file.to_io
        end
      end
    end
  end
end
