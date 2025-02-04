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

      before_create_account do
        unless (birth_date = param_or_nil("birth_date"))
          throw_error_status(422, "birth_date", "must be present")
        end

        begin
          birth_date = Date.parse(birth_date)
        rescue
          throw_error_status(422, "birth_date", "must be a valid date")
        end

        throw_error_status(422, "birth_date", "must be 18-year-old or older") if AgeHelper.age_from_date(birth_date) < 18
      end
      after_create_account do
        display_name = account[:email].split("@", 2).first
        Persistence::Repository::Account.create_profile(account_id: account[:id], display_name:, birth_date: param("birth_date"))
      end
    end

    route do |r|
      r.rodauth
      env["rodauth"] = rodauth
    end
  end
end
