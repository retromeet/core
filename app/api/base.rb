# frozen_string_literal: true

module API
  # The base class for the API, from here we include other routes
  class Base < Grape::API
    format :json

    prefix :api

    mount API::Authenticated::Base

    helpers API::Helpers::Params

    rescue_from Persistence::Repository::Blocks::ProfileNotFound do |_e|
      error!({ error: "NOT_FOUND", details: { fields: :target_profile_id, errors: "not found" }, with: Entities::Error }, 404)
    end

    rescue_from Persistence::Repository::Messages::ProfileNotFound do |_e|
      error!({ error: "NOT_FOUND", details: { fields: :other_profile_id, errors: "not found" }, with: Entities::Error }, 404)
    end

    rescue_from Persistence::Repository::Reports::MessagesNotFoundOrNotFromSender do |_e|
      error!({ error: "MESSAGE_NOT_FOUND_OR_NOT_FROM_SENDER", details: [{ fields: %i[message_ids], errors: ["one of the ids was not found or does not belong to the other profile"] }], with: Entities::Error }, 422)
    end

    rescue_from Grape::Exceptions::ValidationErrors do |e|
      errors = e.errors.map do |key, value|
        { fields: key, errors: value }
      end
      error!({ error: "VALIDATION_ERROR", details: errors, with: Entities::Error }, 400)
    end

    rescue_from :all do |e|
      if Environment.test? || Environment.development?
        puts e
        puts e.backtrace
      end
      error!({ error: "INTERNAL_SERVER_ERROR", with: Entities::Error }, 500)
    end

    if Environment.development? || Environment.test?
      add_swagger_documentation \
        mount_path: "/swagger_doc",
        doc_version: RetroMeet::Version.to_s,
        info: {
          title: "RetroMeet API",
          description: "This is the API that RetroMeet makes available for all apps that will use it.",
          license: "GNU Affero General Public License v3.0",
          license_url: "https://raw.githubusercontent.com/retromeet/core/refs/heads/main/LICENSE"
        },
        security_definitions: {
          jwt_token: {
            type: "apiKey",
            name: "Authorization",
            in: "header",
            description: "A JWT token that can be obtained by calling the login endpoint.",
            authorizationUrl: "/login"
          }
        },
        security: { jwt_token: [] },
        consumes: ["application/json"],
        produces: ["application/json"]
    end

    route :any, "*path" do
      error!({ error: "NOT_FOUND", with: Entities::Error }, 404)
    end
  end
end
