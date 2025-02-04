# frozen_string_literal: true

module API
  OAUTH_VALID_URI_SCHEMES = if Environment.test? || Environment.development?
    %w[http https]
  else
    %w[https]
  end.freeze

  OAUTH_APPLICATION_SCOPES = %w[
    profile
  ].freeze
  # middleware responsible for authentication
  class RodauthMiddleware < Roda
    plugin :middleware
    plugin :render
    plugin :sessions, secret: ENV.fetch("SESSION_SECRET"), key: "retromeet-core.session"
    plugin :rodauth, json: :only, db: Database.connection do
      enable :login, :logout, :create_account,
             :oauth_authorization_code_grant, :oauth_client_credentials_grant,
             :oauth_application_management, :oauth_grant_management, :oauth_token_revocation,
             :oauth_dynamic_client_registration, :oauth_token_introspection,
             :verify_account # Sends an email to verify the account after creation
      login_return_to_requested_location? true
      verify_account_set_password? false
      require_login_confirmation? false

      oauth_application_scopes OAUTH_APPLICATION_SCOPES
      oauth_valid_uri_schemes OAUTH_VALID_URI_SCHEMES

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
