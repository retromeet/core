# frozen_string_literal: true

module API
  # The base class for the API, from here we include other routes
  class Base < Grape::API
    format :json

    prefix :api

    mount API::Authenticated::Base

    helpers API::Helpers::Params

    unless Environment.test?
      rescue_from :all do |_e|
        error!({ error: "Internal server error" }, 500)
      end
    end

    if Environment.development?
      add_swagger_documentation \
        mount_path: "/swagger_doc",
        info: {
          title: "RetroMeet API",
          description: "This is the API that RetroMeet makes available for all apps that will use it."
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
        security: { jwt_token: [] }
    end
  end
end
