# frozen_string_literal: true

# The main class for the API, from here we include other routes
class API < Grape::API
  format :json

  prefix :api

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
      rodauth.authenticated?
    end
  end

  before { authenticate! }

  get :hello do
    { hello: :world }
  end

  get :profile_info do
    { display_name: "renatolond" }
  end
end
