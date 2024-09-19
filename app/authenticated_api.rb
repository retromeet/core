# frozen_string_literal: true

# Class containing all authenticated endpoints. If an endpoint needs no authentication it should instead go into +API+.
class AuthenticatedAPI < Grape::API
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

  desc "foobar"
  get :profile_info do
    { display_name: "renatolond" }
  end
end
