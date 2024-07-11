# frozen_string_literal: true

require_relative "../config/database"

# middleware responsible for authentication
class RodauthMiddleware < Roda
  plugin :middleware
  plugin :rodauth, json: :only, db: Database.connection do
    enable :login, :logout, :create_account, :json, :jwt
    jwt_secret ENV.fetch("JWT_SECRET")
  end

  route do |r|
    r.rodauth
    rodauth.require_authentication
    env["rodauth"] = rodauth
  end
end
