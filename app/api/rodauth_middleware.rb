# frozen_string_literal: true

module API
  # middleware responsible for authentication
  class RodauthMiddleware < Roda
    plugin :middleware
    plugin :rodauth, json: :only, db: Database.connection do
      enable :login, :logout, :create_account,
             :json, # This enables the JSON API that is used to access rodauth functionality.
             :jwt, # This enables the JWT tokens
             :active_sessions
      jwt_secret ENV.fetch("JWT_SECRET")
      hmac_secret ENV.fetch("HMAC_SECRET")
      require_password_confirmation? false
      require_login_confirmation? false

      after_create_account do
        display_name = account[:email].split("@", 2).first
        Database.connection[:account_informations].insert(account_id: account[:id], display_name:)
      end
    end

    route do |r|
      unless Environment.development? && r.path == "/api/swagger_doc"
        r.rodauth
        rodauth.require_authentication
        rodauth.check_active_session
        env["rodauth"] = rodauth
      end
    end
  end
end
