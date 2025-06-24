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
    class << self
      # This function will choose the request locale.
      # It use the +request_locale+ key in the +env+ variable if available, otherwise, it checks if the request
      # is authenticated and if so takes the locale from the profile preferences. If not, will take from the session and lastly
      # from the rack.locale
      # It also memoizes the result to the env
      #
      # @param env [Hash] the env variable for the request
      # @param session [Object] the session object from roda for the current request
      # @param rodauth [Rodauth] the rodauth object for the current request
      # @return [String] The request locale
      def choose_request_locale(env, session, rodauth)
        return env["request_locale"] if env["request_locale"]

        profile_preferences = Persistence::Repository::Account.profile_preferences_from_account_id(account_id: rodauth.account!&.dig(:id))
        profile_locale = profile_preferences["locale"] if profile_preferences&.key?("locale")
        env["request_locale"] = profile_locale || session["locale"] || env["rack.locale"]
      end
    end
    plugin :public, root: File.expand_path("../assets/images", __dir__)
    plugin :flash
    plugin :assets, css: "layout.scss", js: "base.js", path: File.expand_path("../assets", __dir__)

    plugin :render, views: File.expand_path("../assets/html", __dir__), engine: "haml", engine_opts: { "haml" => { escape_html: false } }, template_opts: { default_encoding: "UTF-8" }
    plugin :additional_view_directories, [File.expand_path("../mail/html", __dir__)]
    plugin :additional_render_engines, ["erb"]

    plugin :sessions, secret: EnvironmentConfig.session_secret, key: "retromeet-core.session"

    plugin :route_csrf
    plugin :middleware, next_if_not_found: true
    plugin :error_handler

    error do |e|
      if Environment.test? || Environment.development?
        puts e
        puts e.backtrace
      end
      render(:"500")
    end

    plugin :rodauth, json: true, db: Database.connection do
      enable :login, :logout, :create_account, # Enables the basic rodauth functionality: login, logout, and creating account
             :reset_password,
             :i18n, # Enables translation for fields around the app
             :oauth_authorization_code_grant, # Enable base oauth authorization (i.e /authorize flow)
             :oauth_client_credentials_grant, # Enables applications to fetch a token after initial authorization (i.e /token endpoint)
             # :oauth_application_management, # Enables the application management UI
             # :oauth_grant_management, # Enables the grant management UI
             :oauth_token_revocation, # Enables token revocation for logout (i.e /revoke endpoint)
             :oauth_dynamic_client_registration, # Enables clients to register directly (i.e /register endpoint)
             :oauth_token_introspection, # Enables clients to verify token information
             :verify_account # Sends an email to verify the account after creation
      login_return_to_requested_location? true
      verify_account_set_password? false
      require_login_confirmation? false
      title_instance_variable :@page_title

      authorize_route "oauth/authorize"
      token_route "oauth/token"
      revoke_route "oauth/revoke"
      register_route "oauth/register"
      introspect_route "oauth/introspect"

      oauth_application_scopes OAUTH_APPLICATION_SCOPES
      oauth_valid_uri_schemes OAUTH_VALID_URI_SCHEMES
      oauth_metadata_op_policy_uri "#{RetroMeet::Config.host}/policy"
      oauth_metadata_op_tos_uri "#{RetroMeet::Config.host}/terms"
      oauth_metadata_service_documentation "https://join.retromeet.social/dev"

      field_error_attributes { |field| "class='is-danger input is-large' aria-invalid=\"true\" aria-describedby=\"#{field}_error_message\"" }
      formatted_field_error { |field, reason| "<p id=\"#{field}_error_message\" class='help is-danger'>#{reason}.</p>" }

      domain do
        EnvironmentConfig.retromeet_core_host
      end

      email_from do
        EnvironmentConfig.smtp_from_address
      end

      create_email do |subject, body|
        mail = super(subject, body)
        # TODO: Make this multipart, simplified with text and all
        mail.content_type = "text/html; charset=utf-8"
        mail
      end
      email_subject_prefix do
        "RetroMeet: "
      end
      already_logged_in do
        redirect "/"
      end

      verify_account_email_body do
        render "verify_account"
      end
      reset_password_email_body do
        render "reset_password"
      end

      before_rodauth do
        I18n.locale = RodauthMiddleware.choose_request_locale(request.env, session, self)
      end

      before_register do
        # Before registering, rodauth allows to authorize the client. Currently we allow any client to register, since the idea is that anyone could make a client.
        # This is why the nil, but probably should verify for a logged in user in some cases.
        nil
      end
      before_create_account do
        unless (birth_date = param_or_nil("birth_date"))
          throw_error_status(422, "birth_date", I18n.t("create_account.birth_date.required"))
        end

        begin
          birth_date = Date.parse(birth_date)
        rescue
          throw_error_status(422, "birth_date", I18n.t("create_account.birth_date.invalid_date"))
        end

        throw_error_status(422, "birth_date", I18n.t("create_account.birth_date.over_18_required")) if AgeHelper.age_from_date(birth_date) < 18
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
      I18n.locale = RodauthMiddleware.choose_request_locale(env, session, rodauth)

      r.root do
        view(template: "root", layout: "hero")
      end
      r.is("terms") do
        view(:terms)
      end
      r.is("privacy") do
        view(:privacy)
      end

      check_csrf! unless r.content_type&.include?("application/json") || r.path.start_with?("/api/")
      # rodauth.load_oauth_application_management_routes
      # rodauth.load_oauth_grant_management_routes
      rodauth.load_oauth_server_metadata_route # Loads .well-known/oauth-authorization-server path

      r.is("language") do
        r.post do
          session["locale"] = r.params["locale"] if I18n.available_locales.include?(r.params["locale"].to_sym)
          r.redirect("/")
        end
      end

      # Supposed to catch any non-api paths that are not in rodauth
      # Should be the last one, otherwise other routes will also 404
      # The regex is supposed to mean:
      #   anything that is not api/somethingelse OR api(something that is not a /)+anything else
      r.is(%r{(?!api/).+|api[^/].+}) do
        render(:"404")
      end
      env["rodauth"] = rodauth
    end
  end
end
