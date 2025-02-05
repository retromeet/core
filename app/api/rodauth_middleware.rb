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
    plugin :public, root: File.expand_path("../assets/images", __dir__)
    plugin :flash
    # plugin :middleware
    plugin :assets, css: "layout.scss", path: File.expand_path("../assets", __dir__)

    plugin :render, views: File.expand_path("../assets/html", __dir__), engine: "haml", engine_opts: { "haml" => { escape_html: false } }, template_opts: { default_encoding: "UTF-8" }
    plugin :i18n

    plugin :sessions, secret: ENV.delete("SESSION_SECRET"), key: "retromeet-core.session"

    plugin :route_csrf
    plugin :middleware, next_if_not_found: true
    plugin :rodauth, db: Database.connection do
      enable :login, :logout, :create_account,
             :oauth_authorization_code_grant, :oauth_client_credentials_grant,
             :oauth_application_management, :oauth_grant_management, :oauth_token_revocation,
             :oauth_dynamic_client_registration, :oauth_token_introspection,
             :verify_account # Sends an email to verify the account after creation
      login_return_to_requested_location? true
      verify_account_set_password? false
      require_login_confirmation? false
      title_instance_variable :@page_title

      oauth_application_scopes OAUTH_APPLICATION_SCOPES
      oauth_valid_uri_schemes OAUTH_VALID_URI_SCHEMES

      field_error_attributes { |field| "class='is-danger input is-large' aria-invalid=\"true\" aria-describedby=\"#{field}_error_message\"" }
      formatted_field_error { |field, reason| "<p id=\"#{field}_error_message\" class='help is-danger'>#{reason}.</p>" }
      before_create_account do
        unless (birth_date = param_or_nil("birth_date"))
          throw_error_status(422, "birth_date", R18n.t.birth_date.required)
        end

        begin
          birth_date = Date.parse(birth_date)
        rescue
          throw_error_status(422, "birth_date", R18n.t.birth_date.invalid_date)
        end

        throw_error_status(422, "birth_date", R18n.t.birth_date.over_18_required) if AgeHelper.age_from_date(birth_date) < 18
      end
      after_create_account do
        display_name = account[:email].split("@", 2).first
        Persistence::Repository::Account.create_profile(account_id: account[:id], display_name:, birth_date: param("birth_date"))
      end
    end

    route do |r|
      r.assets
      r.public

      r.rodauth
      check_csrf! unless r.content_type&.include?("application/json")

      env["rodauth"] = rodauth
    end
  end
end
