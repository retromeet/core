# frozen_string_literal: true

require_relative "authenticated_api"

# The main class for the API, from here we include other routes
class API < Grape::API
  format :json

  prefix :api

  mount AuthenticatedAPI

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
