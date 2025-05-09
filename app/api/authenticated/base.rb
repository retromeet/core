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

        # Sets up things in rodauth for this request
        # These are done here so they are only done in case of being in an Authenticated route
        # @return [void]
        def rodauth_setup
          @logged_in_account_id = rodauth.authorization_token[:account_id]
          @logged_in_profile_id = Persistence::Repository::Account.profile_id_from_account_id(account_id: @logged_in_account_id)
        end

        attr_reader :logged_in_profile_id
        attr_reader :logged_in_account_id

        # If the user is not authenticated, returns a 401 error
        # @return [void]
        def authenticate!
          error!({ error: "UNAUTHORIZED", details: [{ fields: nil, errors: "Missing or invalid authorization token" }], with: Entities::Error }, 401) unless rodauth.authorization_token
          # TODO: validate scopes
          # token_scopes = authorization_token[oauth_grants_scopes_column].split(oauth_scope_separator)
          # authorization_required unless scopes.any? { |scope| token_scopes.include?(scope) }
        end

        # @return [Boolean]
        def authenticated?
          rodauth&.authenticated?
        end
      end

      before do
        authenticate!
        rodauth_setup
      end

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
